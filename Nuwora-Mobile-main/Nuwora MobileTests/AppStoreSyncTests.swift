import XCTest
@testable import Nuwora_Mobile

@MainActor
final class AppStoreSyncTests: XCTestCase {
    func testReconnectTriggersSyncCommandStateAndAnalyticsEvent() async {
        let monitor = StubNetworkMonitor(isConnected: true)
        let logger = SpyAnalyticsLogger()
        let store = AppStore(
            dependencies: TestFixtures.appDependencies(networkMonitor: monitor),
            currentUserRole: .member,
            analyticsLogger: logger
        )

        monitor.send(false)
        monitor.send(true)

        try? await Task.sleep(for: .milliseconds(120))

        if case .pending = store.syncCommandState {
            XCTAssertEqual(logger.events.last?.name, "cache_sync_triggered_on_reconnect")
        } else {
            XCTFail("Expected pending sync state after reconnect")
        }
    }
}
