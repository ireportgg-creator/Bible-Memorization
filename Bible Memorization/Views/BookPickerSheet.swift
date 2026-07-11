import SwiftUI

struct BookPickerSheet: View {
    @Binding var selectedBook: BibleBook
    var onSelect: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private static let oldTestamentCount = 39

    private var oldTestament: [BibleBook] { Array(BibleBook.all.prefix(Self.oldTestamentCount)) }
    private var newTestament: [BibleBook] { Array(BibleBook.all.suffix(from: Self.oldTestamentCount)) }

    private func filtered(_ books: [BibleBook]) -> [BibleBook] {
        query.isEmpty ? books : books.filter { $0.korean.contains(query) }
    }

    var body: some View {
        NavigationView {
            List {
                let ot = filtered(oldTestament)
                let nt = filtered(newTestament)

                if !ot.isEmpty {
                    Section("구약") {
                        ForEach(ot) { book in bookRow(book) }
                    }
                }
                if !nt.isEmpty {
                    Section("신약") {
                        ForEach(nt) { book in bookRow(book) }
                    }
                }
            }
            .searchable(text: $query,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "책 이름 검색")
            .navigationTitle("책 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
            }
        }
    }

    private func bookRow(_ book: BibleBook) -> some View {
        Button {
            selectedBook = book
            if let onSelect { onSelect() } else { dismiss() }
        } label: {
            HStack {
                Text(book.korean).foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundColor(.mutedBrown)
            }
        }
    }
}
