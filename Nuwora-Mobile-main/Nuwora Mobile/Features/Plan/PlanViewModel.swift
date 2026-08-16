import Foundation
import Observation

@Observable
final class PlanViewModel {
    var exercises: [Exercise] = []
    var completedExerciseIDs: Set<UUID> = []
    var currentExercise: Exercise?
    var sessionState: SessionState = .idle
    var viewState: FeatureState<[Exercise]> = .idle
    var showCoachReflectionPrompt = false
    var actionError: AppError?
    var sessionCommandState: CommandState = .idle
    private(set) var hasLoadedOnce = false

    private let repository: PlanRepository

    enum Action {
        case loadStarted
        case loadSucceeded([Exercise])
        case loadFailed(AppError)
        case exerciseStarted(Exercise)
        case exerciseCompleted(UUID)
    }

    init(repository: PlanRepository) {
        self.repository = repository
    }

    func send(_ action: Action) {
        reduce(action)
    }

    func loadPlan() async {
        send(.loadStarted)
        do {
            let loaded = try await repository.fetchTodayPlan()
            send(.loadSucceeded(loaded))
            hasLoadedOnce = true
        } catch {
            send(.loadFailed(AppError.loadFailed(feature: "your plan", retryHint: "Try again after reconnecting.")))
        }
    }

    func loadPlanIfNeeded() async {
        guard hasLoadedOnce == false else { return }
        await loadPlan()
    }

    func startExercise(_ exercise: Exercise) {
        send(.exerciseStarted(exercise))
    }

    func completeExercise(performance: Double) async {
        guard let currentExercise else { return }
        sessionCommandState = .pending(message: "Saving session progress...")
        do {
            try await repository.markComplete(exerciseID: currentExercise.id, performance: performance)
            actionError = nil
            send(.exerciseCompleted(currentExercise.id))
            sessionCommandState = .succeeded(message: "Session progress saved.")
            scheduleCommandStateReset()
        } catch {
            let appError = AppError.fallback(
                error,
                or: AppError.saveFailed(action: "save exercise progress", retryHint: "Please retry this session action.")
            )
            actionError = appError
            sessionCommandState = .failed(appError)
        }
    }

    func skipExercise(_ exercise: Exercise) async {
        sessionCommandState = .pending(message: "Skipping exercise...")
        do {
            try await repository.skip(exerciseID: exercise.id)
            actionError = nil
            currentExercise = nil
            sessionState = .idle
            sessionCommandState = .succeeded(message: "Exercise skipped.")
            scheduleCommandStateReset()
        } catch {
            let appError = AppError.fallback(error, or: AppError.saveFailed(action: "skip this exercise"))
            actionError = appError
            sessionCommandState = .failed(appError)
        }
    }

    var totalCount: Int {
        exercises.count
    }

    var doneCount: Int {
        completedExerciseIDs.count
    }

    var completionProgress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(doneCount) / Double(totalCount)
    }

    var nextSuggestedExercise: Exercise? {
        exercises.first(where: { completedExerciseIDs.contains($0.id) == false })
    }

    func dismissCoachReflectionPrompt() {
        showCoachReflectionPrompt = false
    }

    private func reduce(_ action: Action) {
        switch action {
        case .loadStarted:
            viewState = .loading
        case let .loadSucceeded(exercises):
            self.exercises = exercises
            completedExerciseIDs = Set(exercises.filter(\.isCompleted).map(\.id))
            viewState = exercises.isEmpty ? .empty : .loaded(exercises)
        case let .loadFailed(error):
            viewState = .error(error)
        case let .exerciseStarted(exercise):
            currentExercise = exercise
            sessionState = .active
        case let .exerciseCompleted(id):
            completedExerciseIDs.insert(id)
            currentExercise = nil
            sessionState = .complete
            showCoachReflectionPrompt = true
            exercises = exercises.map { exercise in
                var edited = exercise
                if edited.id == id {
                    edited.isCompleted = true
                }
                return edited
            }
        }
    }

    private func scheduleCommandStateReset() {
        Task {
            do {
                try await Task.sleep(for: .seconds(2))
            } catch {
                return
            }
            if case .succeeded = sessionCommandState {
                sessionCommandState = .idle
            }
        }
    }
}
