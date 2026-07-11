import SwiftUI

struct VerseCardView: View {
    let reference: String
    let text: String
    let translationLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(reference)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.darkSurface)
                Spacer()
                Text(translationLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.terracotta)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.terracottaTint)
                    .clipShape(Capsule())
            }
            Rectangle()
                .fill(Color.dividerLight)
                .frame(height: 0.5)
            Text(text)
                .font(.system(size: 15))
                .lineSpacing(4)
                .foregroundColor(.darkSurface.opacity(0.85))
        }
        .padding(16)
        .cardStyle()
    }
}
