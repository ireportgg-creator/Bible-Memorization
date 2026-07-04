import SwiftUI
import CoreData

struct StudyModePickerView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .none
    ) private var categories: FetchedResults<Category>

    @FetchRequest(
        sortDescriptors: [],
        animation: .none
    ) private var allVerses: FetchedResults<SavedVerse>

    @State private var selectedCategory: Category? = nil
    @State private var selectedTranslation: Translation = .korean
    @State private var showFlashcard = false
    @State private var showQuiz = false
    @State private var showFillInBlank = false

    private var filteredVerses: [SavedVerse] {
        let base: [SavedVerse] = selectedCategory.map { cat in
            allVerses.filter { $0.category == cat }
        } ?? Array(allVerses)
        return base.filter { $0.translation == selectedTranslation.rawValue }
    }

    private var canFlashcard: Bool { filteredVerses.count >= 1 }
    private var canQuiz: Bool { filteredVerses.count >= 4 }

    var body: some View {
        NavigationView {
            ZStack {
                Color.parchment.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Category picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CATEGORY")
                                .font(.caption).fontWeight(.semibold)
                                .tracking(1.5).foregroundColor(.mutedBrown)
                            Picker("카테고리", selection: $selectedCategory) {
                                Text("전체").tag(nil as Category?)
                                ForEach(categories) { cat in
                                    Text(cat.name ?? "").tag(cat as Category?)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .cardStyle()
                        }

                        // Translation picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("TRANSLATION")
                                .font(.caption).fontWeight(.semibold)
                                .tracking(1.5).foregroundColor(.mutedBrown)
                            Picker("번역본", selection: $selectedTranslation) {
                                ForEach(Translation.allCases) { t in
                                    Text(t.rawValue).tag(t)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        // Verse count
                        if filteredVerses.isEmpty {
                            Text("'\(selectedTranslation.rawValue)'로 저장된 말씀이 없습니다")
                                .font(.callout).foregroundColor(.mutedBrown)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        } else {
                            Text("\(filteredVerses.count)개 구절")
                                .font(.callout).foregroundColor(.mutedBrown)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }

                        // Mode buttons
                        VStack(spacing: 12) {
                            ModeButton(
                                icon: "rectangle.on.rectangle",
                                title: "플래시카드",
                                subtitle: "카드를 탭해 본문 확인",
                                disabled: !canFlashcard
                            ) { showFlashcard = true }

                            ModeButton(
                                icon: "text.word.spacing",
                                title: "빈칸 채우기",
                                subtitle: "빈칸을 채우며 암기",
                                disabled: !canFlashcard
                            ) { showFillInBlank = true }

                            VStack(spacing: 4) {
                                ModeButton(
                                    icon: "checkmark.circle",
                                    title: "퀴즈",
                                    subtitle: "4지선다로 실력 확인",
                                    disabled: !canQuiz
                                ) { showQuiz = true }

                                if !canQuiz && canFlashcard {
                                    Text("퀴즈는 4개 이상 필요합니다 (현재 \(filteredVerses.count)개)")
                                        .font(.caption).foregroundColor(.mutedBrown)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Practice")
            .fullScreenCover(isPresented: $showFlashcard) {
                FlashcardSessionView(verses: filteredVerses)
                    .environment(\.managedObjectContext, viewContext)
            }
            .fullScreenCover(isPresented: $showQuiz) {
                QuizSessionView(verses: filteredVerses)
                    .environment(\.managedObjectContext, viewContext)
            }
            .fullScreenCover(isPresented: $showFillInBlank) {
                FillInBlankView(verses: filteredVerses)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

private struct ModeButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(disabled ? .mutedBrown : .terracotta)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(disabled ? .mutedBrown : .primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.mutedBrown)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption).foregroundColor(.mutedBrown)
            }
            .padding(18)
            .cardStyle()
        }
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1)
    }
}
