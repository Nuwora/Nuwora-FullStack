import SwiftUI

struct DashboardView: View {
    @Environment(AppStore.self) private var appStore
    @State private var viewModel: DashboardViewModel
    @State private var showMoodSheet = false
    @State private var isRefreshing = false

    init(viewModel: DashboardViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                header

                switch viewModel.viewState {
                case .idle, .loading:
                    NSkeletonView().frame(height: 220)
                    NSkeletonView().frame(height: 180)
                case .empty:
                    NFeatureStatusCard.empty(
                        title: "Nothing planned yet",
                        message: "Your daily plan will appear here after sync."
                    )
                case let .error(error):
                    NFeatureStatusCard.error(error)
                case .loaded:
                    content
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.xl)
            .padding(.bottom, DesignTokens.Layout.contentBottomInset)
        }
        .refreshable {
            isRefreshing = true
            await viewModel.loadDashboard()
            isRefreshing = false
        }
        .task {
            await viewModel.loadDashboardIfNeeded()
        }
        .sheet(isPresented: $showMoodSheet) {
            DashboardMoodSheet { mood in
                Task { await viewModel.logMoodCheckIn(mood) }
                showMoodSheet = false
            }
            .presentationDetents([.height(250)])
            .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.greetingTitle())
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.colorTextSecondary)
                    Text(viewModel.userDisplayName)
                        .font(.nHeading)
                        .foregroundStyle(Color.colorTextPrimary)
                }
                Spacer()
                if viewModel.streakCount > 0 {
                    streakPill
                }
            }
            Text(viewModel.friendlyNudge)
                .font(.subheadline)
                .foregroundStyle(Color.colorTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var streakPill: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundStyle(Color.colorAmber)
                .font(.caption.weight(.bold))
            Text("\(viewModel.streakCount)d")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.colorTextPrimary)
        }
        .padding(.horizontal, DesignTokens.Insets.chipHorizontal + 2)
        .padding(.vertical, DesignTokens.Insets.chipVertical)
        .background(Color.colorAmber.opacity(0.14))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.colorAmber.opacity(0.22), lineWidth: 1))
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            NCommandFeedbackCard(state: appStore.syncCommandState)

            DashboardScoreCard(
                score: viewModel.mindFitnessScore,
                emotionalSummary: viewModel.emotionalSummary,
                lastSyncedText: viewModel.lastSyncedText
            )

            DashboardQuickCardRow(
                planCount: viewModel.dailyPlanPreview.count,
                sleepSummary: viewModel.sleepSummary,
                onOpenMindGym: { appStore.openTab(.mindGym) },
                onOpenCoach: { appStore.openTab(.coach) }
            )

            DashboardMonitoringCard(
                hrvValue: hrvValue,
                focusLevel: focusLevel,
                distractionCount: distractionCount,
                onStartReset: { appStore.openTab(.mindGym) }
            )

            DashboardMoodCard(
                moodLoggedToday: viewModel.moodLoggedToday,
                onOpenMoodSheet: { showMoodSheet = true }
            )

            NCommandFeedbackCard(state: viewModel.moodCommandState)

            if let actionError = viewModel.actionError {
                DashboardActionErrorCard(error: actionError)
            }

            DashboardWorkoutCard(
                exercises: viewModel.dailyPlanPreview,
                onOpenMindGym: { appStore.openTab(.mindGym) }
            )

            if isRefreshing {
                HStack(spacing: 8) {
                    ProgressView().tint(Color.colorTeal)
                    Text("Refreshing your signals...")
                        .font(.caption)
                        .foregroundStyle(Color.colorTextSecondary)
                }
                .padding(.horizontal, DesignTokens.Spacing.xxs)
            }
        }
    }

    private var hrvValue: Int {
        let biometric = viewModel.mindFitnessScore?.biometricScore ?? 60
        return Int(Double(biometric) * 0.52)
    }

    private var focusLevel: Int {
        viewModel.mindFitnessScore?.focusSubscore ?? 68
    }

    private var distractionCount: Int {
        max(1, 6 - (focusLevel / 20))
    }
}

#Preview {
    DashboardView(viewModel: DashboardViewModel(repository: MockDashboardRepository()))
        .environment(AppStore())
}
