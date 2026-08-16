import SwiftUI

struct PlanView: View {
    @Environment(AppStore.self) private var appStore
    @State private var viewModel: PlanViewModel
    @State private var hasRequestedInitialLoad = false
    @State private var formattedToday = Date.now.formatted(date: .abbreviated, time: .omitted)

    init(viewModel: PlanViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        let viewState = viewModel.viewState
        let exercises = viewModel.exercises
        let completedExerciseIDs = viewModel.completedExerciseIDs
        let nextExercise = viewModel.nextSuggestedExercise

        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                header

                switch viewState {
                case .idle, .loading:
                    NSkeletonView().frame(height: 220)
                    NSkeletonView().frame(height: 200)
                case .empty:
                    NFeatureStatusCard.empty(
                        title: "No exercises yet",
                        message: "Your Mind Workout plan will show up after sync."
                    )
                case let .error(error):
                    NFeatureStatusCard.error(error)
                case .loaded:
                    PlanProgressCard(
                        doneCount: viewModel.doneCount,
                        totalCount: viewModel.totalCount,
                        completionProgress: viewModel.completionProgress
                    )
                    if let breathingExercise = exercises.first(where: { $0.type == .breathing }) {
                        PlanBreathingCard(exercise: breathingExercise) {
                            viewModel.startExercise(breathingExercise)
                        }
                    }
                    PlanTimelineSection(
                        exercises: exercises,
                        completedExerciseIDs: completedExerciseIDs,
                        onSelectExercise: viewModel.startExercise
                    )
                    PlanModulesSection { moduleID in
                        let typeMap: [String: ExerciseType] = [
                            "focus": .focus,
                            "memory": .cognitive,
                            "emotional": .journaling,
                            "resilience": .mindfulness,
                            "sleep": .breathing,
                            "nutrition": .breathing
                        ]
                        guard let type = typeMap[moduleID] else { return }
                        let match = exercises.first { $0.type == type && !completedExerciseIDs.contains($0.id) }
                            ?? exercises.first { $0.type == type }
                        if let match {
                            viewModel.startExercise(match)
                        }
                    }
                    PlanBadgesSection()
                }

                if viewModel.showCoachReflectionPrompt {
                    PlanCoachReflectionCard {
                        viewModel.dismissCoachReflectionPrompt()
                        appStore.openTab(.coach)
                    }
                }

                NCommandFeedbackCard(state: viewModel.sessionCommandState)

                if let actionError = viewModel.actionError {
                    PlanActionErrorCard(error: actionError)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.xl)
            .padding(.bottom, DesignTokens.Layout.contentBottomInsetWithFloatingBar)
        }
        .safeAreaInset(edge: .bottom) {
            if let nextExercise, nextExercise.type != .breathing {
                PlanNextExerciseBar(exercise: nextExercise) {
                    viewModel.startExercise(nextExercise)
                }
            }
        }
        // Breathing sessions open full-screen so the orb and timer are fully visible
        .fullScreenCover(item: breathingSessionBinding) { exercise in
            BreathingSessionView(
                exercise: exercise,
                onComplete: {
                    Task {
                        await viewModel.completeExercise(performance: 0.9)
                    }
                },
                onClose: {
                    viewModel.currentExercise = nil
                }
            )
        }
        // All other exercise types open as a standard sheet
        .sheet(item: otherSessionBinding) { exercise in
            PlanSessionOverlay(
                exercise: exercise,
                onBeginSession: {
                    Task {
                        await viewModel.completeExercise(performance: 0.86)
                    }
                },
                onClose: {
                    viewModel.currentExercise = nil
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .task {
            guard hasRequestedInitialLoad == false else { return }
            hasRequestedInitialLoad = true
            await viewModel.loadPlanIfNeeded()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Mind Workout")
                .font(.nHeading)
                .foregroundStyle(Color.colorTextPrimary)
            Text(formattedToday)
                .font(.caption)
                .foregroundStyle(Color.colorTextSecondary)
        }
    }

    private var breathingSessionBinding: Binding<Exercise?> {
        Binding(
            get: {
                guard let ex = viewModel.currentExercise, ex.type == .breathing else { return nil }
                return ex
            },
            set: { viewModel.currentExercise = $0 }
        )
    }

    private var otherSessionBinding: Binding<Exercise?> {
        Binding(
            get: {
                guard let ex = viewModel.currentExercise, ex.type != .breathing else { return nil }
                return ex
            },
            set: { viewModel.currentExercise = $0 }
        )
    }
}

#Preview {
    PlanView(viewModel: PlanViewModel(repository: MockPlanRepository()))
        .environment(AppStore())
}
