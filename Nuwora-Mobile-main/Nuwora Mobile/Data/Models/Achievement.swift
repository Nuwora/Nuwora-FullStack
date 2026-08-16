import Foundation

struct Achievement: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let unlockedAt: Date?

    var isUnlocked: Bool { unlockedAt != nil }
}
