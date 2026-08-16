import SwiftUI

struct NScoreGauge: View {
    var score: Int
    @State private var animatedProgress: Double = 0
    @State private var didAnimate = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.colorSurface.opacity(0.8))
            NProgressRing(progress: animatedProgress, lineWidth: 12, color: .colorGreen)
            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.nNumber)
                    .foregroundStyle(Color.colorTextPrimary)
                Text("Mind Score")
                    .font(.caption)
                    .foregroundStyle(Color.colorTextSecondary)
            }
        }
        .onAppear {
            if didAnimate == false {
                withAnimation(.nuworaGaugeSpring) {
                    animatedProgress = Double(score) / 100
                }
                didAnimate = true
            }
        }
        .onChange(of: score) { _, newScore in
            withAnimation(.nuworaGaugeSpring) {
                animatedProgress = Double(newScore) / 100
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Mind Fitness Score")
        .accessibilityValue("\(score) out of 100")
    }
}

#Preview("NScoreGauge") {
    ZStack {
        NSceneBackground()
        NScoreGauge(score: 78)
            .frame(width: 180, height: 180)
            .padding()
    }
}
