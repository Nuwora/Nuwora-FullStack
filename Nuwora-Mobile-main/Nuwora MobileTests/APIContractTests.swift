import XCTest
@testable import Nuwora_Mobile

@MainActor
final class APIContractTests: XCTestCase {
    func testStableAPIIdentifiersDoNotUseUILabels() {
        XCTAssertEqual(CoachPersona.aria.apiIdentifier, "zen_monk")
        XCTAssertEqual(CoachPersona.max.apiIdentifier, "peak_performer")
        XCTAssertEqual(CoachPersona.zen.apiIdentifier, "neuroscientist")
        XCTAssertEqual(AnalyticsPeriod.threeMonths.apiIdentifier, "three_months")
        XCTAssertEqual(PrimaryGoal.stressRelief.apiIdentifier, "stress_relief")
    }

    func testAPICodingUsesFractionalUTCDateStrings() throws {
        let date = Date(timeIntervalSince1970: 1_787_000_000.123)
        let request = MoodCheckInRequest(mood: 4, occurredAt: date, clientMutationID: UUID())
        let data = try APICoding.makeEncoder().encode(request)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let encodedDate = try XCTUnwrap(object["occurredAt"] as? String)

        XCTAssertTrue(encodedDate.hasSuffix("Z"))
        XCTAssertTrue(encodedDate.contains("."))

        let decoded = try APICoding.makeDecoder().decode(MoodCheckInRequest.self, from: data)
        XCTAssertEqual(decoded.mood, 4)
        XCTAssertEqual(decoded.occurredAt.timeIntervalSince1970, date.timeIntervalSince1970, accuracy: 0.001)
    }

    func testMoodRequestUsesNumericContractValue() throws {
        let request = MoodCheckInRequest(mood: MoodOption.good.rawValue, occurredAt: .now, clientMutationID: UUID())
        let data = try APICoding.makeEncoder().encode(request)
        let body = try APICoding.makeDecoder().decode(MoodCheckInRequest.self, from: data)
        XCTAssertEqual(body.mood, MoodOption.good.rawValue)
    }

    func testCompleteExerciseClampsPerformance() {
        XCTAssertEqual(HTTPPlanDataSource.normalizedPerformance(1.4), 1)
        XCTAssertEqual(HTTPPlanDataSource.normalizedPerformance(-0.2), 0)
    }

    func testOnboardingRepositoryBuildsBackendSafeEnumValues() {
        let submission = OnboardingSubmission(
            name: " Maya ",
            age: 29,
            primaryGoals: [.stressRelief, .focus],
            assessmentAnswers: [3, 4, 5, 2, 4],
            connectedWearables: ["apple_watch"],
            initialScore: 72,
            cognitiveScore: 80,
            biometricScore: 65,
            moodScore: 71
        )

        let body = HTTPOnboardingRepository.makeRequest(from: submission)
        XCTAssertEqual(body.name, "Maya")
        XCTAssertEqual(body.primaryGoals, ["focus", "stress_relief"])
        XCTAssertEqual(body.initialScores.overall, 72)
    }
}
