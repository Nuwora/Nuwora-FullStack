import Foundation

enum XPFormula {
    static func calculate(baseXP: Int, streak: Int, difficulty: Int) -> Int {
        let streakMultiplier = 1.0 + (Double(min(streak, 7)) * 0.1)
        let difficultyFactor = 0.8 + (Double(difficulty) * 0.08)
        return Int((Double(baseXP) * streakMultiplier * difficultyFactor).rounded())
    }
}
