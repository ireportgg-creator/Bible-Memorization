import SwiftUI
import CoreData

struct FillInBlankView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let deck: [SavedVerse]

    @State private var currentIndex = 0
    @State private var blankedWords: [BlankedWord] = []
    @State private var isRevealed = false
    @State private var score = 0
    @State private var showResult = false

    init(verses: [SavedVerse]) {
        self.deck = verses.shuffled()
    }

    private var current: SavedVerse { deck[currentIndex] }
    private var isLast: Bool { currentIndex >= deck.count - 1 }

    private var displayText: Text {
        blankedWords.indices.reduce(Text("")) { result, i in
            let word = blankedWords[i]
            let sep: Text = i > 0 ? Text(" ") : Text("")
            let w: Text
            if word.isBlank && !isRevealed {
                w = Text(String(repeating: "—", count: max(word.original.count, 2)))
                    .foregroundColor(.terracotta)
            } else {
                w = Text(word.original)
                    .foregroundColor(word.isBlank && isRevealed ? .terracotta : .primary)
            }
            return result + sep + w
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.parchment.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress bar
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color.terracotta)
                            .frame(width: geo.size.width * Double(currentIndex + 1) / Double(deck.count), height: 3)
                            .animation(.easeOut, value: currentIndex)
                    }
                    .frame(height: 3)

                    VStack(spacing: 24) {
                        // Counter + reference
                        HStack {
                            Text("\(currentIndex + 1) / \(deck.count)")
                                .font(.subheadline).foregroundColor(.mutedBrown)
                            Spacer()
                        }
                        .padding(.top, 20)

                        Text(current.reference ?? "")
                            .font(.caption).fontWeight(.semibold)
                            .tracking(1.5).foregroundColor(.terracotta)

                        // Verse card
                        ScrollView {
                            displayText
                                .font(.title3).lineSpacing(10)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(24)
                        }
                        .frame(maxHeight: 280)
                        .cardStyle()

                        if !isRevealed {
                            Button("모두 보기") { isRevealed = true }
                                .font(.subheadline)
                                .foregroundColor(.mutedBrown)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.mutedBrown.opacity(0.4), lineWidth: 1)
                                )
                        }

                        Spacer()

                        if isRevealed {
                            HStack(spacing: 12) {
                                Button {
                                    advance(memorized: false)
                                } label: {
                                    Text("다시")
                                        .font(.headline).frame(maxWidth: .infinity).padding()
                                        .background(Color.cardSurface)
                                        .cornerRadius(14)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color.terracotta.opacity(0.3), lineWidth: 1)
                                        )
                                }
                                .foregroundColor(.primary)

                                Button {
                                    advance(memorized: true)
                                } label: {
                                    Text("확인")
                                        .font(.headline).frame(maxWidth: .infinity).padding()
                                        .background(Color.terracotta)
                                        .cornerRadius(14)
                                        .foregroundColor(.white)
                                }
                            }
                        }

                        Color.clear.frame(height: 20)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("종료") { dismiss() }
                        .foregroundColor(.mutedBrown)
                }
            }
            .onAppear { loadCard() }
            .fullScreenCover(isPresented: $showResult) {
                StudyResultView(score: score, total: deck.count) { dismiss() }
            }
        }
    }

    private func loadCard() {
        let text = current.text ?? ""
        let raw = text.components(separatedBy: " ")
        let blankSet = Set(raw.indices.shuffled().prefix(max(raw.count / 2, 1)))
        blankedWords = raw.enumerated().map { i, w in
            BlankedWord(original: w, isBlank: blankSet.contains(i))
        }
        isRevealed = false
    }

    private func advance(memorized: Bool) {
        if memorized {
            current.isMemorized = true
            score += 1
            try? viewContext.save()
        }
        if isLast {
            showResult = true
        } else {
            currentIndex += 1
            loadCard()
        }
    }
}

struct BlankedWord: Identifiable {
    let id = UUID()
    let original: String
    let isBlank: Bool
}
