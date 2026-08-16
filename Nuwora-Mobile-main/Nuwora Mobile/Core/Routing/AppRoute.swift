import Foundation

enum AppRoute {
    case auth
    case onboarding
    case main
}

enum TabItem: Int, CaseIterable, Identifiable {
    case home
    case coach
    case mindGym
    case insights
    case profile

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .coach: return "Coach"
        case .mindGym: return "Mind Gym"
        case .insights: return "Insights"
        case .profile: return "Profile"
        }
    }

    var tabLabel: String {
        switch self {
        case .home: return "Today"
        case .coach: return "Coach"
        case .mindGym: return "Mind"
        case .insights: return "Insights"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .coach: return "message.badge.waveform"
        case .mindGym: return "figure.mind.and.body"
        case .insights: return "chart.line.uptrend.xyaxis"
        case .profile: return "person.crop.circle"
        }
    }
}

enum FeatureState<Value> {
    case idle
    case loading
    case loaded(Value)
    case empty
    case error(AppError)
}
