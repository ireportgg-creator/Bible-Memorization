import SwiftUI

struct BibleReadingView: View {
    private enum ReadSubScreen {
        case main, bookmarks, search
    }

    @State private var screen: ReadSubScreen = .main
    @State private var bookId = "GEN"
    @State private var chapter = 1
    @State private var translation: Translation = .korean
    @State private var highlightVerse: Int?
    @State private var chapterCounts: [String: Int] = [:]

    var body: some View {
        NavigationView {
            Group {
                switch screen {
                case .main:
                    ChapterReaderView(
                        bookId: $bookId,
                        chapter: $chapter,
                        translation: $translation,
                        highlightVerse: $highlightVerse,
                        chapterCounts: chapterCounts,
                        onOpenBookmarks: { screen = .bookmarks },
                        onOpenSearch: { screen = .search }
                    )
                case .bookmarks:
                    BookmarksView(onBack: { screen = .main }, onJump: jump)
                case .search:
                    BibleWordSearchView(onBack: { screen = .main }, onJump: jump)
                }
            }
            .navigationBarHidden(true)
            .onAppear { screen = .main }
        }
        .task {
            guard chapterCounts.isEmpty else { return }
            var counts: [String: Int] = [:]
            for book in BibleBook.all {
                counts[book.id] = (try? await BibleContentService.chapterCount(bookId: book.id)) ?? 1
            }
            chapterCounts = counts
        }
    }

    private func jump(_ newBookId: String, _ newChapter: Int, _ verse: Int?, _ newTranslation: Translation) {
        bookId = newBookId
        chapter = newChapter
        translation = newTranslation
        highlightVerse = verse
        screen = .main
    }
}
