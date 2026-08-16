import Charts
import SwiftUI

struct InsightsView: View {
    @Environment(AppStore.self) private var appStore
    @State private var viewModel: AnalyticsViewModel
    @State private var showCorporateDashboard = false
    @State private var hasRequestedInitialLoad = false
    @State private var periodLoadTask: Task<Void, Never>?

    init(viewModel: AnalyticsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        let viewState = viewModel.viewState
        let scoreHistory = viewModel.scoreHistory
        let weeklySummary = viewModel.weeklyAISummary
        let burnoutAlertActive = viewModel.burnoutAlertActive
        let correlationInsights = viewModel.correlationInsights

        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                header
                periodPicker

                switch viewState {
                case .idle, .loading:
                    NSkeletonView().frame(height: 240)
                    NSkeletonView().frame(height: 180)
                case .empty:
                    NFeatureStatusCard.empty(
                        title: "Not enough data yet",
                        message: "Keep going and your trend insights will appear here."
                    )
                case let .error(error):
                    NFeatureStatusCard.error(error)
                case .loaded:
                    scoreChartCard(scoreHistory: scoreHistory)
                    metricsRow
                    summaryCard(summary: weeklySummary, burnoutAlertActive: burnoutAlertActive)
                    correlationSection(correlationInsights: correlationInsights)
                    teamCard
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.xl)
            .padding(.bottom, DesignTokens.Layout.contentBottomInset)
        }
        .sheet(isPresented: $showCorporateDashboard) {
            CorporateDashboardView()
        }
        .task {
            guard hasRequestedInitialLoad == false else { return }
            hasRequestedInitialLoad = true
            await viewModel.loadAnalyticsIfNeeded()
        }
        .onDisappear {
            periodLoadTask?.cancel()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Insights")
                .font(.nHeading)
                .foregroundStyle(Color.colorTextPrimary)
            Text("Understand how your mind adapts over time")
                .font(.subheadline)
                .foregroundStyle(Color.colorTextSecondary)
        }
    }

    private var periodPicker: some View {
        NCard {
            Picker("Period", selection: $viewModel.selectedPeriod) {
                ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .tint(Color.colorTeal)
            .onChange(of: viewModel.selectedPeriod) { _, newValue in
                loadPeriod(newValue)
            }
        }
    }

    private func scoreChartCard(scoreHistory: [MindFitnessScore]) -> some View {
        MindFitnessChartCard(scoreHistory: scoreHistory)
            .equatable()
    }

    private var metricsRow: some View {
        HStack(spacing: 10) {
            ForEach(Self.metrics) { metric in
                metricCard(title: metric.title, value: metric.value, icon: metric.icon, tint: metric.tint)
            }
        }
    }

    private func metricCard(title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color.colorTextSecondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.colorTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignTokens.Insets.cardCompact)
        .background(Color.colorSurface.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.standard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.standard, style: .continuous)
                .stroke(Color.colorBorder, lineWidth: 1)
        )
    }

    private func summaryCard(summary: String?, burnoutAlertActive: Bool) -> some View {
        NCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Weekly Summary", systemImage: "sparkles")
                    .foregroundStyle(Color.colorGreen)
                    .font(.headline)

                Text(summary ?? "Your resilience improved this week. Great consistency.")
                    .foregroundStyle(Color.colorTextPrimary)
                    .font(.subheadline)

                if burnoutAlertActive {
                    Text("Burnout trend detected. Consider reducing cognitive intensity tomorrow.")
                        .font(.caption)
                        .foregroundStyle(Color.colorAmber)
                        .padding(.top, DesignTokens.Spacing.xxs)
                }
            }
        }
    }

    private func correlationSection(correlationInsights: [CorrelationInsight]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Correlation Insights")
                .font(.headline)
                .foregroundStyle(Color.colorTextPrimary)

            LazyVStack(spacing: 10) {
                ForEach(correlationInsights) { insight in
                    CorrelationInsightCard(insight: insight)
                        .equatable()
                }
            }

            NCard {
                Text("Your best focus days follow 7+ hours of sleep.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.colorTextPrimary)
            }
        }
    }

    private var teamCard: some View {
        NCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Team & Corporate")
                    .font(.headline)
                    .foregroundStyle(Color.colorTextPrimary)
                Text("Open anonymized team analytics and Mental Readiness Index.")
                    .font(.subheadline)
                    .foregroundStyle(Color.colorTextSecondary)

                if appStore.hasPermission(.viewCorporateDashboard) {
                    NButton(title: "Open Corporate Dashboard", style: .secondary) {
                        if appStore.requestCorporateDashboardAccess(source: "insights_team_card") {
                            showCorporateDashboard = true
                        }
                    }
                    .accessibilityHint("Opens anonymized team analytics for authorized roles.")
                } else {
                    Text("Corporate analytics require manager or admin access.")
                        .font(.caption)
                        .foregroundStyle(Color.colorTextTertiary)
                }
            }
        }
    }

    private func loadPeriod(_ period: AnalyticsPeriod) {
        periodLoadTask?.cancel()
        periodLoadTask = Task {
            await viewModel.loadAnalytics(for: period)
        }
    }

    private static let metrics: [InsightMetric] = [
        InsightMetric(id: "focus", title: "Focus", value: "+11%", icon: "scope", tint: .colorGreen),
        InsightMetric(id: "calm", title: "Calm", value: "+14%", icon: "drop", tint: .colorTeal),
        InsightMetric(id: "sleep", title: "Sleep", value: "+1h", icon: "moon.zzz", tint: .colorPurple),
        InsightMetric(id: "recovery", title: "Recovery", value: "+9%", icon: "heart", tint: .colorGreen)
    ]
}

private struct InsightMetric: Identifiable {
    let id: String
    let title: String
    let value: String
    let icon: String
    let tint: Color
}

private struct MindFitnessChartCard: View, Equatable {
    let scoreHistory: [MindFitnessScore]

    private var dateRangeLabel: String {
        guard let newest = scoreHistory.first, let oldest = scoreHistory.last else { return "" }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return "\(f.string(from: oldest.date)) – \(f.string(from: newest.date))"
    }

    var body: some View {
        NCard(glow: .colorTeal) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Mind Fitness Score")
                        .foregroundStyle(Color.colorTextPrimary)
                        .font(.headline)
                    Spacer()
                    if !dateRangeLabel.isEmpty {
                        Text(dateRangeLabel)
                            .font(.caption)
                            .foregroundStyle(Color.colorTextSecondary)
                    }
                }

                Chart(scoreHistory) { point in
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Score", point.overallScore)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.colorTeal.opacity(0.28), Color.colorTeal.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Score", point.overallScore)
                    )
                    .foregroundStyle(Color.colorTeal)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .interpolationMethod(.catmullRom)
                }
                .chartYScale(domain: 0 ... 100)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.colorBorder)
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            .foregroundStyle(Color.colorTextTertiary)
                            .font(.system(size: 10))
                    }
                }
                .chartYAxis {
                    AxisMarks(values: [0, 25, 50, 75, 100]) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.colorBorder)
                        AxisValueLabel()
                            .foregroundStyle(Color.colorTextTertiary)
                            .font(.system(size: 10))
                    }
                }
                .frame(height: 200)
                .animation(.nuworaSpring, value: scoreHistory)
            }
        }
    }
}

private struct CorrelationInsightCard: View, Equatable {
    let insight: CorrelationInsight

    var body: some View {
        NCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(insight.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.colorTextPrimary)
                Text(insight.description)
                    .font(.caption)
                    .foregroundStyle(Color.colorTextSecondary)

                ProgressView(value: insight.strength)
                    .tint(.colorTeal)
            }
        }
    }
}

#Preview {
    InsightsView(viewModel: AnalyticsViewModel(repository: MockAnalyticsRepository()))
}
