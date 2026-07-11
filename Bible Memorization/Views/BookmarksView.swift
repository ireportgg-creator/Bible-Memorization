import SwiftUI
import CoreData

struct BookmarksView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Bookmark.createdAt, ascending: false)])
    private var bookmarks: FetchedResults<Bookmark>

    let onBack: () -> Void
    let onJump: (String, Int, Int?, Translation) -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            if bookmarks.isEmpty {
                Spacer()
                Text("아직 저장된 책갈피가 없어요")
                    .font(.system(size: 15))
                    .foregroundColor(.mutedBrown)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                List {
                    ForEach(bookmarks) { bookmark in
                        bookmarkRow(bookmark)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
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
            Text("북마크")
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

    private func bookmarkRow(_ bookmark: Bookmark) -> some View {
        Button {
            let translation = Translation(rawValue: bookmark.translation ?? "") ?? .korean
            let verse = bookmark.verse > 0 ? Int(bookmark.verse) : nil
            onJump(bookmark.bookId ?? "", Int(bookmark.chapter), verse, translation)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(bookmark.reference ?? "")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.darkSurface)
                        Text(bookmark.translation ?? "")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.terracotta)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.terracottaTint)
                            .clipShape(Capsule())
                    }
                    Text("\(formattedDate(bookmark.createdAt)) 저장")
                        .font(.system(size: 13))
                        .foregroundColor(.mutedBrown)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(.mutedBrown)
            }
            .padding(16)
            .cardStyle()
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                delete(bookmark)
            } label: {
                Label("삭제", systemImage: "trash")
            }
        }
    }

    private func delete(_ bookmark: Bookmark) {
        viewContext.delete(bookmark)
        try? viewContext.save()
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}
