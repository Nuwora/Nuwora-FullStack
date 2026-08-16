import Charts
import SwiftUI

struct CorporateDashboardView: View {
    @Environment(AppStore.self) private var appStore
    @State private var hasLoggedDeniedAccess = false

    private let readiness = 78
    private let trend: [TeamTrendPoint] = [
        TeamTrendPoint(day: "Mon", readiness: 71, focus: 69),
        TeamTrendPoint(day: "Tue", readiness: 73, focus: 72),
        TeamTrendPoint(day: "Wed", readiness: 76, focus: 74),
        TeamTrendPoint(day: "Thu", readiness: 77, focus: 75),
        TeamTrendPoint(day: "Fri", readiness: 78, focus: 76)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if appStore.hasPermission(.viewCorporateDashboard) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                            header
                            readinessCard
                            trendsCard
                            anonymizedMetricsCard
                            integrationsCard
                        }
                        .padding(.horizontal, DesignTokens.Spacing.lg)
                        .padding(.top, DesignTokens.Spacing.xl)
                        .padding(.bottom, DesignTokens.Spacing.xl)
                    }
                } else {
                    accessDeniedState
                }
            }
            .navigationTitle("Corporate Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                guard appStore.hasPermission(.viewCorporateDashboard) == false else { return }
                guard hasLoggedDeniedAccess == false else { return }
                hasLoggedDeniedAccess = true
                appStore.auditDeniedAccess(source: "corporate_dashboard_direct_entry")
            }
        }
    }

    private var accessDeniedState: some View {
        VStack {
            NCard(glow: .colorAmber) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Access denied")
                        .font(.headline)
                        .foregroundStyle(Color.colorAmber)
                    Text("Corporate analytics are available only to authorized manager and admin roles.")
                        .font(.subheadline)
                        .foregroundStyle(Color.colorTextSecondary)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.xl)
            Spacer()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Mental Readiness Overview")
                .font(.nHeading)
                .foregroundStyle(Color.colorTextPrimary)
            Text("Anonymized team wellbeing and cognitive readiness trends")
                .font(.subheadline)
                .foregroundStyle(Color.colorTextSecondary)
        }
    }

    private var readinessCard: some View {
        NCard(glow: .colorTeal) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Mental Readiness Index")
                    .font(.headline)
                    .foregroundStyle(Color.colorTextPrimary)

                HStack(alignment: .bottom) {
                    Text("\(readiness)")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(Color.colorTextPrimary)
                    Text("/100")
                        .font(.headline)
                        .foregroundStyle(Color.colorTextSecondary)
                    Spacer()
                    Text("+4 this week")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.colorGreen)
                }

                ProgressView(value: Double(readiness) / 100)
                    .tint(.colorTeal)
            }
        }
    }

    private var trendsCard: some View {
        NCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Performance Trends")
                    .font(.headline)
                    .foregroundStyle(Color.colorTextPrimary)

                Chart(trend) { point in
                    LineMark(
                        x: .value("Day", point.day),
                        y: .value("Readiness", point.readiness)
                    )
                    .foregroundStyle(Color.colorTeal)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))

                    LineMark(
                        x: .value("Day", point.day),
                        y: .value("Focus", point.focus)
                    )
                    .foregroundStyle(Color.colorPurple)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                }
                .chartYScale(domain: 55 ... 100)
                .frame(height: 180)
            }
        }
    }

    private var anonymizedMetricsCard: some View {
        NCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Anonymized Team Metrics")
                    .font(.headline)
                    .foregroundStyle(Color.colorTextPrimary)

                metricRow(title: "Avg Focus Stability", value: "76%", tint: .colorGreen)
                metricRow(title: "Avg Stress Volatility", value: "-9%", tint: .colorTeal)
                metricRow(title: "Recovery Quality", value: "72%", tint: .colorPurple)
                metricRow(title: "Sleep Consistency", value: "68%", tint: .colorTeal)
            }
        }
    }

    private func metricRow(title: String, value: String, tint: Color) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color.colorTextSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
        }
    }

    private var integrationsCard: some View {
        NCard(glow: .colorPurple) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Integrations")
                    .font(.headline)
                    .foregroundStyle(Color.colorTextPrimary)

                HStack(spacing: 10) {
                    integrationChip(title: "Slack", symbol: "bubble.left.and.bubble.right.fill")
                    integrationChip(title: "Teams", symbol: "person.3.sequence")
                }

                Text("Weekly summaries can be pushed to your existing communication stack.")
                    .font(.caption)
                    .foregroundStyle(Color.colorTextSecondary)
            }
        }
    }

    private func integrationChip(title: String, symbol: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.caption)
                .foregroundStyle(Color.colorTeal)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.colorTextPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.appCard.opacity(0.7))
        .clipShape(Capsule())
    }
}

private struct TeamTrendPoint: Identifiable {
    let id = UUID()
    let day: String
    let readiness: Int
    let focus: Int
}

#Preview {
    CorporateDashboardView()
}
