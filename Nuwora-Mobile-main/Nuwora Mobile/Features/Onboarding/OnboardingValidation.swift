import Foundation

struct OnboardingValidator {
    static func isWelcomeStepValid(name: String, age: String) -> Bool {
        guard let ageValue = Int(age.trimmingCharacters(in: .whitespacesAndNewlines)) else { return false }
        return name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 && (13...100).contains(ageValue)
    }

    static func welcomeValidationMessage(name: String, age: String) -> String? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAge = age.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty && trimmedAge.isEmpty {
            return nil
        }
        if trimmedName.count < 2 {
            return "Enter a valid name (minimum 2 characters)."
        }
        guard let ageValue = Int(trimmedAge), (13...100).contains(ageValue) else {
            return "Enter a valid age between 13 and 100."
        }
        return nil
    }

    static func hasAtLeastOneGoal(_ selectedGoals: Set<PrimaryGoal>) -> Bool {
        selectedGoals.isEmpty == false
    }
}
