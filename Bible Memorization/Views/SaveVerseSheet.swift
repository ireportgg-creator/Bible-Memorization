import SwiftUI
import CoreData

struct SaveVerseSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let verse: VerseData
    let translation: String
    let categories: [Category]
    let onSave: (VerseData, Category) -> Void

    @State private var selectedCategory: Category?
    @State private var showAddCategory = false
    @State private var newCategoryName = ""

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // 구절 미리보기
                VStack(alignment: .leading, spacing: 8) {
                    Text(verse.reference)
                        .font(.headline)
                    Text(verse.cleanedContent)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()

                Text("카테고리 선택")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 4)

                List(selection: $selectedCategory) {
                    ForEach(categories) { category in
                        HStack {
                            Text(category.name ?? "")
                            Spacer()
                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { selectedCategory = category }
                    }

                    Button {
                        showAddCategory = true
                    } label: {
                        Label("새 카테고리 만들기", systemImage: "plus.circle")
                    }
                }
                .listStyle(.insetGrouped)

                Button {
                    if let category = selectedCategory {
                        onSave(verse, category)
                    }
                } label: {
                    Text("저장")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedCategory == nil)
                .padding()
            }
            .navigationTitle("저장하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
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
        selectedCategory = category
        newCategoryName = ""
    }
}
