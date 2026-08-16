import Foundation

struct LocalAnalyticsEvent: Codable, Equatable {
    let name: String
    let metadata: [String: String]
    let timestamp: Date
}

protocol LocalAnalyticsLogging {
    func track(_ event: LocalAnalyticsEvent)
}

final class LocalAnalyticsLogger: LocalAnalyticsLogging {
    static let shared = LocalAnalyticsLogger()

    private(set) var events: [LocalAnalyticsEvent] = []

    private init() {}

    func track(_ event: LocalAnalyticsEvent) {
        events.append(event)
        #if DEBUG
        print("[Analytics] \(event.name) \(event.metadata)")
        #endif
    }
}
