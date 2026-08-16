import Foundation
import SwiftData

struct SwiftDataBootstrapResult {
    let container: ModelContainer
    let isDegradedMode: Bool
}

enum SwiftDataStack {
    static func bootstrapContainer(inMemory: Bool = false) -> SwiftDataBootstrapResult {
        let schema = Schema([
            CachedDailyPlan.self,
            CachedExercise.self,
            CachedMindFitnessScore.self,
            CachedChatMessage.self
        ])

        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            return SwiftDataBootstrapResult(container: container, isDegradedMode: inMemory)
        } catch {
            let fallbackConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                let fallbackContainer = try ModelContainer(for: schema, configurations: [fallbackConfiguration])
                LocalAnalyticsLogger.shared.track(
                    LocalAnalyticsEvent(
                        name: "swiftdata_init_failed_fallback_memory",
                        metadata: ["error": String(describing: error)],
                        timestamp: .now
                    )
                )
                return SwiftDataBootstrapResult(container: fallbackContainer, isDegradedMode: true)
            } catch {
                preconditionFailure("Failed to bootstrap any SwiftData container: \(error)")
            }
        }
    }
}
