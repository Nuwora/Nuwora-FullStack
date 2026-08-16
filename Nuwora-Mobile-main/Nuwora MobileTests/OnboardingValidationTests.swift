import XCTest
@testable import Nuwora_Mobile

final class OnboardingValidationTests: XCTestCase {
    func testWelcomeValidationRejectsInvalidNameAndAge() {
        XCTAssertFalse(OnboardingValidator.isWelcomeStepValid(name: "A", age: "11"))
        XCTAssertNotNil(OnboardingValidator.welcomeValidationMessage(name: "A", age: "11"))
    }

    func testWelcomeValidationAcceptsValidInput() {
        XCTAssertTrue(OnboardingValidator.isWelcomeStepValid(name: "Maya", age: "27"))
        XCTAssertNil(OnboardingValidator.welcomeValidationMessage(name: "Maya", age: "27"))
    }

    func testGoalSelectionRequiresAtLeastOneGoal() {
        XCTAssertFalse(OnboardingValidator.hasAtLeastOneGoal([]))
        XCTAssertTrue(OnboardingValidator.hasAtLeastOneGoal([.focus]))
    }
}
