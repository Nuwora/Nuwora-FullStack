import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    let sender: MessageSender
    let timestamp: Date
    var isTyping: Bool = false
}

enum MessageSender: String, Codable {
    case user
    case coach
}

enum CoachPersona: String, CaseIterable, Codable {
    case aria = "ZEN"
    case zen = "PRO"
    case max = "MAX"

    var displayName: String {
        switch self {
        case .aria: return "Zen Monk"
        case .max: return "Peak Performer"
        case .zen: return "Neuroscientist"
        }
    }

    var tagline: String {
        switch self {
        case .aria: return "Calm, grounded guidance"
        case .max: return "Focused, high-energy coaching"
        case .zen: return "Data-driven emotional clarity"
        }
    }

    var toneLabel: String {
        switch self {
        case .aria: return "Calm Focus"
        case .max: return "Peak Drive"
        case .zen: return "Analytical Clarity"
        }
    }
}
