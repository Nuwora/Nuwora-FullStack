import Foundation
import Observation
import SwiftUI

@Observable
final class AppStore {
    var route: AppRoute = .auth
    var selectedTab: TabItem = .home
    var toastMessage: ToastMessage?
    var isOnline = true
    var degradedMode = false
    var syncCommandState: CommandState = .idle
    private(set) var currentUserRole: UserRole
    private(set) var permissions: Set<AppPermission>

    let dependencies: AppDependencies
    private let analyticsLogger: LocalAnalyticsLogging
    private var cacheSyncCoordinator: CacheSyncing?

    init(
        dependencies: AppDependencies = .mock,
        currentUserRole: UserRole = .member,
        degradedMode: Bool = false,
        analyticsLogger: LocalAnalyticsLogging = LocalAnalyticsLogger.shared
    ) {
        self.dependencies = dependencies
        self.currentUserRole = currentUserRole
        self.permissions = currentUserRole.defaultPermissions
        self.degradedMode = degradedMode
        self.analyticsLogger = analyticsLogger

        dependencies.networkMonitor.start { [weak self] connected in
            guard let self else { return }
            self.isOnline = connected
            if connected {
                self.toastMessage = ToastMessage(text: "Back online - checking for updates", kind: .success)
            } else {
                self.toastMessage = ToastMessage(text: "You're offline - using cached data", kind: .warning)
                self.syncCommandState = .idle
            }
            Task { @MainActor in
                do {
                    try await Task.sleep(for: .seconds(2.5))
                } catch {
                    return
                }
                self.toastMessage = nil
            }
        }

        cacheSyncCoordinator = CacheSyncCoordinator(monitor: dependencies.networkMonitor) { [weak self] in
            guard let self else { return }
            await self.handleReconnectSync()
        }

        cacheSyncCoordinator?.startSyncOnReconnect()

        if degradedMode {
            showToast("Storage degraded mode enabled. Some data may be temporary.", kind: .warning)
            analyticsLogger.track(
                LocalAnalyticsEvent(
                    name: "storage_degraded_mode_enabled",
                    metadata: ["source": "swiftdata_bootstrap_fallback"],
                    timestamp: .now
                )
            )
        }
    }

    func completeAuth() {
        withAnimation(.nuworaPageSpring) {
            route = .onboarding
        }
    }

    func logOut() {
        withAnimation(.nuworaPageSpring) {
            route = .auth
        }
        Task {
            await dependencies.credentialAuthClient.logout()
        }
    }

    func finishOnboarding() {
        withAnimation(.nuworaPageSpring) {
            route = .main
        }
        Task {
            do {
                try await dependencies.healthKitManager.requestAuthorization()
                analyticsLogger.track(
                    LocalAnalyticsEvent(
                        name: "healthkit_auth_requested",
                        metadata: ["result": "success"],
                        timestamp: .now
                    )
                )
            } catch {
                analyticsLogger.track(
                    LocalAnalyticsEvent(
                        name: "healthkit_auth_requested",
                        metadata: ["result": "failed", "error": String(describing: error)],
                        timestamp: .now
                    )
                )
                showToast("Health data access not granted. You can enable it later in Settings.", kind: .info)
            }
        }
    }

    func openTab(_ tab: TabItem) {
        withAnimation(.nuworaPageSpring) {
            selectedTab = tab
        }
    }

    func hasPermission(_ permission: AppPermission) -> Bool {
        permissions.contains(permission)
    }

    func setCurrentUserRole(_ role: UserRole) {
        currentUserRole = role
        permissions = role.defaultPermissions
    }

    func requestCorporateDashboardAccess(source: String) -> Bool {
        guard hasPermission(.viewCorporateDashboard) else {
            auditDeniedAccess(source: source)
            showToast("Access denied: corporate dashboard is restricted.", kind: .warning)
            return false
        }
        return true
    }

    func auditDeniedAccess(source: String) {
        analyticsLogger.track(
            LocalAnalyticsEvent(
                name: "corporate_dashboard_access_denied",
                metadata: [
                    "role": currentUserRole.rawValue,
                    "source": source
                ],
                timestamp: .now
            )
        )
    }

    private func showToast(_ text: String, kind: ToastKind) {
        toastMessage = ToastMessage(text: text, kind: kind)
        Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(3))
            } catch {
                return
            }
            if toastMessage?.text == text {
                toastMessage = nil
            }
        }
    }

    private func handleReconnectSync() async {
        syncCommandState = .pending(message: "Syncing cached data...")
        analyticsLogger.track(
            LocalAnalyticsEvent(
                name: "cache_sync_triggered_on_reconnect",
                metadata: [:],
                timestamp: .now
            )
        )

        do {
            try await Task.sleep(for: .seconds(0.8))
        } catch {
            return
        }

        syncCommandState = .succeeded(message: "Cached data synced.")
        do {
            try await Task.sleep(for: .seconds(2))
        } catch {
            return
        }
        if case .succeeded = syncCommandState {
            syncCommandState = .idle
        }
    }
}
