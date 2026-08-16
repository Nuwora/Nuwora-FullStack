import SwiftUI

/// Hosts the pre-onboarding auth flow: an entry screen offering Log In,
/// Create Account, or Continue as Guest, plus the two credential forms.
/// "Continue as Guest" skips straight to `onFinished` — the existing
/// `AnonymousAuthSession` still authenticates lazily on the first
/// authenticated request, exactly as it always has.
struct AuthContainerView: View {
    let credentialAuth: CredentialAuthenticating
    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var stage: Stage = .welcome

    enum Stage {
        case welcome
        case login
        case register
    }

    var body: some View {
        Group {
            switch stage {
            case .welcome:
                AuthWelcomeView(
                    onLogin: { withAnimation(navigationAnimation) { stage = .login } },
                    onRegister: { withAnimation(navigationAnimation) { stage = .register } },
                    onContinueAsGuest: onFinished
                )
            case .login:
                LoginView(
                    credentialAuth: credentialAuth,
                    onBack: { withAnimation(navigationAnimation) { stage = .welcome } },
                    onSuccess: onFinished
                )
            case .register:
                RegisterView(
                    credentialAuth: credentialAuth,
                    onBack: { withAnimation(navigationAnimation) { stage = .welcome } },
                    onSuccess: onFinished
                )
            }
        }
        .transition(
            .asymmetric(
                insertion: .opacity.combined(with: .move(edge: .trailing)),
                removal: .opacity.combined(with: .move(edge: .leading))
            )
        )
    }

    private var navigationAnimation: Animation {
        reduceMotion ? .linear(duration: 0.01) : .nuworaSpring
    }
}

#Preview {
    ZStack {
        NSceneBackground(style: .onboarding)
        AuthContainerView(credentialAuth: MockCredentialAuthClient(), onFinished: {})
    }
}
