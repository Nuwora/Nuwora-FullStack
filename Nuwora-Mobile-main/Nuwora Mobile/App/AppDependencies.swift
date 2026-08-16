import Foundation

enum AppEnvironment: String {
    case mock
    case stagingReady = "staging-ready"

    static func fromProcess() -> AppEnvironment {
        let raw = ProcessInfo.processInfo.environment["NUWORA_APP_ENV"]?.lowercased()
        return AppEnvironment(rawValue: raw ?? "") ?? .mock
    }
}

struct AppDependencies {
    let environment: AppEnvironment
    let dashboardRepository: DashboardRepository
    let planRepository: PlanRepository
    let coachRepository: CoachRepository
    let analyticsRepository: AnalyticsRepository
    let profileRepository: ProfileRepository
    let onboardingRepository: OnboardingRepository
    let credentialAuthClient: CredentialAuthenticating
    let healthKitManager: HealthKitManaging
    let networkMonitor: NetworkMonitoring

    init(
        environment: AppEnvironment = .mock,
        dashboardRepository: DashboardRepository,
        planRepository: PlanRepository,
        coachRepository: CoachRepository,
        analyticsRepository: AnalyticsRepository,
        profileRepository: ProfileRepository,
        onboardingRepository: OnboardingRepository,
        credentialAuthClient: CredentialAuthenticating,
        healthKitManager: HealthKitManaging,
        networkMonitor: NetworkMonitoring
    ) {
        self.environment = environment
        self.dashboardRepository = dashboardRepository
        self.planRepository = planRepository
        self.coachRepository = coachRepository
        self.analyticsRepository = analyticsRepository
        self.profileRepository = profileRepository
        self.onboardingRepository = onboardingRepository
        self.credentialAuthClient = credentialAuthClient
        self.healthKitManager = healthKitManager
        self.networkMonitor = networkMonitor
    }

    static func make(environment: AppEnvironment) -> AppDependencies {
        switch environment {
        case .mock:
            return .mock
        case .stagingReady:
            return .stagingReady
        }
    }

    static let mock = AppDependencies(
        environment: .mock,
        dashboardRepository: MockDashboardRepository(),
        planRepository: MockPlanRepository(),
        coachRepository: MockCoachRepository(),
        analyticsRepository: MockAnalyticsRepository(),
        profileRepository: MockProfileRepository(),
        onboardingRepository: MockOnboardingRepository(),
        credentialAuthClient: MockCredentialAuthClient(),
        healthKitManager: MockHealthKitManager(),
        networkMonitor: NetworkMonitor()
    )

    static let stagingReady: AppDependencies = {
        let configuration = APIConfiguration.fromProcess()
        let authSession = AnonymousAuthSession(configuration: configuration)
        let client = APIClient(configuration: configuration, authSession: authSession)

        return AppDependencies(
            environment: .stagingReady,
            dashboardRepository: StagingDashboardRepository(remote: HTTPDashboardDataSource(client: client)),
            planRepository: StagingPlanRepository(remote: HTTPPlanDataSource(client: client)),
            coachRepository: StagingCoachRepository(remote: HTTPCoachDataSource(client: client)),
            analyticsRepository: StagingAnalyticsRepository(remote: HTTPAnalyticsDataSource(client: client)),
            profileRepository: StagingProfileRepository(remote: HTTPProfileDataSource(client: client)),
            onboardingRepository: HTTPOnboardingRepository(client: client),
            credentialAuthClient: HTTPCredentialAuthClient(client: client, authSession: authSession),
            // HealthKit ingestion is outside the minimal backend contract.
            // Keep the deterministic adapter until that API is introduced.
            healthKitManager: MockHealthKitManager(),
            networkMonitor: NetworkMonitor()
        )
    }()
}
