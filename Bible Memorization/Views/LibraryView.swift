import SwiftUI
import CoreData

struct LibraryView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    ) private var categories: FetchedResults<Category>

    @State private var searchQuery = ""
    @State private var showSearch = false
    @State private var showAddCategory = false
    @State private var newCategoryName = ""

    private var filtered: [Category] {
        searchQuery.isEmpty ? Array(categories) :
            categories.filter { ($0.name ?? "").localizedCaseInsensitiveContains(searchQuery) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.parchment.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Search bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundColor(.mutedBrown)
                        TextField("컬렉션 검색", text: $searchQuery)
                            .foregroundColor(.primary)
                    }
                    .padding(12)
                    .background(Color.cardSurface)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom, 16)

                    if categories.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "books.vertical")
                                .font(.system(size: 48)).foregroundColor(.mutedBrown)
                            Text("라이브러리가 비어 있습니다")
                                .font(.headline).foregroundColor(.mutedBrown)
                            Text("+ 버튼으로 카테고리를 만들고\n말씀을 추가해 보세요.")
                                .font(.subheadline).foregroundColor(.mutedBrown)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(filtered) { cat in
                                    NavigationLink(destination: CategoryDetailView(category: cat)) {
                                        LibraryCategoryRow(category: cat)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button { showAddCategory = true } label: {
                            Label("새 카테고리", systemImage: "folder.badge.plus")
                        }
                        Button { showSearch = true } label: {
                            Label("말씀 검색/추가", systemImage: "plus.magnifyingglass")
                        }
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
            .sheet(isPresented: $showSearch) {
                SearchView().environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func createCategory() {
        guard !newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let cat = Category(context: viewContext)
        cat.id = UUID()
        cat.name = newCategoryName.trimmingCharacters(in: .whitespaces)
        cat.createdAt = Date()
        try? viewContext.save()
        newCategoryName = ""
    }
}

private struct LibraryCategoryRow: View {
    let category: Category
    @FetchRequest private var verses: FetchedResults<SavedVerse>

    init(category: Category) {
        self.category = category
        _verses = FetchRequest<SavedVerse>(
            sortDescriptors: [],
            predicate: NSPredicate(format: "category == %@ AND translation == %@", category, "개역한글"),
            animation: .none
        )
    }

    private var memorized: Int { verses.filter { $0.isMemorized }.count }
    private var progress: Double { verses.isEmpty ? 0 : Double(memorized) / Double(verses.count) }

    var body: some View {
        HStack(spacing: 16) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.terracotta.opacity(0.2), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.terracotta, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut, value: progress)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(category.name ?? "")
                    .font(.subheadline).fontWeight(.semibold).foregroundColor(.primary)
                Text("\(verses.count)개 구절")
                    .font(.caption).foregroundColor(.mutedBrown)
            }

            Spacer()

            Text("\(Int(progress * 100))%")
                .font(.subheadline).fontWeight(.semibold).foregroundColor(.terracotta)

            Image(systemName: "chevron.right")
                .font(.caption).foregroundColor(.mutedBrown)
        }
        .padding(16)
        .cardStyle()
    }
}
