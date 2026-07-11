import SwiftUI

struct ChapterPickerSheet: View {
    let book: BibleBook
    let totalChapters: Int
    let currentBookId: String
    let currentChapter: Int
    var onSelect: (Int) -> Void
    var onBack: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(1...max(totalChapters, 1), id: \.self) { number in
                        chapterCell(number)
                    }
                }
                .padding(16)
            }
            .background(Color.parchment.ignoresSafeArea())
            .navigationTitle("\(book.korean) · 장 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let onBack {
                    ToolbarItem(placement: .cancellationAction) {
                        Button { onBack() } label: { Image(systemName: "chevron.left") }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                }
            }
        }
    }

    private func chapterCell(_ number: Int) -> some View {
        let isActive = book.id == currentBookId && number == currentChapter
        return Button {
            onSelect(number)
        } label: {
            Text("\(number)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isActive ? .white : .darkSurface)
                .frame(maxWidth: .infinity, minHeight: 56, maxHeight: 56)
                .background(isActive ? Color.terracotta : Color.cardSurface)
                .cornerRadius(10)
                .shadow(color: isActive ? Color.terracotta.opacity(0.3) : Color.black.opacity(0.05),
                        radius: isActive ? 6 : 4, y: isActive ? 2 : 1)
        }
    }
}
