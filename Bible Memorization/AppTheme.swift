import SwiftUI

extension Color {
    static let parchment   = Color(red: 0.97, green: 0.95, blue: 0.93)
    static let terracotta  = Color(red: 0.71, green: 0.41, blue: 0.24)
    static let cardSurface = Color.white
    static let darkSurface = Color(red: 0.11, green: 0.10, blue: 0.09)
    static let mutedBrown  = Color(red: 0.55, green: 0.48, blue: 0.42)

    static let divider        = Color(red: 140/255, green: 122/255, blue: 107/255).opacity(0.18)
    static let dividerLight   = Color(red: 140/255, green: 122/255, blue: 107/255).opacity(0.14)
    static let terracottaTint = Color(red: 180/255, green: 104/255, blue: 45/255).opacity(0.10)
    static let segmentTrackBg = Color(red: 140/255, green: 122/255, blue: 107/255).opacity(0.12)
    static let deleteRed      = Color(red: 180/255, green: 67/255, blue: 45/255)
    static let highlightTint  = Color(red: 180/255, green: 104/255, blue: 45/255).opacity(0.14)
}

extension View {
    func cardStyle(radius: CGFloat = 16) -> some View {
        self
            .background(Color.cardSurface)
            .cornerRadius(radius)
            .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
    }

    func parchmentBackground() -> some View {
        self.background(Color.parchment.ignoresSafeArea())
    }
}
