import SwiftUI

struct NToast: View {
    let message: ToastMessage

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large, style: .continuous)

        HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(iconColor)

            Text(message.text)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.colorTextPrimary)
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background {
            shape
                .fill(Color.colorSurfaceHigh.opacity(0.72))
                .background(.ultraThinMaterial, in: shape)
                .overlay {
                    shape.fill(DesignTokens.Gradients.glass).opacity(0.2)
                }
        }
        .overlay {
            shape
                .stroke(borderColor, lineWidth: 1)
        }
        .shadow(color: iconColor.opacity(0.22), radius: 18, x: 0, y: 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message.text)
    }

    private var iconColor: Color {
        switch message.kind {
        case .success: return .colorGreen
        case .warning: return .colorAmber
        case .info: return .colorTeal
        }
    }

    private var borderColor: Color {
        switch message.kind {
        case .success: return .colorGreen.opacity(0.35)
        case .warning: return .colorAmber.opacity(0.4)
        case .info: return .colorTeal.opacity(0.35)
        }
    }

    private var icon: String {
        switch message.kind {
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
}

#Preview("NToast") {
    ZStack {
        NSceneBackground()
        VStack {
            Spacer()
            NToast(message: ToastMessage(text: "You're offline - using cached data", kind: .warning))
                .padding()
        }
    }
}
