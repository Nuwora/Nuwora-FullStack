import SwiftUI

struct NCard<Content: View>: View {
    var glow: Color? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card, style: .continuous)
        let accent = glow ?? .clear

        content()
            .padding(DesignTokens.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                shape
                    .fill(Color.colorSurfaceHigh.opacity(0.72))
                    .overlay {
                        shape.fill(accent.opacity(0.04))
                    }
            }
            .overlay {
                shape
                    .stroke(Color.colorBorder, lineWidth: 1)
            }
    }
}

#Preview("NCard") {
    ZStack {
        NSceneBackground()
        NCard(glow: .colorGreen) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Mind Fitness")
                    .foregroundStyle(Color.colorTextPrimary)
                    .font(.headline)
                Text("Liquid glass card style")
                    .foregroundStyle(Color.colorTextSecondary)
                    .font(.subheadline)
            }
        }
        .padding()
    }
}
