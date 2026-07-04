import SwiftUI
import CoreData

struct FlashcardSessionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let deck: [SavedVerse]

    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var score = 0
    @State private var showResult = false

    init(verses: [SavedVerse]) {
        self.deck = verses.shuffled()
    }

    private var current: SavedVerse { deck[currentIndex] }
    private var isLast: Bool { currentIndex >= deck.count - 1 }

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
                        HStack {
                            Text("\(currentIndex + 1) / \(deck.count)")
                                .font(.subheadline).foregroundColor(.mutedBrown)
                            Spacer()
                            Text(current.translation ?? "")
                                .font(.caption).foregroundColor(.mutedBrown)
                        }
                        .padding(.top, 20)

                        Spacer()

                        FlashCardView(
                            front: current.reference ?? "",
                            back: current.text ?? "",
                            isFlipped: $isFlipped
                        )

                        if !isFlipped {
                            Text("탭하여 본문 확인")
                                .font(.caption).foregroundColor(.mutedBrown)
                        }

                        Spacer()

                        if isFlipped {
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
            .fullScreenCover(isPresented: $showResult) {
                StudyResultView(score: score, total: deck.count) { dismiss() }
            }
        }
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
            isFlipped = false
            currentIndex += 1
        }
    }
}

private struct FlashCardView: View {
    let front: String
    let back: String
    @Binding var isFlipped: Bool

    var body: some View {
        ZStack {
            CardFace(text: front, label: "구절 번호", isFront: true)
                .opacity(isFlipped ? 0 : 1)
            CardFace(text: back, label: "본문", isFront: false)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isFlipped)
        .onTapGesture { isFlipped.toggle() }
        .padding(.horizontal)
    }
}

private struct CardFace: View {
    let text: String
    let label: String
    let isFront: Bool

    var body: some View {
        VStack(spacing: 12) {
            Text(label)
                .font(.caption).fontWeight(.semibold)
                .tracking(1.5).foregroundColor(.terracotta)
            Spacer()
            Text(text)
                .font(isFront ? .title2 : .body)
                .fontWeight(isFront ? .bold : .regular)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
            Spacer()
        }
        .padding(28)
        .frame(maxWidth: .infinity, minHeight: 260)
        .cardStyle()
    }
}
