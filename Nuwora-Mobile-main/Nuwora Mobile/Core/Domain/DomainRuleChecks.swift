import Foundation

enum DomainRuleChecks {
    static func runInDebug() {
        #if DEBUG
        assert(MindFitnessCalculator.calculateOverall(cognitive: 80, biometric: 70, mood: 60) == 71)
        assert(XPFormula.calculate(baseXP: 100, streak: 3, difficulty: 4) == 146)

        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)
        let old = Calendar.current.date(byAdding: .day, value: -3, to: now)
        assert(StreakPolicy.nextStreak(previousStreak: 5, lastActivity: yesterday, currentDate: now) == 6)
        assert(StreakPolicy.nextStreak(previousStreak: 5, lastActivity: old, currentDate: now) == 1)

        assert(SafetyKeywordDetector.detectLevel(for: "I feel hopeless") == .watch)
        assert(SafetyKeywordDetector.detectLevel(for: "I want to end my life") == .urgent)
        assert(SafetyKeywordDetector.detectLevel(for: "I had a productive day") == .none)
        #endif
    }
}
