import SwiftUI

enum NButtonStyle {
    case primary
    case secondary
    case ghost
}

struct NButton: View {
    let title: String
    var style: NButtonStyle = .primary
    var action: () -> Void

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.button, style: .continuous)

        Button {
            HapticManager.tap()
            action()
        } label: {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundStyle(foregroundColor)
                .background {
                    shape
                        .fill(baseFill)
                }
                .overlay {
                    shape
                        .stroke(borderColor, lineWidth: borderWidth)
                }
        }
        .buttonStyle(FlatPressButtonStyle())
        .accessibilityLabel(title)
        .accessibilityHint("Activates \(title)")
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .appBackground
        case .secondary, .ghost: return .colorTextPrimary
        }
    }

    private var baseFill: some ShapeStyle {
        switch style {
        case .primary:
            return AnyShapeStyle(Color.colorGreen)
        case .secondary:
            return AnyShapeStyle(Color.colorSurfaceHigh.opacity(0.76))
        case .ghost:
            return AnyShapeStyle(Color.clear)
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary:
            return Color.clear
        case .secondary:
            return Color.colorBorder
        case .ghost:
            return Color.colorBorder
        }
    }

    private var borderWidth: CGFloat {
        style == .ghost ? 0.8 : 1
    }
}

private struct FlatPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

#Preview("NButton") {
    ZStack {
        NSceneBackground()
        VStack(spacing: DesignTokens.Spacing.md) {
            NButton(title: "Start Session") {}
            NButton(title: "Secondary", style: .secondary) {}
            NButton(title: "Skip", style: .ghost) {}
        }
        .padding()
    }
}
