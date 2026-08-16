import Foundation

struct DailyPlan: Codable {
    let date: Date
    let exercises: [Exercise]
    let estimatedMinutes: Int
    let difficulty: String
}
