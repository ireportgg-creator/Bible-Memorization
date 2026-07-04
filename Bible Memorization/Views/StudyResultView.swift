import SwiftUI

struct StudyResultView: View {
    let score: Int
    let total: Int
    let onDismiss: () -> Void

    private var isPerfect: Bool { score == total }

    var body: some View {
        ZStack {
            Color.parchment.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Image(systemName: isPerfect ? "star.fill" : "checkmark.circle")
                    .font(.system(size: 64))
                    .foregroundColor(isPerfect ? .yellow : .terracotta)

                VStack(spacing: 8) {
                    Text("세션 완료!")
                        .font(.title2).fontWeight(.bold)
                    Text("\(total)개 중 \(score)개 완료")
                        .font(.title3).foregroundColor(.mutedBrown)
                }

                if isPerfect {
                    Text("완벽합니다!")
                        .font(.headline).foregroundColor(.terracotta)
                }

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Text("완료")
                        .font(.headline).frame(maxWidth: .infinity).padding()
                        .background(Color.terracotta).cornerRadius(14)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)

                Color.clear.frame(height: 20)
            }
        }
    }
}
