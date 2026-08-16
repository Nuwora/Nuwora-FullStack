import Foundation

extension CoachPersona {
    var apiIdentifier: String {
        switch self {
        case .aria: return "zen_monk"
        case .max: return "peak_performer"
        case .zen: return "neuroscientist"
        }
    }
}

extension AnalyticsPeriod {
    var apiIdentifier: String {
        switch self {
        case .week: return "week"
        case .month: return "month"
        case .threeMonths: return "three_months"
        }
    }
}

extension PrimaryGoal {
    var apiIdentifier: String {
        switch self {
        case .focus: return "focus"
        case .stressRelief: return "stress_relief"
        case .memory: return "memory"
        case .resilience: return "resilience"
        }
    }
}

struct MoodCheckInRequest: Codable, Equatable {
    let mood: Int
    let occurredAt: Date
    let clientMutationID: UUID
}

struct CompleteExerciseRequest: Codable, Equatable {
    let performance: Double
    let completedAt: Date
    let clientMutationID: UUID
}

struct SkipExerciseRequest: Codable, Equatable {
    let skippedAt: Date
    let clientMutationID: UUID
}

struct SendCoachMessageRequest: Codable, Equatable {
    let content: String
    let persona: String
    let clientMutationID: UUID
}

struct WeeklySummaryDTO: Codable, Equatable {
    let summary: String
}

final class HTTPDashboardDataSource: RemoteDashboardDataSource {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchDashboardSnapshot() async throws -> DashboardSnapshotDTO {
        try await client.send(DashboardSnapshotDTO.self, path: "dashboard")
    }

    func logMood(_ mood: MoodOption) async throws {
        let request = MoodCheckInRequest(
            mood: mood.rawValue,
            occurredAt: .now,
            clientMutationID: UUID()
        )
        let _: EmptyResponse = try await client.send(
            EmptyResponse.self,
            method: .post,
            path: "moods",
            body: AnyEncodable(request)
        )
    }
}

final class HTTPPlanDataSource: RemotePlanDataSource {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchTodayPlan() async throws -> [ExerciseDTO] {
        try await client.send([ExerciseDTO].self, path: "plans/today")
    }

    func markComplete(exerciseID: UUID, performance: Double) async throws {
        let request = CompleteExerciseRequest(
            performance: Self.normalizedPerformance(performance),
            completedAt: .now,
            clientMutationID: UUID()
        )
        let _: EmptyResponse = try await client.send(
            EmptyResponse.self,
            method: .post,
            path: "exercises/\(exerciseID.uuidString)/complete",
            body: AnyEncodable(request)
        )
    }

    static func normalizedPerformance(_ performance: Double) -> Double {
        min(1, max(0, performance))
    }

    func skip(exerciseID: UUID) async throws {
        let request = SkipExerciseRequest(skippedAt: .now, clientMutationID: UUID())
        let _: EmptyResponse = try await client.send(
            EmptyResponse.self,
            method: .post,
            path: "exercises/\(exerciseID.uuidString)/skip",
            body: AnyEncodable(request)
        )
    }
}

final class HTTPCoachDataSource: RemoteCoachDataSource {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchMessages(limit: Int, cursor: String?) async throws -> [ChatMessageDTO] {
        var queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        if let cursor, cursor.isEmpty == false {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }
        return try await client.send(
            [ChatMessageDTO].self,
            path: "coach/messages",
            queryItems: queryItems
        )
    }

    func sendMessage(_ text: String, persona: CoachPersona) async throws -> ChatMessageDTO {
        let request = SendCoachMessageRequest(
            content: text,
            persona: persona.apiIdentifier,
            clientMutationID: UUID()
        )
        return try await client.send(
            ChatMessageDTO.self,
            method: .post,
            path: "coach/messages",
            body: AnyEncodable(request)
        )
    }
}

final class HTTPAnalyticsDataSource: RemoteAnalyticsDataSource {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchScores(period: AnalyticsPeriod, page: Int?) async throws -> [MindFitnessScoreDTO] {
        var queryItems = [URLQueryItem(name: "period", value: period.apiIdentifier)]
        if let page {
            queryItems.append(URLQueryItem(name: "page", value: String(page)))
        }
        return try await client.send(
            [MindFitnessScoreDTO].self,
            path: "analytics/scores",
            queryItems: queryItems
        )
    }

    func fetchCorrelationInsights() async throws -> [CorrelationInsightDTO] {
        try await client.send([CorrelationInsightDTO].self, path: "analytics/correlations")
    }

    func fetchWeeklySummary() async throws -> String {
        let response = try await client.send(WeeklySummaryDTO.self, path: "analytics/weekly-summary")
        return response.summary
    }
}

final class HTTPProfileDataSource: RemoteProfileDataSource {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchProfile() async throws -> UserDTO {
        try await client.send(UserDTO.self, path: "me")
    }

    func fetchAchievements() async throws -> [AchievementDTO] {
        try await client.send([AchievementDTO].self, path: "me/achievements")
    }

    func fetchLeaderboardPreview() async throws -> [LeaderboardEntryDTO] {
        try await client.send(
            [LeaderboardEntryDTO].self,
            path: "leaderboard",
            queryItems: [URLQueryItem(name: "limit", value: "3")]
        )
    }
}

struct OnboardingSubmission: Equatable {
    let name: String
    let age: Int
    let primaryGoals: [PrimaryGoal]
    let assessmentAnswers: [Int]
    let connectedWearables: [String]
    let initialScore: Int
    let cognitiveScore: Int
    let biometricScore: Int
    let moodScore: Int
}

struct OnboardingRequestDTO: Codable, Equatable {
    struct InitialScores: Codable, Equatable {
        let overall: Int
        let cognitive: Int
        let biometric: Int
        let mood: Int
    }

    let name: String
    let age: Int
    let primaryGoals: [String]
    let assessmentAnswers: [Int]
    let connectedWearables: [String]
    let initialScores: InitialScores
}

protocol OnboardingRepository {
    func submit(_ submission: OnboardingSubmission) async throws
}

final class MockOnboardingRepository: OnboardingRepository {
    func submit(_: OnboardingSubmission) async throws {}
}

final class HTTPOnboardingRepository: OnboardingRepository {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func submit(_ submission: OnboardingSubmission) async throws {
        let request = Self.makeRequest(from: submission)

        let _: EmptyResponse = try await client.send(
            EmptyResponse.self,
            method: .post,
            path: "onboarding",
            body: AnyEncodable(request)
        )
    }

    static func makeRequest(from submission: OnboardingSubmission) -> OnboardingRequestDTO {
        OnboardingRequestDTO(
            name: submission.name.trimmingCharacters(in: .whitespacesAndNewlines),
            age: submission.age,
            primaryGoals: submission.primaryGoals.map(\.apiIdentifier).sorted(),
            assessmentAnswers: submission.assessmentAnswers,
            connectedWearables: submission.connectedWearables.sorted(),
            initialScores: OnboardingRequestDTO.InitialScores(
                overall: submission.initialScore,
                cognitive: submission.cognitiveScore,
                biometric: submission.biometricScore,
                mood: submission.moodScore
            )
        )
    }
}
