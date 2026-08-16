import Foundation

protocol CacheSyncing {
    func startSyncOnReconnect()
}

final class CacheSyncCoordinator: CacheSyncing {
    private let monitor: NetworkMonitoring
    private let onSync: () async -> Void

    init(monitor: NetworkMonitoring, onSync: @escaping () async -> Void) {
        self.monitor = monitor
        self.onSync = onSync
    }

    func startSyncOnReconnect() {
        monitor.start { isConnected in
            guard isConnected else { return }
            Task {
                await self.onSync()
            }
        }
    }
}
