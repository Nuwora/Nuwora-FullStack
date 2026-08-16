import XCTest
@testable import Nuwora_Mobile

@MainActor
final class AppDependenciesTests: XCTestCase {
    func testMakeStagingReadyEnvironmentUsesStagingFlag() {
        let dependencies = AppDependencies.make(environment: .stagingReady)

        XCTAssertEqual(dependencies.environment, .stagingReady)
    }
}
