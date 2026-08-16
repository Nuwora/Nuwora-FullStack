import Foundation
import Network

protocol NetworkMonitoring: AnyObject {
    var isConnected: Bool { get }
    func start(_ onChange: @escaping (Bool) -> Void)
}

final class NetworkMonitor: NetworkMonitoring {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    private var observers: [(Bool) -> Void] = []
    private var isStarted = false

    private(set) var isConnected: Bool = true

    func start(_ onChange: @escaping (Bool) -> Void) {
        observers.append(onChange)

        guard isStarted == false else { return }
        isStarted = true
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let connected = path.status == .satisfied
            if connected != self.isConnected {
                self.isConnected = connected
                DispatchQueue.main.async {
                    self.observers.forEach { callback in
                        callback(connected)
                    }
                }
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
