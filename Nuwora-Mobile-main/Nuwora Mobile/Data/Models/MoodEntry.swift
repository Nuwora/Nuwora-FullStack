import Foundation

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let mood: MoodOption
}

enum MoodOption: Int, CaseIterable, Codable {
    case awful = 1
    case bad
    case neutral
    case good
    case great

    var emoji: String {
        switch self {
        case .awful: return "😞"
        case .bad: return "😕"
        case .neutral: return "😐"
        case .good: return "🙂"
        case .great: return "😄"
        }
    }

    var label: String {
        switch self {
        case .awful: return "Awful"
        case .bad: return "Bad"
        case .neutral: return "Neutral"
        case .good: return "Good"
        case .great: return "Great"
        }
    }
}
