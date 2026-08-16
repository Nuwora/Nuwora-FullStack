import Foundation

enum CommandState: Equatable {
    case idle
    case pending(message: String)
    case succeeded(message: String)
    case failed(AppError)

    var isTerminal: Bool {
        switch self {
        case .succeeded, .failed:
            return true
        case .idle, .pending:
            return false
        }
    }
}
