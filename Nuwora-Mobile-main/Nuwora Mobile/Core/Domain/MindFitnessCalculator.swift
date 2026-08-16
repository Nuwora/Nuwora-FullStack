import Foundation

enum MindFitnessCalculator {
    static func calculateOverall(cognitive: Int, biometric: Int, mood: Int) -> Int {
        let weighted = (Double(cognitive) * 0.4) + (Double(biometric) * 0.3) + (Double(mood) * 0.3)
        return Int(weighted.rounded())
    }
}
