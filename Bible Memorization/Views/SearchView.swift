import SwiftUI
import CoreData

struct SearchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    ) private var categories: FetchedResults<Category>

    @State private var selectedTranslation = Translation.korean
    @State private var selectedBook = BibleBook.all[0]
    @State private var chapterText = ""
    @State private var verseText = ""
    @State private var fetchedVerse: VerseData?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSaveSheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    translationPicker
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
                    } else if let verse = fetchedVerse {
                        verseCard(verse)
                        saveButton
                    }
                }
                .padding(.vertical, 20)
            }
            .navigationTitle("성경 검색")
            .sheet(isPresented: $showSaveSheet) {
                SaveVerseSheet(
                    verse: fetchedVerse!,
                    translation: selectedTranslation.rawValue,
                    categories: Array(categories),
                    onSave: saveVerse(verse:to:)
                )
            }
        }
    }

    // MARK: - Sub-views

    private var translationPicker: some View {
        Picker("번역", selection: $selectedTranslation) {
            ForEach(Translation.allCases) { t in
                Text(t.rawValue).tag(t)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    private var bookSelector: some View {
        Menu {
            ForEach(BibleBook.all) { book in
                Button(selectedTranslation == .korean ? book.korean : book.english) {
                    selectedBook = book
                }
            }
        } label: {
            HStack {
                Text(selectedTranslation == .korean ? selectedBook.korean : selectedBook.english)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }

    private var referenceInputs: some View {
        HStack(spacing: 16) {
            HStack {
                TextField("장", text: $chapterText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                Text("장")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)

            HStack {
                TextField("절", text: $verseText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                Text("절")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }

    private var searchButton: some View {
        Button {
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

    private func verseCard(_ verse: VerseData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(verse.reference)
                    .font(.headline)
                Spacer()
                Text(selectedTranslation.rawValue)
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
            showSaveSheet = true
        } label: {
            Label("저장하기", systemImage: "bookmark")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.bordered)
        .padding(.horizontal)
    }

    // MARK: - Logic

    private func search() async {
        guard let chapter = Int(chapterText), let verse = Int(verseText),
              chapter > 0, verse > 0 else {
            errorMessage = "장/절을 올바르게 입력해 주세요."
            return
        }

        isLoading = true
        errorMessage = nil
        fetchedVerse = nil

        do {
            if selectedTranslation == .korean {
                fetchedVerse = try await KoreanBibleService.shared.fetchVerse(
                    bookId: selectedBook.id,
                    chapter: chapter,
                    verse: verse
                )
            } else {
                fetchedVerse = try await BibleAPIService.shared.fetchVerse(
                    bibleId: selectedTranslation.bibleId,
                    bookId: selectedBook.id,
                    chapter: chapter,
                    verse: verse
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func saveVerse(verse: VerseData, to category: Category) {
        let saved = SavedVerse(context: viewContext)
        saved.id = UUID()
        saved.reference = verse.reference
        saved.text = verse.cleanedContent
        saved.translation = selectedTranslation.rawValue
        saved.savedAt = Date()
        saved.category = category
        try? viewContext.save()
        showSaveSheet = false
    }
}
