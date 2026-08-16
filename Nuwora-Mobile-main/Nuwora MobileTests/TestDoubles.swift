import Foundation
@testable import Nuwora_Mobile

struct FixedError: Error {}

final class StubDashboardRepository: DashboardRepository {
    enum Mode {
        case success(DashboardSnapshot)
        case failure(Error)
    }

    let mode: Mode
    private(set) var loggedMoods: [MoodOption] = []

    init(mode: Mode) {
        self.mode = mode
    }

    func fetchDashboard() async throws -> DashboardSnapshot {
        switch mode {
        case let .success(snapshot):
            return snapshot
        case let .failure(error):
            throw error
        }
    }

    func logMood(_ mood: MoodOption) async throws {
        loggedMoods.append(mood)
    }
}

final class StubPlanRepository: PlanRepository {
    enum Mode {
        case success([Exercise])
        case failure(Error)
    }

    let fetchMode: Mode
    let markCompleteError: Error?
    let skipError: Error?

    init(fetchMode: Mode, markCompleteError: Error? = nil, skipError: Error? = nil) {
        self.fetchMode = fetchMode
        self.markCompleteError = markCompleteError
        self.skipError = skipError
    }

    func fetchTodayPlan() async throws -> [Exercise] {
        switch fetchMode {
        case let .success(exercises):
            return exercises
        case let .failure(error):
            throw error
        }
    }

    func markComplete(exerciseID: UUID, performance: Double) async throws {
        _ = exerciseID
        _ = performance
        if let markCompleteError {
            throw markCompleteError
        }
    }

    func skip(exerciseID: UUID) async throws {
        _ = exerciseID
        if let skipError {
            throw skipError
        }
    }
}

final class StubCoachRepository: CoachRepository {
    enum Mode {
        case success([ChatMessage])
        case failure(Error)
    }

    let fetchMode: Mode
    let sendMode: Mode

    init(fetchMode: Mode, sendMode: Mode) {
        self.fetchMode = fetchMode
        self.sendMode = sendMode
    }

    func fetchMessages(limit: Int, cursor _: String?) async throws -> [ChatMessage] {
        switch fetchMode {
        case let .success(messages):
            return Array(messages.prefix(limit))
        case let .failure(error):
            throw error
        }
    }

    func sendMessage(_ text: String, persona _: CoachPersona) async throws -> ChatMessage {
        _ = text
        switch sendMode {
        case let .success(messages):
            if let first = messages.first {
                return first
            }
            return ChatMessage(id: UUID(), content: "OK", sender: .coach, timestamp: .now)
        case let .failure(error):
            throw error
        }
    }
}

final class SpyAnalyticsLogger: LocalAnalyticsLogging {
    private(set) var events: [LocalAnalyticsEvent] = []

    func track(_ event: LocalAnalyticsEvent) {
        events.append(event)
    }
}

final class StubNetworkMonitor: NetworkMonitoring {
    var isConnected: Bool
    private var observers: [(Bool) -> Void] = []

    init(isConnected: Bool = true) {
        self.isConnected = isConnected
    }

    func start(_ onChange: @escaping (Bool) -> Void) {
        observers.append(onChange)
        onChange(isConnected)
    }

    func send(_ isConnected: Bool) {
        self.isConnected = isConnected
        observers.forEach { $0(isConnected) }
    }
}

struct TestFixtures {
    static func sampleScore(overall: Int = 74) -> MindFitnessScore {
        MindFitnessScore(
            id: UUID(),
            date: Date(),
            overallScore: overall,
            cognitiveScore: 72,
            biometricScore: 70,
            moodScore: 71,
            focusSubscore: 73,
            calmSubscore: 70,
            energySubscore: 69
        )
    }

    static func sampleExercise(id: UUID = UUID(), completed: Bool = false) -> Exercise {
        Exercise(
            id: id,
            title: "Breathing Reset",
            subtitle: "2-minute downshift",
            type: .breathing,
            durationSeconds: 120,
            difficulty: 2,
            xpReward: 60,
            isCompleted: completed
        )
    }

    static func dashboardSnapshot(planPreview: [Exercise]) -> DashboardSnapshot {
        DashboardSnapshot(
            score: sampleScore(),
            planPreview: planPreview,
            streakCount: 3,
            currentLevel: 2,
            xpProgress: 0.4,
            aiInsight: "Keep going",
            lastSyncDate: Date().addingTimeInterval(-300)
        )
    }

    static func appDependencies(networkMonitor: NetworkMonitoring = StubNetworkMonitor()) -> AppDependencies {
        AppDependencies(
            dashboardRepository: MockDashboardRepository(),
            planRepository: MockPlanRepository(),
            coachRepository: MockCoachRepository(coachService: MockCoachService()),
            analyticsRepository: MockAnalyticsRepository(),
            profileRepository: MockProfileRepository(),
            onboardingRepository: MockOnboardingRepository(),
            credentialAuthClient: MockCredentialAuthClient(),
            healthKitManager: MockHealthKitManager(),
            networkMonitor: networkMonitor
        )
    }
}

final class MockCoachService: CoachServicing {
    func sendMessage(_ message: String, persona: CoachPersona) async throws -> [String] {
        _ = message
        _ = persona
        return ["OK"]
    }
}
