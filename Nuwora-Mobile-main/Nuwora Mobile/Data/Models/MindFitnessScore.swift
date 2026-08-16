import Foundation

struct MindFitnessScore: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let overallScore: Int
    let cognitiveScore: Int
    let biometricScore: Int
    let moodScore: Int
    let focusSubscore: Int
    let calmSubscore: Int
    let energySubscore: Int
}
