import SwiftUI

enum NSceneStyle: Hashable {
    case onboarding
    case home
    case coach
    case mindGym
    case insights
    case profile

    init(tab: TabItem) {
        switch tab {
        case .home:
            self = .home
        case .coach:
            self = .coach
        case .mindGym:
            self = .mindGym
        case .insights:
            self = .insights
        case .profile:
            self = .profile
        }
    }

    var baseGradient: LinearGradient {
        switch self {
        case .onboarding:
            return LinearGradient(
                colors: [Color.appBackground, Color.appSurface, Color.accentTint.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .home:
            return LinearGradient(
                colors: [Color.appBackground, Color.appSurface, Color.appCard],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .coach:
            return LinearGradient(
                colors: [Color.appBackground, Color.appCard, Color.accentTint.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .mindGym:
            return LinearGradient(
                colors: [Color.appBackground, Color.appSurface, Color.accentTint.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .insights:
            return LinearGradient(
                colors: [Color.appBackground, Color.appCard, Color.accentTint.opacity(0.65)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .profile:
            return LinearGradient(
                colors: [Color.appBackground, Color.appSurface, Color.accentTint.opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

}

struct NSceneBackground: View {
    var style: NSceneStyle = .home

    var body: some View {
        style.baseGradient
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [Color.textPrimary.opacity(0.03), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)
            }
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [Color.clear, Color.appBackground.opacity(0.16)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 180)
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()
    }
}

#Preview {
    NSceneBackground(style: .coach)
}
