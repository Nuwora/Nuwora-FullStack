import Combine
import CoreGraphics
import Foundation
import SwiftUI
import UIKit

enum BreathPhase: Int, CaseIterable {
    case inhale
    case holdIn
    case exhale
    case holdOut

    var title: String {
        switch self {
        case .inhale:
            return "Inhale"
        case .holdIn, .holdOut:
            return "Hold"
        case .exhale:
            return "Exhale"
        }
    }

    var guidance: String {
        switch self {
        case .inhale:
            return "Breathe in through your nose"
        case .holdIn:
            return "Hold gently"
        case .exhale:
            return "Exhale slowly"
        case .holdOut:
            return "Stay relaxed"
        }
    }

    var duration: TimeInterval {
        switch self {
        case .inhale:
            return 4
        case .holdIn:
            return 1
        case .exhale:
            return 6
        case .holdOut:
            return 1
        }
    }

    var targetScale: CGFloat {
        switch self {
        case .inhale, .holdIn:
            return 1.0
        case .exhale, .holdOut:
            return 0.58
        }
    }
}

@MainActor
final class BreathingSessionViewModel: ObservableObject {
    static let totalSessionDuration: TimeInterval = 30

    let exercise: Exercise

    @Published var phase: BreathPhase = .inhale
    @Published var phaseTimeRemaining: TimeInterval = BreathPhase.inhale.duration
    @Published var sessionTimeRemaining: TimeInterval
    @Published var scale: CGFloat = BreathPhase.holdOut.targetScale
    @Published var phaseProgress: Double = 0
    @Published var isRunning = false
    @Published var isCompleted = false
    @Published var completedCycles = 0

    private var phaseTask: Task<Void, Never>?
    private let haptics: BreathingHapticsEngine
    private let tickIntervalNanoseconds: UInt64 = 50_000_000
    private var phaseFromScale: CGFloat = BreathPhase.holdOut.targetScale
    private var phaseToScale: CGFloat = BreathPhase.inhale.targetScale

    init(exercise: Exercise) {
        self.exercise = exercise
        sessionTimeRemaining = Self.totalSessionDuration
        haptics = BreathingHapticsEngine()
    }

    deinit {
        phaseTask?.cancel()
    }

    var sessionProgress: Double {
        let total = max(Self.totalSessionDuration, 1)
        let done = total - sessionTimeRemaining
        return min(max(done / total, 0), 1)
    }

    var sessionTimeLabel: String {
        let remainingSeconds = Int(sessionTimeRemaining.rounded())
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var phaseTimeLabel: String {
        String(format: "%.1f s", max(0, phaseTimeRemaining))
    }

    func start() {
        guard isCompleted == false else { return }
        guard isRunning == false else { return }
        isRunning = true
        phaseFromScale = scale
        phaseToScale = phase.targetScale

        haptics.prepare()
        haptics.phaseTransition(for: phase)
        haptics.resetRhythmClock()

        phaseTask = Task { [weak self] in
            await self?.runSessionLoop()
        }
    }

    func stop() {
        isRunning = false
        phaseTask?.cancel()
        phaseTask = nil
    }

    func endSession() {
        stop()
        isCompleted = true
        phaseTimeRemaining = 0
        sessionTimeRemaining = 0
        phaseProgress = 1
        HapticManager.success()
    }

    private func runSessionLoop() async {
        var lastTick = Date()
        while isRunning, isCompleted == false {
            try? await Task.sleep(nanoseconds: tickIntervalNanoseconds)
            if Task.isCancelled || isRunning == false {
                return
            }

            let now = Date()
            let elapsed = now.timeIntervalSince(lastTick)
            lastTick = now

            phaseTimeRemaining = max(0, phaseTimeRemaining - elapsed)
            sessionTimeRemaining = max(0, sessionTimeRemaining - elapsed)

            updateScaleForCurrentPhase()
            haptics.rhythmPulse(for: phase)

            if sessionTimeRemaining <= 0 {
                endSession()
                return
            }

            if phaseTimeRemaining <= 0 {
                advancePhase()
            }
        }
    }

    private func advancePhase() {
        switch phase {
        case .inhale:
            phase = .holdIn
        case .holdIn:
            phase = .exhale
        case .exhale:
            phase = .holdOut
        case .holdOut:
            phase = .inhale
            completedCycles += 1
        }

        phaseTimeRemaining = phase.duration
        phaseProgress = 0
        phaseFromScale = scale
        phaseToScale = phase.targetScale
        haptics.phaseTransition(for: phase)
        haptics.resetRhythmClock()
    }

    private func updateScaleForCurrentPhase() {
        let duration = max(phase.duration, 0.0001)
        let elapsed = duration - phaseTimeRemaining
        let clampedProgress = min(max(elapsed / duration, 0), 1)
        phaseProgress = clampedProgress
        scale = phaseFromScale + (phaseToScale - phaseFromScale) * CGFloat(clampedProgress)
    }
}
