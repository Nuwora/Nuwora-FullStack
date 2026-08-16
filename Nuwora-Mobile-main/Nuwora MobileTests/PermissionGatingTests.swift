import XCTest
@testable import Nuwora_Mobile

@MainActor
final class PermissionGatingTests: XCTestCase {
    func testMemberCannotAccessCorporateDashboardAndEventIsLogged() {
        let logger = SpyAnalyticsLogger()
        let store = AppStore(
            dependencies: TestFixtures.appDependencies(networkMonitor: StubNetworkMonitor()),
            currentUserRole: .member,
            analyticsLogger: logger
        )

        let allowed = store.requestCorporateDashboardAccess(source: "unit_test")

        XCTAssertFalse(allowed)
        XCTAssertFalse(store.hasPermission(.viewCorporateDashboard))
        XCTAssertEqual(logger.events.last?.name, "corporate_dashboard_access_denied")
        XCTAssertEqual(logger.events.last?.metadata["role"], UserRole.member.rawValue)
    }

    func testManagerHasCorporateDashboardPermission() {
        let store = AppStore(
            dependencies: TestFixtures.appDependencies(networkMonitor: StubNetworkMonitor()),
            currentUserRole: .manager,
            analyticsLogger: SpyAnalyticsLogger()
        )

        XCTAssertTrue(store.hasPermission(.viewCorporateDashboard))
        XCTAssertTrue(store.requestCorporateDashboardAccess(source: "unit_test"))
    }
}
