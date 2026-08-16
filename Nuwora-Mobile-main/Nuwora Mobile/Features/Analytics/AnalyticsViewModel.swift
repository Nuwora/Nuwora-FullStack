import Foundation
import Observation

@Observable
final class AnalyticsViewModel {
    var scoreHistory: [MindFitnessScore] = []
    var selectedPeriod: AnalyticsPeriod = .week
    var weeklyAISummary: String?
    var correlationInsights: [CorrelationInsight] = []
    var burnoutAlertActive = false
    var viewState: FeatureState<[MindFitnessScore]> = .idle
    private(set) var hasLoadedOnce = false
    private var hasLoadedStaticInsights = false
    private var lastLoadedPeriod: AnalyticsPeriod?

    private let repository: AnalyticsRepository

    init(repository: AnalyticsRepository) {
        self.repository = repository
    }

    func loadAnalytics(for period: AnalyticsPeriod, force: Bool = false) async {
        if force == false, hasLoadedOnce, lastLoadedPeriod == period {
            return
        }

        // Show skeleton only on the very first load. Period changes keep existing
        // content visible so there is no flash when switching Week / Month / 3 Months.
        if !hasLoadedOnce {
            viewState = .loading
        }

        do {
            let scores = try await repository.fetchScores(period: period, page: nil)
            scoreHistory = scores

            if hasLoadedStaticInsights == false || force {
                async let summary = repository.fetchWeeklySummary()
                async let correlations = repository.fetchCorrelationInsights()
                weeklyAISummary = try await summary
                correlationInsights = try await correlations
                hasLoadedStaticInsights = true
            }

            burnoutAlertActive = scoreHistory.count > 4 && scoreHistory.prefix(4).allSatisfy { $0.moodScore < 55 }
            viewState = scoreHistory.isEmpty ? .empty : .loaded(scoreHistory)
            hasLoadedOnce = true
            lastLoadedPeriod = period
        } catch {
            viewState = .error(AppError.loadFailed(feature: "insights", retryHint: "Pull to refresh or try another period."))
        }
    }

    func loadAnalyticsIfNeeded() async {
        guard hasLoadedOnce == false else { return }
        await loadAnalytics(for: selectedPeriod)
    }
}
