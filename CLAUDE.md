# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A SwiftUI + Core Data iOS app for memorizing Bible verses. Users search/save verses (Korean 개역한글, NIV, or Message translations), organize them into categories, and practice with flashcards, fill-in-the-blank, or quizzes.

## Build & run

No test target exists, no SPM/CocoaPods dependencies, no lint config — this is a single Xcode project.

```bash
# Build
xcodebuild -project "Bible Memorization.xcodeproj" -scheme "Bible Memorization" -configuration Debug build

# Or open in Xcode
open "Bible Memorization.xcodeproj"
```

Run/debug via Xcode (Cmd+R) using the simulator — that's the normal workflow here, not CLI builds.

## Architecture

**Verse data has two independent sources**, selected by `Translation.bibleId`:
- `개역한글` (Korean) → `KoreanBibleService`, reads the entire Bible from the bundled `korean_bible.json` (`[bookId: [[String]]]`, indexed `[chapter-1][verse-1]`). Fully offline, no API key needed.
- `NIV` / `Message` → `BibleAPIService`, calls `api.scripture.api.bible` using the key in `APIConfig.swift`, which reads `APIKeys.bibleAPIKey`. `Bible Memorization/APIKeys.swift` is gitignored and **not present after a fresh clone** — create it locally with:
  ```swift
  import Foundation
  enum APIKeys {
      static let bibleAPIKey = "YOUR_KEY_HERE"
  }
  ```
  Without it, the project won't build.

Both services return the same `VerseData` model, so downstream views don't care which source a verse came from. `BibleBook.all` provides the canonical book id ↔ Korean/English name mapping used by both services and the UI.

**Chapter reading and full-Bible search go through `BibleContentService`**, a thin static-dispatch enum that routes to `KoreanBibleService`/`BibleAPIService` by `Translation` (same split as verse fetching above). Both services expose `fetchChapter`/`search` returning translation-agnostic `ChapterContent`/`SearchResultItem` models (`Models/APIModels.swift`). `BibleAPIService.fetchChapter` parses the API's `[N]`/`[N-M]` verse markers from chapter text — the `[N-M]` form only appears in paraphrase translations like Message, which group multiple verses under one marker.

**Persistence is Core Data** (`BibleMemo.xcdatamodeld`), with three entities:
- `Category` (name, createdAt) — has-many `SavedVerse`
- `SavedVerse` (reference, text, translation, isMemorized, savedAt) — belongs-to `Category`
- `Bookmark` (bookId, chapter, verse, translation, reference, createdAt) — standalone, unrelated to `Category`/`SavedVerse`. Marks a reading position from the Read tab (chapter-level bookmarks use `verse == 0` as a sentinel); conceptually separate from `SavedVerse`, which is for memorization practice.

`PersistenceController` (`Persistence.swift`) seeds 10 default Korean categories (믿음, 구원, 기도, ...) on first launch via a `UserDefaults` flag. All views read Core Data through `@FetchRequest`, scoped with an `NSPredicate` on `category` and/or `translation` (verses are tracked per-translation, so the same reference saved in Korean and NIV are separate `SavedVerse` rows).

**Navigation is a 4-tab `TabView`** (`ContentView.swift`): Home, Practice, Library, Read. Each tab root is its own `NavigationView`.

- **Home** (`HomeView`) — dashboard: verse-of-the-day (deterministic pick by day-of-year, Korean translation only), progress stats, "continue practicing" card, collection previews.
- **Practice** (`StudyModePickerView`) — pick a category + translation, then launch one of three full-screen study sessions (`FlashcardSessionView`, `FillInBlankView`, `QuizSessionView`), each gated by a minimum verse count (flashcard/fill-in-blank need ≥1, quiz needs ≥4 for 4-choice distractors). Sessions report results via `StudyResultView` and mark verses `isMemorized`.
- **Library** (`LibraryView` → `CategoryDetailView`) — category CRUD and the verse list per category. Adding verses goes through `SearchView` (search by book/chapter/verse, fetches from both services in parallel) → `SaveVerseSheet` (pick category, save).
- **Read** (`BibleReadingView`) — chapter-by-chapter reading, independent of the memorization flow above. Owns `bookId`/`chapter`/`translation`/`highlightVerse` state and switches between three sub-screens (`ChapterReaderView`, `BookmarksView`, `BibleWordSearchView`) itself rather than pushing via `NavigationLink` — this mirrors the confirmed design spec, which models Read as one tab with an internal screen stack, not three tabs. `ChapterReaderView` handles book/chapter navigation (via `BookPickerSheet` + `ChapterPickerSheet`, both bottom sheets) and verse/chapter bookmarking (long-press or tap a verse row for a verse bookmark; toolbar button for a chapter bookmark). `BookmarksView` and `BibleWordSearchView` both jump back into `ChapterReaderView` at a specific verse via the same `onJump` closure, which also clears back to the main sub-screen.

**Theming**: `AppTheme.swift` defines the "Quiet Parchment" palette (`Color.parchment`, `.terracotta`, `.cardSurface`, `.darkSurface`, `.mutedBrown`) plus shared view modifiers (`.cardStyle()`, `.parchmentBackground()`). Reuse these rather than hardcoding colors in new views.

**UI strings are Korean** throughout (labels, alerts, empty states). Match this when adding UI.

## Design workflow

`개발-디자인-워크플로우.md` (Korean) documents the intended process for this project: plan in Claude Code → mock up/prototype in Claude Design → extract SwiftUI specs (colors, fonts, component measurements) from the finalized design → implement in Claude Code. The lesson recorded there: build the design first, then implement once — implementing early and re-skinning later caused duplicate work.
