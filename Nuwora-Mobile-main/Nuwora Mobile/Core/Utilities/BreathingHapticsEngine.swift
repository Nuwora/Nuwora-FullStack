import CoreHaptics
import Foundation
import UIKit

final class BreathingHapticsEngine {
    private enum Settings {
        static let enabledKey = "settings.haptics.enabled"
        static let intensityKey = "settings.haptics.intensity"
    }

    private var engine: CHHapticEngine?
    private var supportsCoreHaptics = false
    private var lastRhythmPulse = Date.distantPast
    private let fallbackImpactGenerator = UIImpactFeedbackGenerator(style: .light)

    init() {
        configureEngine()
    }

    func prepare() {
        guard hapticsEnabled else { return }
        fallbackImpactGenerator.prepare()
        if supportsCoreHaptics {
            try? engine?.start()
        }
    }

    func phaseTransition(for phase: BreathPhase) {
        guard hapticsEnabled else { return }
        let intensity = baseIntensity
        switch phase {
        case .inhale:
            playTransient(
                intensity: intensity,
                sharpness: 0.52
            )
        case .holdIn, .holdOut:
            playTransient(
                intensity: intensity * 0.78,
                sharpness: 0.35
            )
        case .exhale:
            playTransient(
                intensity: intensity * 0.9,
                sharpness: 0.18
            )
        }
    }

    func rhythmPulse(for phase: BreathPhase) {
        guard hapticsEnabled else { return }
        guard phase == .inhale || phase == .exhale else { return }

        let interval: TimeInterval = phase == .inhale ? 0.82 : 0.68
        guard Date().timeIntervalSince(lastRhythmPulse) >= interval else { return }
        lastRhythmPulse = Date()

        let phaseFactor = phase == .inhale ? 0.45 : 0.32
        playTransient(
            intensity: max(0.08, baseIntensity * phaseFactor),
            sharpness: phase == .inhale ? 0.26 : 0.15
        )
    }

    func resetRhythmClock() {
        lastRhythmPulse = .distantPast
    }

    private func configureEngine() {
        supportsCoreHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        guard supportsCoreHaptics else { return }

        do {
            let created = try CHHapticEngine()
            created.isAutoShutdownEnabled = true
            created.resetHandler = { [weak self] in
                self?.prepare()
            }
            engine = created
        } catch {
            supportsCoreHaptics = false
            engine = nil
        }
    }

    private func playTransient(intensity: Double, sharpness: Double) {
        if supportsCoreHaptics {
            let clampedIntensity = Float(max(0.0, min(1.0, intensity)))
            let clampedSharpness = Float(max(0.0, min(1.0, sharpness)))
            let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: clampedIntensity)
            let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: clampedSharpness)
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensityParam, sharpnessParam],
                relativeTime: 0
            )
            do {
                let pattern = try CHHapticPattern(events: [event], parameters: [])
                let player = try engine?.makePlayer(with: pattern)
                try engine?.start()
                try player?.start(atTime: 0)
                return
            } catch {
                supportsCoreHaptics = false
            }
        }

        fallbackImpactGenerator.impactOccurred(intensity: CGFloat(max(0.08, min(1.0, intensity))))
        fallbackImpactGenerator.prepare()
    }

    private var hapticsEnabled: Bool {
        if UserDefaults.standard.object(forKey: Settings.enabledKey) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: Settings.enabledKey)
    }

    private var baseIntensity: Double {
        let value = UserDefaults.standard.double(forKey: Settings.intensityKey)
        if UserDefaults.standard.object(forKey: Settings.intensityKey) == nil {
            return 0.7
        }
        return max(0.1, min(1.0, value))
    }
}
