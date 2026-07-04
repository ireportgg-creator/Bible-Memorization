import SwiftUI
import CoreData

struct QuizSessionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let deck: [SavedVerse]

    @State private var currentIndex = 0
    @State private var choices: [SavedVerse] = []
    @State private var selectedID: NSManagedObjectID?
    @State private var score = 0
    @State private var showResult = false

    init(verses: [SavedVerse]) {
        self.deck = verses.shuffled()
    }

    private var current: SavedVerse { deck[currentIndex] }
    private var isAnswered: Bool { selectedID != nil }
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

                    VStack(spacing: 20) {
                        HStack {
                            Text("\(currentIndex + 1) / \(deck.count)")
                                .font(.subheadline).foregroundColor(.mutedBrown)
                            Spacer()
                        }
                        .padding(.top, 20)

                        // Verse text card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("이 구절의 번호는?")
                                .font(.caption).fontWeight(.semibold)
                                .tracking(1).foregroundColor(.terracotta)
                            Text(current.text ?? "")
                                .font(.body).lineSpacing(6)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .cardStyle()

                        // Choices
                        VStack(spacing: 10) {
                            ForEach(choices, id: \.objectID) { choice in
                                QuizChoiceButton(
                                    label: choice.reference ?? "",
                                    state: buttonState(for: choice),
                                    action: { select(choice) }
                                )
                                .disabled(isAnswered)
                            }
                        }

                        Spacer()
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
            .onAppear { loadChoices() }
            .fullScreenCover(isPresented: $showResult) {
                StudyResultView(score: score, total: deck.count) { dismiss() }
            }
        }
    }

    private func buttonState(for choice: SavedVerse) -> QuizChoiceButton.State {
        guard let selected = selectedID else { return .normal }
        if choice.objectID == current.objectID { return .correct }
        if choice.objectID == selected { return .wrong }
        return .normal
    }

    private func select(_ choice: SavedVerse) {
        selectedID = choice.objectID
        if choice.objectID == current.objectID {
            current.isMemorized = true
            score += 1
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { advance() }
    }

    private func advance() {
        if isLast { showResult = true }
        else {
            currentIndex += 1
            selectedID = nil
            loadChoices()
        }
    }

    private func loadChoices() {
        let candidates = deck.filter { $0.objectID != current.objectID }
        var seen = Set<String>()
        var unique: [SavedVerse] = []
        for c in candidates {
            guard let t = c.text, !seen.contains(t) else { continue }
            seen.insert(t)
            unique.append(c)
        }
        choices = ([current] + Array(unique.shuffled().prefix(3))).shuffled()
    }
}

private struct QuizChoiceButton: View {
    enum State { case normal, correct, wrong }

    let label: String
    let state: State
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label).font(.body).fontWeight(.medium)
                Spacer()
                if state == .correct {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                } else if state == .wrong {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(bgColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: state == .normal ? 0 : 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var bgColor: Color {
        switch state {
        case .normal:  return Color.cardSurface
        case .correct: return Color.green.opacity(0.1)
        case .wrong:   return Color.red.opacity(0.1)
        }
    }

    private var borderColor: Color {
        switch state {
        case .normal:  return .clear
        case .correct: return .green
        case .wrong:   return .red
        }
    }
}
