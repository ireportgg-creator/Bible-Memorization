import SwiftUI
import CoreData

struct SearchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    ) private var categories: FetchedResults<Category>

    @State private var selectedBook = BibleBook.all[0]
    @State private var showBookPicker = false
    @State private var chapterText = ""
    @State private var verseText = ""
    @State private var endChapterText = ""
    @State private var endVerseText = ""
    @State private var fetchedVerses: [(verse: VerseData, translation: Translation)] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSaveSheet = false
    @State private var showDuplicateAlert = false
    @State private var didSave = false

    private enum Field { case chapter, verse, endChapter, endVerse }
    @FocusState private var focusedField: Field?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    bookSelector
                    referenceInputs
                    searchButton

                    if isLoading {
                        ProgressView().padding()
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    } else if !fetchedVerses.isEmpty {
                        ForEach(fetchedVerses.indices, id: \.self) { i in
                            verseCard(fetchedVerses[i].verse, translation: fetchedVerses[i].translation)
                        }
                        saveButton
                    }
                }
                .padding(.vertical, 20)
            }
            .scrollDismissesKeyboard(.immediately)
            .onChange(of: focusedField) { newField in
                switch newField {
                case .chapter:    chapterText = ""
                case .verse:      verseText = ""
                case .endChapter: endChapterText = ""
                case .endVerse:   endVerseText = ""
                case .none:       break
                }
            }
            .navigationTitle("성경 검색")
            .toolbar {
                if !fetchedVerses.isEmpty || !chapterText.isEmpty || !verseText.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button("초기화") {
                            fetchedVerses = []
                            chapterText = ""
                            verseText = ""
                            endChapterText = ""
                            endVerseText = ""
                            errorMessage = nil
                            focusedField = nil
                        }
                    }
                }
            }
            .sheet(isPresented: $showSaveSheet, onDismiss: {
                if didSave {
                    fetchedVerses = []
                    chapterText = ""
                    verseText = ""
                    endChapterText = ""
                    endVerseText = ""
                    focusedField = nil
                    didSave = false
                }
            }) {
                SaveVerseSheet(
                    verses: fetchedVerses,
                    categories: Array(categories),
                    onSave: saveVerses(to:)
                )
            }
        }
    }

    // MARK: - Sub-views

    private var bookSelector: some View {
        Button { showBookPicker = true } label: {
            HStack {
                Text(selectedBook.korean)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showBookPicker) {
            BookPickerSheet(selectedBook: $selectedBook)
        }
    }

    private var referenceInputs: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                HStack {
                    TextField("장", text: $chapterText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .focused($focusedField, equals: .chapter)
                    Text("장").foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

                HStack {
                    TextField("절", text: $verseText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .focused($focusedField, equals: .verse)
                    Text("절").foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }

            HStack(spacing: 8) {
                Text("~")
                    .foregroundColor(.secondary)
                    .frame(width: 16)

                HStack {
                    TextField("장", text: $endChapterText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .focused($focusedField, equals: .endChapter)
                    Text("장").foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

                HStack {
                    TextField("절", text: $endVerseText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .focused($focusedField, equals: .endVerse)
                    Text("절").foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }

    private var searchButton: some View {
        Button {
            focusedField = nil
            Task { await search() }
        } label: {
            Text("검색")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .disabled(chapterText.isEmpty || verseText.isEmpty || isLoading)
        .padding(.horizontal)
    }

    private func verseCard(_ verse: VerseData, translation: Translation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(verse.reference)
                    .font(.headline)
                Spacer()
                Text(translation.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(6)
            }
            Divider()
            Text(verse.cleanedContent)
                .font(.body)
                .lineSpacing(6)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(14)
        .padding(.horizontal)
    }

    private var saveButton: some View {
        Button {
            if isAlreadySaved() {
                showDuplicateAlert = true
            } else {
                showSaveSheet = true
            }
        } label: {
            Label("저장하기", systemImage: "bookmark")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.bordered)
        .padding(.horizontal)
        .alert("저장된 말씀입니다.", isPresented: $showDuplicateAlert) {
            Button("확인", role: .cancel) {}
        }
    }

    private func isAlreadySaved() -> Bool {
        guard let first = fetchedVerses.first else { return false }
        let request = SavedVerse.fetchRequest()
        request.predicate = NSPredicate(format: "reference == %@ AND translation == %@",
                                        first.verse.reference, first.translation.rawValue)
        request.fetchLimit = 1
        return (try? viewContext.count(for: request)) ?? 0 > 0
    }

    // MARK: - Logic

    private func search() async {
        guard let chapter = Int(chapterText), let verse = Int(verseText),
              chapter > 0, verse > 0 else {
            errorMessage = "장/절을 올바르게 입력해 주세요."
            return
        }

        let isRange = !endVerseText.isEmpty
        let endChapter = endChapterText.isEmpty ? chapter : (Int(endChapterText) ?? 0)
        let endVerse   = Int(endVerseText) ?? 0

        if isRange {
            guard endChapter > 0, endVerse > 0 else {
                errorMessage = "끝 절을 올바르게 입력해 주세요."
                return
            }
            guard endChapter > chapter || (endChapter == chapter && endVerse > verse) else {
                errorMessage = "끝 절이 시작 절보다 뒤여야 합니다."
                return
            }
        }

        isLoading = true
        errorMessage = nil
        fetchedVerses = []

        let bookId = selectedBook.id
        var results: [(verse: VerseData, translation: Translation)] = []

        if isRange {
            async let koreanFetch  = KoreanBibleService.shared.fetchVerseRange(bookId: bookId, startChapter: chapter, startVerse: verse, endChapter: endChapter, endVerse: endVerse)
            async let nivFetch     = BibleAPIService.shared.fetchPassage(bibleId: Translation.niv.bibleId, bookId: bookId, startChapter: chapter, startVerse: verse, endChapter: endChapter, endVerse: endVerse)
            async let messageFetch = BibleAPIService.shared.fetchPassage(bibleId: Translation.message.bibleId, bookId: bookId, startChapter: chapter, startVerse: verse, endChapter: endChapter, endVerse: endVerse)

            if let v = try? await koreanFetch  { results.append((v, .korean)) }
            if let v = try? await nivFetch     { results.append((v, .niv)) }
            if let v = try? await messageFetch { results.append((v, .message)) }
        } else {
            async let koreanFetch  = KoreanBibleService.shared.fetchVerse(bookId: bookId, chapter: chapter, verse: verse)
            async let nivFetch     = BibleAPIService.shared.fetchVerse(bibleId: Translation.niv.bibleId, bookId: bookId, chapter: chapter, verse: verse)
            async let messageFetch = BibleAPIService.shared.fetchVerse(bibleId: Translation.message.bibleId, bookId: bookId, chapter: chapter, verse: verse)

            if let v = try? await koreanFetch  { results.append((v, .korean)) }
            if let v = try? await nivFetch     { results.append((v, .niv)) }
            if let v = try? await messageFetch { results.append((v, .message)) }
        }

        fetchedVerses = results
        if results.isEmpty {
            errorMessage = "구절을 불러오지 못했습니다. 장/절 번호를 확인해 주세요."
        }

        isLoading = false
    }

    private func saveVerses(to category: Category) {
        let now = Date()
        for (index, (verse, translation)) in fetchedVerses.enumerated() {
            let saved = SavedVerse(context: viewContext)
            saved.id = UUID()
            saved.reference = verse.reference
            saved.text = verse.cleanedContent
            saved.translation = translation.rawValue
            saved.savedAt = now.addingTimeInterval(Double(-index) * 0.001)
            saved.category = category
        }
        try? viewContext.save()
        didSave = true
        showSaveSheet = false
    }
}

private struct BookPickerSheet: View {
    @Binding var selectedBook: BibleBook
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    var filtered: [BibleBook] {
        query.isEmpty ? BibleBook.all : BibleBook.all.filter { $0.korean.hasPrefix(query) }
    }

    var body: some View {
        NavigationView {
            List(filtered) { book in
                Button {
                    selectedBook = book
                    dismiss()
                } label: {
                    Text(book.korean)
                        .foregroundColor(.primary)
                }
            }
            .searchable(text: $query,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "성경 검색")
            .navigationTitle("책 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
            }
        }
    }
}
