import Foundation

struct MockDataProvider {
    static let mindFitnessScores: [MindFitnessScore] = (0..<30).map { offset in
        let date = Calendar.current.date(byAdding: .day, value: -offset, to: .now) ?? .now
        let cognitive = Int.random(in: 55...90)
        let biometric = Int.random(in: 50...88)
        let mood = Int.random(in: 52...92)
        let overall = MindFitnessCalculator.calculateOverall(cognitive: cognitive, biometric: biometric, mood: mood)

        return MindFitnessScore(
            id: UUID(),
            date: date,
            overallScore: overall,
            cognitiveScore: cognitive,
            biometricScore: biometric,
            moodScore: mood,
            focusSubscore: Int.random(in: 50...90),
            calmSubscore: Int.random(in: 50...90),
            energySubscore: Int.random(in: 50...90)
        )
    }

    static let exercises: [Exercise] = [
        Exercise(id: UUID(), title: "Box Breathing", subtitle: "Breathing - 4 min", type: .breathing, durationSeconds: 240, difficulty: 2, xpReward: 55, isCompleted: false),
        Exercise(id: UUID(), title: "Stroop Sprint", subtitle: "Cognitive - 6 min", type: .cognitive, durationSeconds: 360, difficulty: 4, xpReward: 80, isCompleted: false),
        Exercise(id: UUID(), title: "Mindful Reset", subtitle: "Mindfulness - 5 min", type: .mindfulness, durationSeconds: 300, difficulty: 2, xpReward: 60, isCompleted: false),
        Exercise(id: UUID(), title: "Deep Focus", subtitle: "Focus - 10 min", type: .focus, durationSeconds: 600, difficulty: 3, xpReward: 90, isCompleted: false),
        Exercise(id: UUID(), title: "Reflective Journal", subtitle: "Journaling - 7 min", type: .journaling, durationSeconds: 420, difficulty: 2, xpReward: 65, isCompleted: false)
    ]

    static let achievements: [Achievement] = [
        Achievement(id: UUID(), title: "First Breath", description: "Complete your first breathing session", iconName: "wind", unlockedAt: .now.addingTimeInterval(-86_400 * 18)),
        Achievement(id: UUID(), title: "7 Day Streak", description: "Train 7 days in a row", iconName: "flame.fill", unlockedAt: .now.addingTimeInterval(-86_400 * 4)),
        Achievement(id: UUID(), title: "Calm Captain", description: "Complete 5 calming sessions in a week", iconName: "sailboat.fill", unlockedAt: .now.addingTimeInterval(-86_400 * 2)),
        Achievement(id: UUID(), title: "Focus Forge", description: "Hit 90+ focus score 3 times", iconName: "target", unlockedAt: .now.addingTimeInterval(-86_400)),
        Achievement(id: UUID(), title: "Mind Builder", description: "Complete 20 sessions", iconName: "brain.head.profile", unlockedAt: nil),
        Achievement(id: UUID(), title: "Night Owl", description: "Finish a session after 9PM", iconName: "moon.stars.fill", unlockedAt: nil),
        Achievement(id: UUID(), title: "Marathoner", description: "Complete a 30-day streak", iconName: "figure.run", unlockedAt: nil),
        Achievement(id: UUID(), title: "Resilience Pro", description: "Reach Level 10", iconName: "shield.lefthalf.filled", unlockedAt: nil),
        Achievement(id: UUID(), title: "Reflection Master", description: "Write 25 journal entries", iconName: "book.closed.fill", unlockedAt: nil)
    ]

    static let chatHistory: [ChatMessage] = [
        ChatMessage(id: UUID(), content: "How am I doing today?", sender: .user, timestamp: .now.addingTimeInterval(-1800)),
        ChatMessage(id: UUID(), content: "You are trending up in focus. A short breathing reset could amplify it.", sender: .coach, timestamp: .now.addingTimeInterval(-1700)),
        ChatMessage(id: UUID(), content: "I feel a bit stressed.", sender: .user, timestamp: .now.addingTimeInterval(-1400)),
        ChatMessage(id: UUID(), content: "Let's do a 60-second downshift and reduce pressure before your next task.", sender: .coach, timestamp: .now.addingTimeInterval(-1300))
    ]

    static let leaderboard: [LeaderboardEntry] = [
        LeaderboardEntry(id: UUID(), rank: 1, alias: "ZenFalcon", score: 2810),
        LeaderboardEntry(id: UUID(), rank: 2, alias: "NovaPulse", score: 2730),
        LeaderboardEntry(id: UUID(), rank: 3, alias: "CalmRider", score: 2645),
        LeaderboardEntry(id: UUID(), rank: 4, alias: "FocusForge", score: 2510),
        LeaderboardEntry(id: UUID(), rank: 5, alias: "Dimi", score: 2415),
        LeaderboardEntry(id: UUID(), rank: 6, alias: "QuietRiver", score: 2370),
        LeaderboardEntry(id: UUID(), rank: 7, alias: "AuroraMind", score: 2298)
    ]

    static let user = User(
        id: UUID(),
        name: "Dimi",
        age: 28,
        primaryGoals: [.focus, .resilience],
        joinedAt: .now.addingTimeInterval(-86_400 * 21),
        currentLevel: 7,
        currentStreak: 5
    )
}
