import SwiftUI

struct AuthWelcomeView: View {
    let onLogin: () -> Void
    let onRegister: () -> Void
    let onContinueAsGuest: () -> Void

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xl) {
            Spacer(minLength: DesignTokens.Spacing.xl)

            hero

            Spacer(minLength: DesignTokens.Spacing.lg)

            NCard {
                VStack(spacing: DesignTokens.Spacing.md) {
                    NButton(title: "Log In", action: onLogin)
                    NButton(title: "Create Account", style: .secondary, action: onRegister)
                    NButton(title: "Continue as Guest", style: .ghost, action: onContinueAsGuest)
                }
            }

            Spacer(minLength: DesignTokens.Spacing.xl)
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var hero: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.colorGreen.opacity(0.1))
                    .frame(width: 80, height: 80)
                Circle()
                    .fill(Color.colorTeal.opacity(0.08))
                    .frame(width: 56, height: 56)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(Color.colorGreen)
            }

            VStack(spacing: DesignTokens.Spacing.xs) {
                Text("Welcome to Nuwora")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.colorTextPrimary)

                Text("Sign in to keep your progress across devices, or continue as a guest.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.colorTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    ZStack {
        NSceneBackground(style: .onboarding)
        AuthWelcomeView(onLogin: {}, onRegister: {}, onContinueAsGuest: {})
    }
}
