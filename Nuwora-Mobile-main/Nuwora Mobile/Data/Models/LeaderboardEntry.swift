import Foundation

struct LeaderboardEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let rank: Int
    let alias: String
    let score: Int
}
