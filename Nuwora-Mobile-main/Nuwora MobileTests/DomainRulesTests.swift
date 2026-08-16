import XCTest
@testable import Nuwora_Mobile

final class DomainRulesTests: XCTestCase {
    func testMindFitnessCalculatorWeightedScore() {
        let score = MindFitnessCalculator.calculateOverall(cognitive: 80, biometric: 70, mood: 60)
        XCTAssertEqual(score, 71)
    }

    func testXPFormulaCapsStreakAtSeven() {
        let withHugeStreak = XPFormula.calculate(baseXP: 100, streak: 99, difficulty: 4)
        let withMaxStreak = XPFormula.calculate(baseXP: 100, streak: 7, difficulty: 4)
        XCTAssertEqual(withHugeStreak, withMaxStreak)
    }

    func testStreakPolicyResetsAfterTwoDaysGap() {
        let now = Date()
        let old = Calendar.current.date(byAdding: .day, value: -3, to: now)
        XCTAssertEqual(StreakPolicy.nextStreak(previousStreak: 5, lastActivity: old, currentDate: now), 1)
    }

    func testSafetyKeywordDetectorLevels() {
        XCTAssertEqual(SafetyKeywordDetector.detectLevel(for: "I feel hopeless today"), .watch)
        XCTAssertEqual(SafetyKeywordDetector.detectLevel(for: "I want to end my life"), .urgent)
        XCTAssertEqual(SafetyKeywordDetector.detectLevel(for: "I had a productive day"), .none)
    }
}
