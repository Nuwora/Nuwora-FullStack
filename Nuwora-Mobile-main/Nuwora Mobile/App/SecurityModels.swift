import Foundation

enum UserRole: String, Codable {
    case member
    case manager
    case admin

    var defaultPermissions: Set<AppPermission> {
        switch self {
        case .member:
            return []
        case .manager, .admin:
            return [.viewCorporateDashboard]
        }
    }
}

enum AppPermission: String, Codable, Hashable {
    case viewCorporateDashboard
}
