import SwiftUI

struct SplashScreenView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        ZStack {
            background

            VStack(spacing: DesignTokens.Spacing.lg) {
                logoMark
                wordmark
            }
            .padding(.horizontal, DesignTokens.Spacing.xl)
            .scaleEffect(appeared || reduceMotion ? 1 : 0.96)
            .opacity(appeared || reduceMotion ? 1 : 0)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.55), value: appeared)
        }
        .ignoresSafeArea()
        .onAppear {
            appeared = true
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color.appBackground,
                Color.appSurface,
                Color.appCard
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .center) {
            Circle()
                .fill(Color.colorTeal.opacity(0.16))
                .frame(width: 260, height: 260)
                .blur(radius: 44)
        }
    }

    private var logoMark: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.colorTeal, Color.colorGreen],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 88, height: 88)
                .shadow(color: Color.colorGreen.opacity(0.28), radius: 22, y: 10)

            Image(systemName: "brain.head.profile")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(Color.white)
        }
        .accessibilityHidden(true)
    }

    private var wordmark: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            Text("Nuwora")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .tracking(1.4)
                .foregroundStyle(Color.colorTextPrimary)

            Text("Train calm. Build focus.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.colorTextSecondary)
        }
        .multilineTextAlignment(.center)
    }
}

#Preview {
    SplashScreenView()
}
