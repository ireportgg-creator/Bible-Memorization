import SwiftUI
import CoreData

struct CategoryDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let category: Category

    @FetchRequest private var verses: FetchedResults<SavedVerse>

    init(category: Category) {
        self.category = category
        _verses = FetchRequest<SavedVerse>(
            sortDescriptors: [NSSortDescriptor(keyPath: \SavedVerse.savedAt, ascending: false)],
            predicate: NSPredicate(format: "category == %@", category),
            animation: .default
        )
    }

    var body: some View {
        Group {
            if verses.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "text.book.closed")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("저장된 말씀이 없습니다")
                        .foregroundColor(.secondary)
                }
            } else {
                List {
                    ForEach(verses) { verse in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(verse.reference ?? "")
                                    .font(.headline)
                                Spacer()
                                Text(verse.translation ?? "")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(5)
                            }
                            Text(verse.text ?? "")
                                .font(.body)
                                .lineSpacing(4)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 6)
                    }
                    .onDelete(perform: deleteVerses)
                }
            }
        }
        .navigationTitle(category.name ?? "")
        .navigationBarTitleDisplayMode(.large)
    }

    private func deleteVerses(at offsets: IndexSet) {
        offsets.map { verses[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
}
