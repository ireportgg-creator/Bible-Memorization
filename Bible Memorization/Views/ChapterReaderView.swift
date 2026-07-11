import SwiftUI
import CoreData

struct ChapterReaderView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var bookId: String
    @Binding var chapter: Int
    @Binding var translation: Translation
    @Binding var highlightVerse: Int?
    let chapterCounts: [String: Int]
    let onOpenBookmarks: () -> Void
    let onOpenSearch: () -> Void

    @State private var chapterContent: ChapterContent?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var pickerStep: PickerStep?
    @State private var pendingBook: BibleBook = BibleBook.all[0]
    @State private var verseActionId: Int?
    @State private var toastMessage: String?

    private enum PickerStep: Identifiable {
        case book
        case chapter(BibleBook)
        var id: String {
            switch self {
            case .book: return "book"
            case .chapter(let b): return "chapter-\(b.id)"
            }
        }
    }

    private var currentBook: BibleBook {
        BibleBook.all.first(where: { $0.id == bookId }) ?? BibleBook.all[0]
    }
    private var totalChapters: Int { chapterCounts[bookId] ?? 1 }
    private var currentBookIndex: Int { BibleBook.all.firstIndex(where: { $0.id == bookId }) ?? 0 }
    private var isFirstChapterOfBible: Bool { currentBookIndex == 0 && chapter <= 1 }
    private var isLastChapterOfBible: Bool { currentBookIndex == BibleBook.all.count - 1 && chapter >= totalChapters }

    var body: some View {
        VStack(spacing: 0) {
            header
            content
            navBar
        }
        .parchmentBackground()
        .overlay(alignment: .bottom) {
            if let toastMessage {
                Text(toastMessage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.parchment)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color.darkSurface)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.25), radius: 16, y: 4)
                    .padding(.bottom, 100)
            }
        }
        .task(id: "\(bookId)-\(chapter)-\(translation.rawValue)") {
            await loadChapter()
        }
        .task(id: highlightVerse) {
            guard highlightVerse != nil else { return }
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            highlightVerse = nil
        }
        .task(id: toastMessage) {
            guard toastMessage != nil else { return }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            toastMessage = nil
        }
        .sheet(item: $pickerStep) { step in
            switch step {
            case .book:
                BookPickerSheet(selectedBook: $pendingBook, onSelect: {
                    pickerStep = .chapter(pendingBook)
                })
            case .chapter(let book):
                ChapterPickerSheet(
                    book: book,
                    totalChapters: chapterCounts[book.id] ?? 1,
                    currentBookId: bookId,
                    currentChapter: chapter,
                    onSelect: { number in
                        bookId = book.id
                        chapter = number
                        highlightVerse = nil
                        pickerStep = nil
                    },
                    onBack: { pickerStep = .book }
                )
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button {
                    pendingBook = currentBook
                    pickerStep = .book
                } label: {
                    HStack(spacing: 6) {
                        Text("\(currentBook.korean) \(chapter)장")
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(.darkSurface)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.terracotta)
                    }
                }
                Spacer()
                HStack(spacing: 6) {
                    circleButton(systemImage: "bookmark", action: onOpenBookmarks)
                    circleButton(systemImage: "magnifyingglass", action: onOpenSearch)
                }
            }

            TranslationSegmentedPicker(selection: $translation)

            Button {
                addBookmark(verse: 0)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 12, weight: .semibold))
                    Text("이 장 책갈피에 추가")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.terracotta)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .padding(.bottom, 12)
        .background(Color.parchment)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.divider).frame(height: 0.5)
        }
    }

    private func circleButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.darkSurface)
                .frame(width: 36, height: 36)
                .background(Color.mutedBrown.opacity(0.1))
                .clipShape(Circle())
        }
    }

    private var content: some View {
        ScrollView {
            if isLoading {
                ProgressView().padding(.top, 40)
            } else if let errorMessage {
                Text(errorMessage)
                    .font(.callout)
                    .foregroundColor(.mutedBrown)
                    .padding(.top, 40)
            } else if let chapterContent {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(chapterContent.verses) { verse in
                        verseRow(verse)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
        }
    }

    private func verseRow(_ verse: VerseLine) -> some View {
        let isHighlighted = highlightVerse == verse.number
        let isActionShown = verseActionId == verse.number

        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 10) {
                Text(verse.numberLabel)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.terracotta)
                    .frame(width: 22, alignment: .leading)
                    .padding(.top, 4)
                Text(verse.text)
                    .font(.system(size: 18, design: .serif))
                    .lineSpacing(11)
                    .foregroundColor(.darkSurface)
            }
            .padding(.vertical, 9)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                verseActionId = isActionShown ? nil : verse.number
            }

            if isActionShown {
                HStack(spacing: 10) {
                    Button {
                        addBookmark(verse: verse.number)
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "bookmark")
                                .font(.system(size: 11, weight: .semibold))
                            Text("책갈피 추가")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.terracotta)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.terracottaTint)
                        .cornerRadius(8)
                    }
                    Button {
                        verseActionId = nil
                    } label: {
                        Text("취소")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.mutedBrown)
                    }
                }
                .padding(.leading, 40)
                .padding(.trailing, 8)
                .padding(.bottom, 12)
            }
        }
        .background(isHighlighted ? Color.highlightTint : Color.clear)
        .cornerRadius(10)
        .animation(.easeInOut(duration: 0.4), value: isHighlighted)
    }

    private var navBar: some View {
        HStack {
            Button {
                goToPreviousChapter()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left").font(.system(size: 13, weight: .bold))
                    Text("이전 장").font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.terracotta)
            }
            .disabled(isFirstChapterOfBible)
            .opacity(isFirstChapterOfBible ? 0.3 : 1)

            Spacer()

            Text("\(currentBook.korean) \(chapter) / \(totalChapters)")
                .font(.system(size: 13))
                .foregroundColor(.mutedBrown)

            Spacer()

            Button {
                goToNextChapter()
            } label: {
                HStack(spacing: 4) {
                    Text("다음 장").font(.system(size: 15, weight: .semibold))
                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.terracotta)
            }
            .disabled(isLastChapterOfBible)
            .opacity(isLastChapterOfBible ? 0.3 : 1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.parchment)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.divider).frame(height: 0.5)
        }
    }

    private func goToPreviousChapter() {
        guard !isFirstChapterOfBible else { return }
        verseActionId = nil
        if chapter > 1 {
            chapter -= 1
        } else {
            let prevBook = BibleBook.all[currentBookIndex - 1]
            bookId = prevBook.id
            chapter = chapterCounts[prevBook.id] ?? 1
        }
    }

    private func goToNextChapter() {
        guard !isLastChapterOfBible else { return }
        verseActionId = nil
        if chapter < totalChapters {
            chapter += 1
        } else {
            let nextBook = BibleBook.all[currentBookIndex + 1]
            bookId = nextBook.id
            chapter = 1
        }
    }

    private func loadChapter() async {
        isLoading = true
        errorMessage = nil
        do {
            chapterContent = try await BibleContentService.fetchChapter(bookId: bookId, chapter: chapter, translation: translation)
        } catch {
            chapterContent = nil
            errorMessage = "본문을 불러오지 못했습니다."
        }
        isLoading = false
    }

    private func addBookmark(verse: Int) {
        let bookmark = Bookmark(context: viewContext)
        bookmark.id = UUID()
        bookmark.bookId = bookId
        bookmark.chapter = Int32(chapter)
        bookmark.verse = Int32(verse)
        bookmark.translation = translation.rawValue
        bookmark.reference = verse == 0 ? "\(currentBook.korean) \(chapter)장" : "\(currentBook.korean) \(chapter):\(verse)"
        bookmark.createdAt = Date()
        try? viewContext.save()

        verseActionId = nil
        toastMessage = verse == 0 ? "이 장이 책갈피에 추가되었습니다" : "책갈피에 추가되었습니다"
    }
}
