import SwiftUI

struct AppRootView: View {
    @Environment(AppStore.self) private var appStore

    var body: some View {
        ZStack(alignment: .bottom) {
            NSceneBackground(style: sceneStyle)
                .overlay(alignment: .top) {
                    LinearGradient(
                        colors: [Color.textPrimary.opacity(0.05), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 140)
                    .ignoresSafeArea(edges: .top)
                }
                .animation(.nuworaSoftEase, value: sceneStyle)

            routeView
            .animation(.nuworaPageSpring, value: appStore.route)

            if let toast = appStore.toastMessage {
                NToast(message: toast)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    @ViewBuilder
    private var routeView: some View {
        switch appStore.route {
        case .auth:
            AuthContainerView(
                credentialAuth: appStore.dependencies.credentialAuthClient,
                onFinished: appStore.completeAuth
            )
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .leading)),
                        removal: .opacity.combined(with: .move(edge: .trailing))
                    )
                )
        case .onboarding:
            OnboardingView(
                repository: appStore.dependencies.onboardingRepository,
                onFinished: appStore.finishOnboarding
            )
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .leading)),
                        removal: .opacity.combined(with: .move(edge: .trailing))
                    )
                )
        case .main:
            MainTabView()
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity.combined(with: .move(edge: .leading))
                    )
                )
        }
    }

    private var sceneStyle: NSceneStyle {
        switch appStore.route {
        case .auth, .onboarding:
            return .onboarding
        case .main:
            return NSceneStyle(tab: appStore.selectedTab)
        }
    }
}

#Preview {
    AppRootView()
        .environment(AppStore())
}
