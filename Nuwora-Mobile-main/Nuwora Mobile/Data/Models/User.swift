import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var age: Int
    var primaryGoals: [PrimaryGoal]
    var joinedAt: Date
    var currentLevel: Int
    var currentStreak: Int
}

enum PrimaryGoal: String, Codable, CaseIterable, Identifiable {
    case focus = "Focus"
    case stressRelief = "Stress Relief"
    case memory = "Memory"
    case resilience = "Resilience"

    var id: String { rawValue }
}
