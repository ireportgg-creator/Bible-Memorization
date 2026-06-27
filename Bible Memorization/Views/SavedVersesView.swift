import SwiftUI
import CoreData

struct SavedVersesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    ) private var categories: FetchedResults<Category>

    @State private var showAddCategory = false
    @State private var newCategoryName = ""

    var body: some View {
        NavigationView {
            Group {
                if categories.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("저장된 말씀이 없습니다")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("먼저 카테고리를 만들고\n검색 탭에서 말씀을 저장해 보세요.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    List {
                        ForEach(categories) { category in
                            NavigationLink(destination: CategoryDetailView(category: category)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(category.name ?? "")
                                            .font(.headline)
                                        Text("\(category.verses?.count ?? 0)개")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteCategories)
                    }
                }
            }
            .navigationTitle("저장된 말씀")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("새 카테고리", isPresented: $showAddCategory) {
                TextField("카테고리 이름", text: $newCategoryName)
                Button("만들기") { createCategory() }
                Button("취소", role: .cancel) { newCategoryName = "" }
            }
        }
    }

    private func createCategory() {
        guard !newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let category = Category(context: viewContext)
        category.id = UUID()
        category.name = newCategoryName.trimmingCharacters(in: .whitespaces)
        category.createdAt = Date()
        try? viewContext.save()
        newCategoryName = ""
    }

    private func deleteCategories(at offsets: IndexSet) {
        offsets.map { categories[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
}
