import Foundation
import HealthKit
import Observation

enum SleepQuality: String, Codable {
    case poor
    case fair
    case good
    case excellent
}

struct SleepSummary: Codable {
    let hours: Double
    let quality: SleepQuality
}

protocol HealthKitManaging {
    var isAuthorized: Bool { get }
    var latestHRV: Double? { get }
    var latestHeartRate: Double? { get }
    var lastNightSleepHours: Double? { get }
    var sleepQuality: SleepQuality? { get }

    func requestAuthorization() async throws
    func fetchLatestHRV() async -> Double?
    func fetchHeartRate() async -> Double?
    func fetchSleepData(for date: Date) async -> SleepSummary?
    func startLiveHRVSession() -> AsyncStream<Double>
}

@Observable
final class HealthKitManager: HealthKitManaging {
    var isAuthorized = false
    var latestHRV: Double?
    var latestHeartRate: Double?
    var lastNightSleepHours: Double?
    var sleepQuality: SleepQuality?

    private let store = HKHealthStore()

    func requestAuthorization() async throws {
        let readTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            store.requestAuthorization(toShare: [], read: readTypes) { [weak self] success, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                self?.isAuthorized = success
                continuation.resume(returning: ())
            }
        }
    }

    func fetchLatestHRV() async -> Double? {
        latestHRV
    }

    func fetchHeartRate() async -> Double? {
        latestHeartRate
    }

    func fetchSleepData(for _: Date) async -> SleepSummary? {
        guard let lastNightSleepHours, let sleepQuality else { return nil }
        return SleepSummary(hours: lastNightSleepHours, quality: sleepQuality)
    }

    func startLiveHRVSession() -> AsyncStream<Double> {
        AsyncStream { continuation in
            continuation.yield(latestHRV ?? 0)
            continuation.finish()
        }
    }
}

@Observable
final class MockHealthKitManager: HealthKitManaging {
    var isAuthorized = true
    var latestHRV: Double? = 42
    var latestHeartRate: Double? = 63
    var lastNightSleepHours: Double? = 7.2
    var sleepQuality: SleepQuality? = .good

    func requestAuthorization() async throws {}
    func fetchLatestHRV() async -> Double? { latestHRV }
    func fetchHeartRate() async -> Double? { latestHeartRate }
    func fetchSleepData(for _: Date) async -> SleepSummary? {
        SleepSummary(hours: 7.2, quality: .good)
    }

    func startLiveHRVSession() -> AsyncStream<Double> {
        AsyncStream { continuation in
            let values = [40.0, 41.5, 42.0, 43.2]
            values.forEach { continuation.yield($0) }
            continuation.finish()
        }
    }
}
