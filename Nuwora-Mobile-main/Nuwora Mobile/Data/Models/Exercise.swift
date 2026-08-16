import Foundation

struct Exercise: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let type: ExerciseType
    let durationSeconds: Int
    let difficulty: Int
    let xpReward: Int
    var isCompleted: Bool
}

enum ExerciseType: String, Codable, CaseIterable {
    case breathing
    case cognitive
    case mindfulness
    case focus
    case journaling

    var icon: String {
        switch self {
        case .breathing: return "wind"
        case .cognitive: return "brain"
        case .mindfulness: return "sparkles"
        case .focus: return "scope"
        case .journaling: return "book"
        }
    }
}
