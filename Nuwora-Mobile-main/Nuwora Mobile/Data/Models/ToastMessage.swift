import Foundation

enum ToastKind {
    case success
    case warning
    case info
}

struct ToastMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let kind: ToastKind
}
