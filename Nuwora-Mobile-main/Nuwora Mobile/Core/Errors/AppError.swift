import Foundation

enum AppErrorCode: String, Codable, Equatable {
    case accessDenied
    case network
    case storage
    case invalidResponse
    case writeFailed
    case unknown
}

struct AppError: Error, Codable, Equatable {
    let code: AppErrorCode
    let message: String
    let retryHint: String

    init(code: AppErrorCode, message: String, retryHint: String = "Please try again.") {
        self.code = code
        self.message = message
        self.retryHint = retryHint
    }

    static func accessDenied(
        message: String = "You do not have permission for this section.",
        retryHint: String = "Contact your administrator if this seems incorrect."
    ) -> AppError {
        AppError(code: .accessDenied, message: message, retryHint: retryHint)
    }

    static func loadFailed(feature: String, retryHint: String = "Pull to refresh when your connection stabilizes.") -> AppError {
        AppError(code: .network, message: "Failed to load \(feature).", retryHint: retryHint)
    }

    static func saveFailed(action: String, retryHint: String = "Please try again in a moment.") -> AppError {
        AppError(code: .writeFailed, message: "Could not \(action).", retryHint: retryHint)
    }

    static func fallback(_ error: Error, or fallback: AppError) -> AppError {
        if let mapped = error as? AppError {
            return mapped
        }
        return fallback
    }
}
