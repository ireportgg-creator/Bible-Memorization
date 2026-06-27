import SwiftUI
import CoreData

struct SaveVerseSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let verses: [(verse: VerseData, translation: Translation)]
    let categories: [Category]
    let onSave: (Category) -> Void

    @State private var selectedCategory: Category?
    @State private var showAddCategory = false
    @State private var newCategoryName = ""
    @State private var saved = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // 병행 구절 미리보기
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(verses.indices, id: \.self) { i in
                            let item = verses[i]
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(item.verse.reference)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(item.translation.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(4)
                                }
                                Text(item.verse.cleanedContent)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(3)
                            }
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: 220)

                Text("카테고리 선택")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 4)

                List {
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
                    guard !saved, let category = selectedCategory else { return }
                    saved = true
                    onSave(category)
                } label: {
                    Text("저장")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedCategory == nil || saved)
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
