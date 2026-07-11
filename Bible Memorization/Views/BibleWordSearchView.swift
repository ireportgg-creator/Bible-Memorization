import SwiftUI

struct BibleWordSearchView: View {
    @State private var query = ""
    @State private var translation: Translation = .korean
    @State private var results: [SearchResultItem]?
    @State private var isLoading = false

    let onBack: () -> Void
    let onJump: (String, Int, Int?, Translation) -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            inputArea
            resultsArea
        }
        .parchmentBackground()
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.terracotta)
            }
            Text("단어·인물 검색")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(.darkSurface)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 14)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.divider).frame(height: 0.5)
        }
    }

    private var inputArea: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundColor(.mutedBrown)
                TextField("예: 사랑, 다윗, 믿음", text: $query)
                    .foregroundColor(.darkSurface)
                    .submitLabel(.search)
                    .onSubmit { Task { await runSearch() } }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.cardSurface)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)

            TranslationSegmentedPicker(selection: $translation)

            Button {
                Task { await runSearch() }
            } label: {
                Text("검색")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.parchment)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.terracotta)
                    .cornerRadius(10)
            }
            .disabled(query.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
        }
        .padding(16)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.divider).frame(height: 0.5)
        }
    }

    private var resultsArea: some View {
        ScrollView {
            VStack(spacing: 12) {
                if isLoading {
                    ProgressView().padding(.top, 40)
                } else if let results {
                    if results.isEmpty {
                        Text("'\(query)'에 대한 결과가 없어요")
                            .font(.system(size: 15))
                            .foregroundColor(.mutedBrown)
                            .padding(.top, 60)
                    } else {
                        ForEach(results) { result in
                            Button {
                                onJump(result.bookId, result.chapter, result.verse, translation)
                            } label: {
                                VerseCardView(reference: result.reference, text: result.text, translationLabel: translation.rawValue)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } else {
                    Text("검색어를 입력하고 검색 버튼을 눌러보세요")
                        .font(.system(size: 15))
                        .foregroundColor(.mutedBrown)
                        .padding(.top, 60)
                }
            }
            .padding(16)
        }
    }

    private func runSearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        isLoading = true
        results = (try? await BibleContentService.search(query: trimmed, translation: translation)) ?? []
        isLoading = false
    }
}
