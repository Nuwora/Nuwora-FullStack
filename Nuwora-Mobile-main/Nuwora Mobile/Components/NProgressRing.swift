import SwiftUI

struct NProgressRing: View {
    var progress: Double
    var lineWidth: CGFloat = 10
    var color: Color = .colorGreen

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.colorBorder.opacity(0.7), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress ring")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

#Preview("NProgressRing") {
    ZStack {
        NSceneBackground()
        NProgressRing(progress: 0.74)
            .frame(width: 120, height: 120)
            .padding()
    }
}
