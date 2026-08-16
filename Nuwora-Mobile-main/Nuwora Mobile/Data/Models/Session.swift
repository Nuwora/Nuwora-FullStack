import Foundation

struct Session: Identifiable, Codable {
    let id: UUID
    let exerciseID: UUID
    let startedAt: Date
    let endedAt: Date
    let performance: Double
    let earnedXP: Int
}

enum SessionState {
    case idle
    case active
    case complete
}
