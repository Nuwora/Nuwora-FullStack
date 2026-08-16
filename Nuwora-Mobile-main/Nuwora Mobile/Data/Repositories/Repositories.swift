import Foundation

struct DashboardSnapshot {
    let score: MindFitnessScore
    let planPreview: [Exercise]
    let streakCount: Int
    let currentLevel: Int
    let xpProgress: Double
    let aiInsight: String
    let lastSyncDate: Date
}

protocol DashboardRepository {
    func fetchDashboard() async throws -> DashboardSnapshot
    func logMood(_ mood: MoodOption) async throws
}

protocol PlanRepository {
    func fetchTodayPlan() async throws -> [Exercise]
    func markComplete(exerciseID: UUID, performance: Double) async throws
    func skip(exerciseID: UUID) async throws
}

protocol CoachRepository {
    func fetchMessages(limit: Int, cursor: String?) async throws -> [ChatMessage]
    func sendMessage(_ text: String, persona: CoachPersona) async throws -> ChatMessage
}

protocol AnalyticsRepository {
    func fetchScores(period: AnalyticsPeriod, page: Int?) async throws -> [MindFitnessScore]
    func fetchCorrelationInsights() async throws -> [CorrelationInsight]
    func fetchWeeklySummary() async throws -> String
}

protocol ProfileRepository {
    func fetchProfile() async throws -> User
    func fetchAchievements() async throws -> [Achievement]
    func fetchLeaderboardPreview() async throws -> [LeaderboardEntry]
}

final class MockDashboardRepository: DashboardRepository {
    func fetchDashboard() async throws -> DashboardSnapshot {
        DashboardSnapshot(
            score: MockDataProvider.mindFitnessScores.first ?? MindFitnessScore(
                id: UUID(),
                date: .now,
                overallScore: 72,
                cognitiveScore: 70,
                biometricScore: 75,
                moodScore: 71,
                focusSubscore: 74,
                calmSubscore: 69,
                energySubscore: 73
            ),
            planPreview: Array(MockDataProvider.exercises.prefix(3)),
            streakCount: MockDataProvider.user.currentStreak,
            currentLevel: MockDataProvider.user.currentLevel,
            xpProgress: 0.62,
            aiInsight: "Based on your HRV trend, a focus session could yield +8% improvement.",
            lastSyncDate: .now.addingTimeInterval(-60 * 20)
        )
    }

    func logMood(_: MoodOption) async throws {}
}

final class MockPlanRepository: PlanRepository {
    func fetchTodayPlan() async throws -> [Exercise] {
        MockDataProvider.exercises
    }

    func markComplete(exerciseID _: UUID, performance _: Double) async throws {}

    func skip(exerciseID _: UUID) async throws {}
}

final class MockCoachRepository: CoachRepository {
    private let coachService: CoachServicing

    init(coachService: CoachServicing = CoachService()) {
        self.coachService = coachService
    }

    func fetchMessages(limit: Int, cursor _: String?) async throws -> [ChatMessage] {
        Array(MockDataProvider.chatHistory.prefix(limit))
    }

    func sendMessage(_ text: String, persona: CoachPersona) async throws -> ChatMessage {
        let lines = try await coachService.sendMessage(text, persona: persona)
        let body = lines.joined(separator: " ")
        return ChatMessage(
            id: UUID(),
            content: body,
            sender: .coach,
            timestamp: .now
        )
    }
}

final class MockAnalyticsRepository: AnalyticsRepository {
    func fetchScores(period: AnalyticsPeriod, page _: Int?) async throws -> [MindFitnessScore] {
        switch period {
        case .week: return Array(MockDataProvider.mindFitnessScores.prefix(7))
        case .month: return Array(MockDataProvider.mindFitnessScores.prefix(30))
        case .threeMonths: return MockDataProvider.mindFitnessScores
        }
    }

    func fetchCorrelationInsights() async throws -> [CorrelationInsight] {
        [
            CorrelationInsight(id: UUID(), title: "Better sleep -> Higher focus", description: "On nights above 7h sleep, your focus rose by 11%.", strength: 0.72),
            CorrelationInsight(id: UUID(), title: "Breathing -> Lower stress", description: "After breathwork sessions, mood volatility decreased by 9%.", strength: 0.61)
        ]
    }

    func fetchWeeklySummary() async throws -> String {
        "This week your consistency improved and calm score stabilized. Keep sessions short and frequent."
    }
}

final class MockProfileRepository: ProfileRepository {
    func fetchProfile() async throws -> User {
        MockDataProvider.user
    }

    func fetchAchievements() async throws -> [Achievement] {
        MockDataProvider.achievements
    }

    func fetchLeaderboardPreview() async throws -> [LeaderboardEntry] {
        MockDataProvider.leaderboard
    }
}

// MARK: - Backend-Ready DTO Contracts

struct DashboardSnapshotDTO: Codable {
    let score: MindFitnessScoreDTO
    let planPreview: [ExerciseDTO]
    let streakCount: Int
    let currentLevel: Int
    let xpProgress: Double
    let aiInsight: String
    let lastSyncDate: Date
}

struct MindFitnessScoreDTO: Codable {
    let id: UUID
    let date: Date
    let overallScore: Int
    let cognitiveScore: Int
    let biometricScore: Int
    let moodScore: Int
    let focusSubscore: Int
    let calmSubscore: Int
    let energySubscore: Int
}

struct ExerciseDTO: Codable {
    let id: UUID
    let title: String
    let subtitle: String
    let type: String
    let durationSeconds: Int
    let difficulty: Int
    let xpReward: Int
    let isCompleted: Bool
}

struct ChatMessageDTO: Codable {
    let id: UUID
    let content: String
    let sender: String
    let timestamp: Date
}

struct CorrelationInsightDTO: Codable {
    let id: UUID
    let title: String
    let description: String
    let strength: Double
}

struct UserDTO: Codable {
    let id: UUID
    let name: String
    let age: Int
    let primaryGoals: [String]
    let joinedAt: Date
    let currentLevel: Int
    let currentStreak: Int
}

struct AchievementDTO: Codable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let unlockedAt: Date?
}

struct LeaderboardEntryDTO: Codable {
    let id: UUID
    let rank: Int
    let alias: String
    let score: Int
}

enum RemoteMapper {
    static func map(_ dto: MindFitnessScoreDTO) -> MindFitnessScore {
        MindFitnessScore(
            id: dto.id,
            date: dto.date,
            overallScore: dto.overallScore,
            cognitiveScore: dto.cognitiveScore,
            biometricScore: dto.biometricScore,
            moodScore: dto.moodScore,
            focusSubscore: dto.focusSubscore,
            calmSubscore: dto.calmSubscore,
            energySubscore: dto.energySubscore
        )
    }

    static func map(_ dto: ExerciseDTO) -> Exercise {
        Exercise(
            id: dto.id,
            title: dto.title,
            subtitle: dto.subtitle,
            type: ExerciseType(rawValue: dto.type) ?? .mindfulness,
            durationSeconds: dto.durationSeconds,
            difficulty: dto.difficulty,
            xpReward: dto.xpReward,
            isCompleted: dto.isCompleted
        )
    }

    static func map(_ dto: ChatMessageDTO) -> ChatMessage {
        ChatMessage(
            id: dto.id,
            content: dto.content,
            sender: MessageSender(rawValue: dto.sender) ?? .coach,
            timestamp: dto.timestamp
        )
    }

    static func map(_ dto: CorrelationInsightDTO) -> CorrelationInsight {
        CorrelationInsight(
            id: dto.id,
            title: dto.title,
            description: dto.description,
            strength: dto.strength
        )
    }

    static func map(_ dto: UserDTO) -> User {
        User(
            id: dto.id,
            name: dto.name,
            age: dto.age,
            primaryGoals: dto.primaryGoals.compactMap(PrimaryGoal.init(rawValue:)),
            joinedAt: dto.joinedAt,
            currentLevel: dto.currentLevel,
            currentStreak: dto.currentStreak
        )
    }

    static func map(_ dto: AchievementDTO) -> Achievement {
        Achievement(
            id: dto.id,
            title: dto.title,
            description: dto.description,
            iconName: dto.iconName,
            unlockedAt: dto.unlockedAt
        )
    }

    static func map(_ dto: LeaderboardEntryDTO) -> LeaderboardEntry {
        LeaderboardEntry(
            id: dto.id,
            rank: dto.rank,
            alias: dto.alias,
            score: dto.score
        )
    }

    static func map(_ dto: DashboardSnapshotDTO) -> DashboardSnapshot {
        DashboardSnapshot(
            score: map(dto.score),
            planPreview: dto.planPreview.map { map($0) },
            streakCount: dto.streakCount,
            currentLevel: dto.currentLevel,
            xpProgress: dto.xpProgress,
            aiInsight: dto.aiInsight,
            lastSyncDate: dto.lastSyncDate
        )
    }
}

// MARK: - Remote Data Source Protocols

protocol RemoteDashboardDataSource {
    func fetchDashboardSnapshot() async throws -> DashboardSnapshotDTO
    func logMood(_ mood: MoodOption) async throws
}

protocol RemotePlanDataSource {
    func fetchTodayPlan() async throws -> [ExerciseDTO]
    func markComplete(exerciseID: UUID, performance: Double) async throws
    func skip(exerciseID: UUID) async throws
}

protocol RemoteCoachDataSource {
    func fetchMessages(limit: Int, cursor: String?) async throws -> [ChatMessageDTO]
    func sendMessage(_ text: String, persona: CoachPersona) async throws -> ChatMessageDTO
}

protocol RemoteAnalyticsDataSource {
    func fetchScores(period: AnalyticsPeriod, page: Int?) async throws -> [MindFitnessScoreDTO]
    func fetchCorrelationInsights() async throws -> [CorrelationInsightDTO]
    func fetchWeeklySummary() async throws -> String
}

protocol RemoteProfileDataSource {
    func fetchProfile() async throws -> UserDTO
    func fetchAchievements() async throws -> [AchievementDTO]
    func fetchLeaderboardPreview() async throws -> [LeaderboardEntryDTO]
}

// MARK: - Staging-Ready Repositories

final class StagingDashboardRepository: DashboardRepository {
    private let remote: RemoteDashboardDataSource

    init(remote: RemoteDashboardDataSource) {
        self.remote = remote
    }

    func fetchDashboard() async throws -> DashboardSnapshot {
        let snapshot = try await remote.fetchDashboardSnapshot()
        return RemoteMapper.map(snapshot)
    }

    func logMood(_ mood: MoodOption) async throws {
        try await remote.logMood(mood)
    }
}

final class StagingPlanRepository: PlanRepository {
    private let remote: RemotePlanDataSource

    init(remote: RemotePlanDataSource) {
        self.remote = remote
    }

    func fetchTodayPlan() async throws -> [Exercise] {
        try await remote.fetchTodayPlan().map { RemoteMapper.map($0) }
    }

    func markComplete(exerciseID: UUID, performance: Double) async throws {
        try await remote.markComplete(exerciseID: exerciseID, performance: performance)
    }

    func skip(exerciseID: UUID) async throws {
        try await remote.skip(exerciseID: exerciseID)
    }
}

final class StagingCoachRepository: CoachRepository {
    private let remote: RemoteCoachDataSource

    init(remote: RemoteCoachDataSource) {
        self.remote = remote
    }

    func fetchMessages(limit: Int, cursor: String?) async throws -> [ChatMessage] {
        try await remote.fetchMessages(limit: limit, cursor: cursor).map { RemoteMapper.map($0) }
    }

    func sendMessage(_ text: String, persona: CoachPersona) async throws -> ChatMessage {
        let response = try await remote.sendMessage(text, persona: persona)
        return RemoteMapper.map(response)
    }
}

final class StagingAnalyticsRepository: AnalyticsRepository {
    private let remote: RemoteAnalyticsDataSource

    init(remote: RemoteAnalyticsDataSource) {
        self.remote = remote
    }

    func fetchScores(period: AnalyticsPeriod, page: Int?) async throws -> [MindFitnessScore] {
        try await remote.fetchScores(period: period, page: page).map { RemoteMapper.map($0) }
    }

    func fetchCorrelationInsights() async throws -> [CorrelationInsight] {
        try await remote.fetchCorrelationInsights().map { RemoteMapper.map($0) }
    }

    func fetchWeeklySummary() async throws -> String {
        try await remote.fetchWeeklySummary()
    }
}

final class StagingProfileRepository: ProfileRepository {
    private let remote: RemoteProfileDataSource

    init(remote: RemoteProfileDataSource) {
        self.remote = remote
    }

    func fetchProfile() async throws -> User {
        try await RemoteMapper.map(remote.fetchProfile())
    }

    func fetchAchievements() async throws -> [Achievement] {
        try await remote.fetchAchievements().map { RemoteMapper.map($0) }
    }

    func fetchLeaderboardPreview() async throws -> [LeaderboardEntry] {
        try await remote.fetchLeaderboardPreview().map { RemoteMapper.map($0) }
    }
}

// MARK: - Legacy Stub Remotes (not wired into staging-ready)

final class StubRemoteDashboardDataSource: RemoteDashboardDataSource {
    func fetchDashboardSnapshot() async throws -> DashboardSnapshotDTO {
        let first = MockDataProvider.mindFitnessScores.first
        let score = MindFitnessScoreDTO(
            id: first?.id ?? UUID(),
            date: first?.date ?? .now,
            overallScore: first?.overallScore ?? 72,
            cognitiveScore: first?.cognitiveScore ?? 70,
            biometricScore: first?.biometricScore ?? 75,
            moodScore: first?.moodScore ?? 71,
            focusSubscore: first?.focusSubscore ?? 74,
            calmSubscore: first?.calmSubscore ?? 69,
            energySubscore: first?.energySubscore ?? 73
        )
        return DashboardSnapshotDTO(
            score: score,
            planPreview: Array(MockDataProvider.exercises.prefix(3)).map {
                ExerciseDTO(
                    id: $0.id,
                    title: $0.title,
                    subtitle: $0.subtitle,
                    type: $0.type.rawValue,
                    durationSeconds: $0.durationSeconds,
                    difficulty: $0.difficulty,
                    xpReward: $0.xpReward,
                    isCompleted: $0.isCompleted
                )
            },
            streakCount: MockDataProvider.user.currentStreak,
            currentLevel: MockDataProvider.user.currentLevel,
            xpProgress: 0.62,
            aiInsight: "Based on your HRV trend, a focus session could yield +8% improvement.",
            lastSyncDate: .now.addingTimeInterval(-60 * 20)
        )
    }

    func logMood(_: MoodOption) async throws {}
}

final class StubRemotePlanDataSource: RemotePlanDataSource {
    func fetchTodayPlan() async throws -> [ExerciseDTO] {
        MockDataProvider.exercises.map {
            ExerciseDTO(
                id: $0.id,
                title: $0.title,
                subtitle: $0.subtitle,
                type: $0.type.rawValue,
                durationSeconds: $0.durationSeconds,
                difficulty: $0.difficulty,
                xpReward: $0.xpReward,
                isCompleted: $0.isCompleted
            )
        }
    }

    func markComplete(exerciseID _: UUID, performance _: Double) async throws {}
    func skip(exerciseID _: UUID) async throws {}
}

final class StubRemoteCoachDataSource: RemoteCoachDataSource {
    private let service: CoachServicing

    init(service: CoachServicing = CoachService()) {
        self.service = service
    }

    func fetchMessages(limit: Int, cursor _: String?) async throws -> [ChatMessageDTO] {
        Array(MockDataProvider.chatHistory.prefix(limit)).map {
            ChatMessageDTO(
                id: $0.id,
                content: $0.content,
                sender: $0.sender.rawValue,
                timestamp: $0.timestamp
            )
        }
    }

    func sendMessage(_ text: String, persona: CoachPersona) async throws -> ChatMessageDTO {
        let lines = try await service.sendMessage(text, persona: persona)
        return ChatMessageDTO(
            id: UUID(),
            content: lines.joined(separator: " "),
            sender: MessageSender.coach.rawValue,
            timestamp: .now
        )
    }
}

final class StubRemoteAnalyticsDataSource: RemoteAnalyticsDataSource {
    func fetchScores(period: AnalyticsPeriod, page _: Int?) async throws -> [MindFitnessScoreDTO] {
        let scores: [MindFitnessScore]
        switch period {
        case .week:
            scores = Array(MockDataProvider.mindFitnessScores.prefix(7))
        case .month:
            scores = Array(MockDataProvider.mindFitnessScores.prefix(30))
        case .threeMonths:
            scores = MockDataProvider.mindFitnessScores
        }

        return scores.map {
            MindFitnessScoreDTO(
                id: $0.id,
                date: $0.date,
                overallScore: $0.overallScore,
                cognitiveScore: $0.cognitiveScore,
                biometricScore: $0.biometricScore,
                moodScore: $0.moodScore,
                focusSubscore: $0.focusSubscore,
                calmSubscore: $0.calmSubscore,
                energySubscore: $0.energySubscore
            )
        }
    }

    func fetchCorrelationInsights() async throws -> [CorrelationInsightDTO] {
        [
            CorrelationInsightDTO(
                id: UUID(),
                title: "Better sleep -> Higher focus",
                description: "On nights above 7h sleep, your focus rose by 11%.",
                strength: 0.72
            ),
            CorrelationInsightDTO(
                id: UUID(),
                title: "Breathing -> Lower stress",
                description: "After breathwork sessions, mood volatility decreased by 9%.",
                strength: 0.61
            )
        ]
    }

    func fetchWeeklySummary() async throws -> String {
        "This week your consistency improved and calm score stabilized. Keep sessions short and frequent."
    }
}

final class StubRemoteProfileDataSource: RemoteProfileDataSource {
    func fetchProfile() async throws -> UserDTO {
        let user = MockDataProvider.user
        return UserDTO(
            id: user.id,
            name: user.name,
            age: user.age,
            primaryGoals: user.primaryGoals.map(\.rawValue),
            joinedAt: user.joinedAt,
            currentLevel: user.currentLevel,
            currentStreak: user.currentStreak
        )
    }

    func fetchAchievements() async throws -> [AchievementDTO] {
        MockDataProvider.achievements.map {
            AchievementDTO(
                id: $0.id,
                title: $0.title,
                description: $0.description,
                iconName: $0.iconName,
                unlockedAt: $0.unlockedAt
            )
        }
    }

    func fetchLeaderboardPreview() async throws -> [LeaderboardEntryDTO] {
        Array(MockDataProvider.leaderboard.prefix(3)).map {
            LeaderboardEntryDTO(id: $0.id, rank: $0.rank, alias: $0.alias, score: $0.score)
        }
    }
}
