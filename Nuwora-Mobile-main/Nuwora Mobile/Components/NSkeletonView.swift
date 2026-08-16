import SwiftUI

struct NSkeletonView: View {
    @State private var shimmer = false

    var body: some View {
        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large, style: .continuous)
            .fill(Color.colorSurfaceHigh.opacity(0.8))
            .overlay {
                LinearGradient(
                    colors: [Color.clear, Color.textPrimary.opacity(0.2), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: shimmer ? 280 : -280)
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: shimmer)
            }
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large, style: .continuous)
                    .stroke(Color.colorBorder, lineWidth: 1)
            }
            .onAppear {
                shimmer = true
            }
            .accessibilityHidden(true)
    }
}

#Preview("NSkeletonView") {
    ZStack {
        NSceneBackground()
        VStack(spacing: 12) {
            NSkeletonView().frame(height: 120)
            NSkeletonView().frame(height: 60)
        }
        .padding()
    }
}
