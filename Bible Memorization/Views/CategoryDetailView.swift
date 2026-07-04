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
        ZStack {
            Color.parchment.ignoresSafeArea()

            Group {
                if verses.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "text.book.closed")
                            .font(.system(size: 40)).foregroundColor(.mutedBrown)
                        Text("저장된 말씀이 없습니다")
                            .foregroundColor(.mutedBrown)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(verses) { verse in
                                VerseRow(verse: verse)
                            }
                            .onDelete(perform: deleteVerses)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 16)
                    }
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

private struct VerseRow: View {
    let verse: SavedVerse

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(verse.reference ?? "")
                        .font(.subheadline).fontWeight(.semibold)
                    Spacer()
                    HStack(spacing: 6) {
                        if verse.isMemorized {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption).foregroundColor(.terracotta)
                        }
                        Text(verse.translation ?? "")
                            .font(.caption).foregroundColor(.mutedBrown)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color.parchment).cornerRadius(4)
                    }
                }
                Text(verse.text ?? "")
                    .font(.body).lineSpacing(4).foregroundColor(.primary)
            }
        }
        .padding(16)
        .cardStyle()
    }
}
