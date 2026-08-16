import Foundation
import SwiftData

@Model
final class CachedDailyPlan {
    @Attribute(.unique) var date: Date
    var exercises: [CachedExercise]
    var generatedAt: Date

    init(date: Date, exercises: [CachedExercise], generatedAt: Date) {
        self.date = date
        self.exercises = exercises
        self.generatedAt = generatedAt
    }
}

@Model
final class CachedExercise {
    @Attribute(.unique) var id: UUID
    var title: String
    var subtitle: String
    var type: String
    var durationSeconds: Int
    var difficulty: Int
    var xpReward: Int
    var isCompleted: Bool

    init(id: UUID, title: String, subtitle: String, type: String, durationSeconds: Int, difficulty: Int, xpReward: Int, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.durationSeconds = durationSeconds
        self.difficulty = difficulty
        self.xpReward = xpReward
        self.isCompleted = isCompleted
    }
}

@Model
final class CachedMindFitnessScore {
    @Attribute(.unique) var date: Date
    var overallScore: Int
    var cognitiveScore: Int
    var biometricScore: Int
    var moodScore: Int
    var focusSubscore: Int
    var calmSubscore: Int
    var energySubscore: Int

    init(date: Date, overallScore: Int, cognitiveScore: Int, biometricScore: Int, moodScore: Int, focusSubscore: Int, calmSubscore: Int, energySubscore: Int) {
        self.date = date
        self.overallScore = overallScore
        self.cognitiveScore = cognitiveScore
        self.biometricScore = biometricScore
        self.moodScore = moodScore
        self.focusSubscore = focusSubscore
        self.calmSubscore = calmSubscore
        self.energySubscore = energySubscore
    }
}

@Model
final class CachedChatMessage {
    @Attribute(.unique) var id: UUID
    var content: String
    var sender: String
    var timestamp: Date
    var personaID: String

    init(id: UUID = UUID(), content: String, sender: String, timestamp: Date, personaID: String) {
        self.id = id
        self.content = content
        self.sender = sender
        self.timestamp = timestamp
        self.personaID = personaID
    }
}
