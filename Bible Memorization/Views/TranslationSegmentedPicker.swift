import SwiftUI

struct TranslationSegmentedPicker: View {
    @Binding var selection: Translation

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Translation.allCases) { t in
                let isActive = t == selection
                Button {
                    selection = t
                } label: {
                    Text(t.rawValue)
                        .font(.system(size: 14, weight: isActive ? .semibold : .medium))
                        .foregroundColor(isActive ? .terracotta : .mutedBrown)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(isActive ? Color.cardSurface : Color.clear)
                        .cornerRadius(8)
                        .shadow(color: isActive ? Color.black.opacity(0.1) : .clear, radius: 4, y: 1)
                }
            }
        }
        .padding(3)
        .background(Color.segmentTrackBg)
        .cornerRadius(10)
    }
}
