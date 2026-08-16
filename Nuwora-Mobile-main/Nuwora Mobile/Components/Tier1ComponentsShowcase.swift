import SwiftUI

private struct Tier1ComponentsShowcase: View {
    var body: some View {
        ZStack {
            NSceneBackground()
            ScrollView {
                VStack(spacing: 16) {
                    NCard(glow: .colorGreen) { Text("Card").foregroundStyle(Color.colorTextPrimary) }
                    NButton(title: "Primary") {}
                    NProgressRing(progress: 0.66).frame(width: 80, height: 80)
                    NScoreGauge(score: 73).frame(width: 120, height: 120)
                    NToast(message: ToastMessage(text: "Offline mode active", kind: .warning))
                    NSkeletonView().frame(height: 80)
                }
                .padding()
            }
        }
    }
}

#Preview("Tier1 Dark") {
    Tier1ComponentsShowcase()
        .preferredColorScheme(.dark)
}

#Preview("Tier1 Light") {
    Tier1ComponentsShowcase()
        .preferredColorScheme(.light)
}
