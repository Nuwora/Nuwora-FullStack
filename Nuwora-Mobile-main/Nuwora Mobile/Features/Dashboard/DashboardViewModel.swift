import Foundation
import Observation

@Observable
final class DashboardViewModel {
    var mindFitnessScore: MindFitnessScore?
    var dailyPlanPreview: [Exercise] = []
    var streakCount = 0
    var currentLevel = 1
    var xpProgress = 0.0
    var aiInsight: String?
    var isLoading = false
    var viewState: FeatureState<DashboardSnapshot> = .idle
    var lastSyncedText = ""
    var userDisplayName = ""
    var sleepSummary = "7h 22m last night"
    var emotionalSummary = "Your focus is improving."
    var friendlyNudge = "Try a quick 2-min reset."
    var moodLoggedToday = false
    var actionError: AppError?
    var moodCommandState: CommandState = .idle
    private(set) var hasLoadedOnce = false

    private let repository: DashboardRepository
    private let profileRepository: ProfileRepository

    enum Action {
        case loadStarted
        case loadSucceeded(DashboardSnapshot)
        case loadFailed(AppError)
    }

    init(repository: DashboardRepository, profileRepository: ProfileRepository = MockProfileRepository()) {
        self.repository = repository
        self.profileRepository = profileRepository
    }

    func send(_ action: Action) {
        reduce(action)
    }

    func loadDashboard() async {
        send(.loadStarted)
        do {
            let snapshot = try await repository.fetchDashboard()
            send(.loadSucceeded(snapshot))
            hasLoadedOnce = true
        } catch {
            send(.loadFailed(AppError.loadFailed(feature: "dashboard")))
        }
        await loadDisplayName()
    }

    private func loadDisplayName() async {
        // Best-effort: the greeting still works from the dashboard snapshot
        // alone, so a profile-fetch failure here shouldn't surface as an error.
        guard let profile = try? await profileRepository.fetchProfile(),
              profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        else { return }
        userDisplayName = profile.name
    }

    func loadDashboardIfNeeded() async {
        guard hasLoadedOnce == false else { return }
        await loadDashboard()
    }

    func logMoodCheckIn(_ mood: MoodOption) async {
        moodCommandState = .pending(message: "Saving your mood check-in...")
        do {
            try await repository.logMood(mood)
            moodLoggedToday = true
            actionError = nil
            moodCommandState = .succeeded(message: "Mood check-in saved.")
            emotionalSummary = "Thanks for checking in. Small steps count."
            scheduleCommandStateReset()
        } catch {
            moodLoggedToday = false
            let appError = AppError.fallback(error, or: AppError.saveFailed(action: "save your mood check-in"))
            actionError = appError
            moodCommandState = .failed(appError)
        }
    }

    func greetingTitle(now: Date = .now) -> String {
        let hour = Calendar.current.component(.hour, from: now)
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<18:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }

    private func reduce(_ action: Action) {
        switch action {
        case .loadStarted:
            isLoading = true
            viewState = .loading
        case let .loadSucceeded(snapshot):
            isLoading = false
            mindFitnessScore = snapshot.score
            dailyPlanPreview = snapshot.planPreview
            streakCount = snapshot.streakCount
            currentLevel = snapshot.currentLevel
            xpProgress = snapshot.xpProgress
            aiInsight = snapshot.aiInsight
            lastSyncedText = RelativeDateTimeFormatter().localizedString(for: snapshot.lastSyncDate, relativeTo: .now)
            emotionalSummary = snapshot.score.overallScore >= 75 ? "Your focus is improving." : "Let's stay gentle and steady today."
            if snapshot.streakCount <= 1 {
                friendlyNudge = "You've missed a bit - try a quick 2-min reset?"
            } else {
                friendlyNudge = snapshot.score.overallScore < 65 ? "Try a quick 2-min reset?" : "Keep your momentum with one short session."
            }
            viewState = snapshot.planPreview.isEmpty ? .empty : .loaded(snapshot)
        case let .loadFailed(error):
            isLoading = false
            viewState = .error(error)
        }
    }

    private func scheduleCommandStateReset() {
        Task {
            do {
                try await Task.sleep(for: .seconds(2.5))
            } catch {
                return
            }
            if case .succeeded = moodCommandState {
                moodCommandState = .idle
            }
        }
    }
}
