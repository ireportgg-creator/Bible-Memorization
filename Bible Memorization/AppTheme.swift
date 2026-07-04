import SwiftUI

extension Color {
    static let parchment   = Color(red: 0.97, green: 0.95, blue: 0.93)
    static let terracotta  = Color(red: 0.71, green: 0.41, blue: 0.24)
    static let cardSurface = Color.white
    static let darkSurface = Color(red: 0.11, green: 0.10, blue: 0.09)
    static let mutedBrown  = Color(red: 0.55, green: 0.48, blue: 0.42)
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
