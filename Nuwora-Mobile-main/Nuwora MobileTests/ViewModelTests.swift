import XCTest
@testable import Nuwora_Mobile

@MainActor
final class ViewModelTests: XCTestCase {
    func testDashboardViewModelLoadSuccessTransitionsToLoaded() async {
        let exercise = TestFixtures.sampleExercise()
        let repository = StubDashboardRepository(mode: .success(TestFixtures.dashboardSnapshot(planPreview: [exercise])))
        let viewModel = DashboardViewModel(repository: repository)

        await viewModel.loadDashboard()

        switch viewModel.viewState {
        case let .loaded(snapshot):
            XCTAssertEqual(snapshot.planPreview.count, 1)
        default:
            XCTFail("Expected loaded state")
        }
        XCTAssertTrue(viewModel.hasLoadedOnce)
        XCTAssertEqual(viewModel.dailyPlanPreview.count, 1)
    }

    func testDashboardViewModelLoadFailureTransitionsToError() async {
        let repository = StubDashboardRepository(mode: .failure(FixedError()))
        let viewModel = DashboardViewModel(repository: repository)

        await viewModel.loadDashboard()

        switch viewModel.viewState {
        case let .error(error):
            XCTAssertEqual(error.code, .network)
        default:
            XCTFail("Expected error state")
        }
    }

    func testPlanViewModelLoadSuccessBuildsCompletedIDs() async {
        let completed = TestFixtures.sampleExercise(id: UUID(), completed: true)
        let pending = TestFixtures.sampleExercise(id: UUID(), completed: false)
        let repository = StubPlanRepository(fetchMode: .success([completed, pending]))
        let viewModel = PlanViewModel(repository: repository)

        await viewModel.loadPlan()

        XCTAssertTrue(viewModel.completedExerciseIDs.contains(completed.id))
        XCTAssertFalse(viewModel.completedExerciseIDs.contains(pending.id))
        XCTAssertEqual(viewModel.totalCount, 2)
        XCTAssertTrue(viewModel.hasLoadedOnce)
    }

    func testPlanViewModelCompleteExerciseFailureSetsActionError() async {
        let exercise = TestFixtures.sampleExercise(id: UUID(), completed: false)
        let repository = StubPlanRepository(fetchMode: .success([exercise]), markCompleteError: FixedError())
        let viewModel = PlanViewModel(repository: repository)
        viewModel.startExercise(exercise)

        await viewModel.completeExercise(performance: 0.9)

        XCTAssertEqual(viewModel.actionError?.code, .writeFailed)
        XCTAssertFalse(viewModel.completedExerciseIDs.contains(exercise.id))
    }

    func testPlanViewModelCompleteExerciseSuccessSetsCommandState() async {
        let exercise = TestFixtures.sampleExercise(id: UUID(), completed: false)
        let repository = StubPlanRepository(fetchMode: .success([exercise]))
        let viewModel = PlanViewModel(repository: repository)
        viewModel.startExercise(exercise)

        await viewModel.completeExercise(performance: 0.91)

        if case .succeeded = viewModel.sessionCommandState {
            XCTAssertTrue(viewModel.completedExerciseIDs.contains(exercise.id))
        } else {
            XCTFail("Expected success command state")
        }
    }

    func testDashboardMoodCheckInFailureSetsCommandStateFailed() async {
        final class FailingDashboardRepository: DashboardRepository {
            func fetchDashboard() async throws -> DashboardSnapshot {
                TestFixtures.dashboardSnapshot(planPreview: [])
            }

            func logMood(_ mood: MoodOption) async throws {
                _ = mood
                throw FixedError()
            }
        }

        let viewModel = DashboardViewModel(repository: FailingDashboardRepository())
        await viewModel.logMoodCheckIn(.good)

        if case .failed = viewModel.moodCommandState {
            XCTAssertEqual(viewModel.actionError?.code, .writeFailed)
        } else {
            XCTFail("Expected failed command state")
        }
    }

    func testCoachSendMessageFailureSetsCommandStateFailed() async {
        let repository = StubCoachRepository(
            fetchMode: .success([]),
            sendMode: .failure(FixedError())
        )
        let viewModel = CoachViewModel(repository: repository)

        await viewModel.sendMessage("help")

        if case .failed = viewModel.sendCommandState {
            XCTAssertFalse(viewModel.messages.isEmpty)
        } else {
            XCTFail("Expected failed command state")
        }
    }
}
