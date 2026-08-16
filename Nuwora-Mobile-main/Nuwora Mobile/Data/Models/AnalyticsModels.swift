import Foundation

struct CorrelationInsight: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let strength: Double
}

enum AnalyticsPeriod: String, CaseIterable, Codable {
    case week = "Week"
    case month = "Month"
    case threeMonths = "3 Months"
}
