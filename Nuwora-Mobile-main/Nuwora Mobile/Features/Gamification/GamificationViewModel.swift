import Foundation
import Observation

@Observable
final class GamificationViewModel {
    var userProfile: User?
    var achievements: [Achievement] = []
    var leaderboardPreview: [LeaderboardEntry] = []
    var neuroTreeStage = 0
    var viewState: FeatureState<User> = .idle
    private(set) var hasLoadedOnce = false

    private let repository: ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }

    func loadProfile() async {
        viewState = .loading
        do {
            async let profile = repository.fetchProfile()
            async let loadedAchievements = repository.fetchAchievements()
            async let leaderboard = repository.fetchLeaderboardPreview()

            userProfile = try await profile
            achievements = try await loadedAchievements
            leaderboardPreview = try await leaderboard

            let level = userProfile?.currentLevel ?? 1
            neuroTreeStage = min(10, max(0, level))
            viewState = userProfile == nil ? .empty : .loaded(userProfile!)
            hasLoadedOnce = true
        } catch {
            viewState = .error(AppError.loadFailed(feature: "profile", retryHint: "Try reopening Profile."))
        }
    }

    func loadProfileIfNeeded() async {
        guard hasLoadedOnce == false else { return }
        await loadProfile()
    }
}
