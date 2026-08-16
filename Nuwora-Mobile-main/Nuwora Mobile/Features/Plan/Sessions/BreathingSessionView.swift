import SwiftUI

struct BreathingSessionView: View {
    let exercise: Exercise
    let onComplete: () -> Void
    let onClose: () -> Void

    @StateObject private var viewModel: BreathingSessionViewModel
    @State private var didSubmitCompletion = false

    init(
        exercise: Exercise,
        onComplete: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
        self.exercise = exercise
        self.onComplete = onComplete
        self.onClose = onClose
        _viewModel = StateObject(wrappedValue: BreathingSessionViewModel(exercise: exercise))
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xl) {
            header
            breathingOrb
            sessionCard
            controls
        }
        .padding(DesignTokens.Insets.modal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(NSceneBackground(style: .mindGym))
        .interactiveDismissDisabled(viewModel.isRunning)
        .onChange(of: viewModel.isCompleted) { _, completed in
            guard completed else { return }
            guard didSubmitCompletion == false else { return }
            didSubmitCompletion = true
            onComplete()
            onClose()
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    // MARK: – Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.colorTextPrimary)
                Text(viewModel.phase.guidance)
                    .font(.subheadline)
                    .foregroundStyle(Color.colorTextSecondary)
            }
            Spacer()
            // Show timer while running; show close button otherwise
            if viewModel.isRunning {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(viewModel.sessionTimeLabel)
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(Color.colorTextPrimary)
                    Text("remaining")
                        .font(.caption2)
                        .foregroundStyle(Color.colorTextTertiary)
                }
            } else if !viewModel.isCompleted {
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.colorTextSecondary.opacity(0.65))
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
    }

    // MARK: – Breathing orb
    //
    // Color animation uses opacity cross-fades instead of direct Color interpolation.
    // SwiftUI can't smoothly interpolate between trait-aware UIColor-backed Colors,
    // but opacity is always animatable. Three pre-colored layers per element
    // (teal, purple, green) cross-fade via .opacity as the phase changes.

    private var breathingOrb: some View {
        ZStack {
            // Outermost ambient ring — fixed size, cross-fades color on phase change
            orbLayer(.colorTeal,   size: 292, fill: 0.07, active: isTealPhase)
            orbLayer(.colorPurple, size: 292, fill: 0.07, active: viewModel.phase == .holdIn)
            orbLayer(.colorGreen,  size: 292, fill: 0.07, active: viewModel.phase == .exhale)

            // Mid halo — scales with breathing
            scaledOrbLayer(.colorTeal,   size: 226, fill: 0.14, active: isTealPhase)
            scaledOrbLayer(.colorPurple, size: 226, fill: 0.14, active: viewModel.phase == .holdIn)
            scaledOrbLayer(.colorGreen,  size: 226, fill: 0.14, active: viewModel.phase == .exhale)

            // Core orb with radial gradient and glow — scales with breathing
            coreOrbLayer(.colorTeal,   active: isTealPhase)
            coreOrbLayer(.colorPurple, active: viewModel.phase == .holdIn)
            coreOrbLayer(.colorGreen,  active: viewModel.phase == .exhale)

            // Phase progress arc — cross-fades color
            progressArc(.colorTeal,   active: isTealPhase)
            progressArc(.colorPurple, active: viewModel.phase == .holdIn)
            progressArc(.colorGreen,  active: viewModel.phase == .exhale)

            // Phase label — spring transition on phase change
            VStack(spacing: 5) {
                Text(viewModel.phase.title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.white)
                    .id(viewModel.phase)
                    .transition(.scale(scale: 0.78).combined(with: .opacity))
                Text(viewModel.phaseTimeLabel)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(Color.white.opacity(0.82))
            }
            .animation(DesignTokens.Motion.standardSpring, value: viewModel.phase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    // Teal covers both inhale and holdOut (same visual weight, no jarring jump)
    private var isTealPhase: Bool {
        viewModel.phase == .inhale || viewModel.phase == .holdOut
    }

    @ViewBuilder
    private func orbLayer(_ color: Color, size: CGFloat, fill alpha: Double, active: Bool) -> some View {
        Circle()
            .fill(color.opacity(alpha))
            .frame(width: size, height: size)
            .opacity(active ? 1 : 0)
            .animation(.easeInOut(duration: 0.5), value: active)
    }

    @ViewBuilder
    private func scaledOrbLayer(_ color: Color, size: CGFloat, fill alpha: Double, active: Bool) -> some View {
        Circle()
            .fill(color.opacity(alpha))
            .frame(width: size, height: size)
            .scaleEffect(viewModel.scale)
            .opacity(active ? 1 : 0)
            .animation(.easeInOut(duration: 0.4), value: active)
    }

    @ViewBuilder
    private func coreOrbLayer(_ color: Color, active: Bool) -> some View {
        Circle()
            .fill(RadialGradient(
                colors: [color.opacity(0.92), color.opacity(0.50)],
                center: .center,
                startRadius: 6,
                endRadius: 112
            ))
            .frame(width: 175, height: 175)
            .scaleEffect(viewModel.scale)
            .shadow(color: color.opacity(0.55), radius: 34, x: 0, y: 0)
            .opacity(active ? 1 : 0)
            .animation(.easeInOut(duration: 0.4), value: active)
    }

    @ViewBuilder
    private func progressArc(_ color: Color, active: Bool) -> some View {
        Circle()
            .trim(from: 0, to: max(0.03, viewModel.phaseProgress))
            .stroke(
                AngularGradient(
                    colors: [color, color.opacity(0.42), color],
                    center: .center
                ),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )
            .frame(width: 214, height: 214)
            .rotationEffect(.degrees(-90))
            .opacity(active ? (viewModel.isRunning ? 1 : 0.38) : 0)
            .animation(.easeInOut(duration: 0.4), value: active)
    }

    // MARK: – Session card

    private var sessionCard: some View {
        NCard(glow: .colorTeal) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Session Progress")
                        .foregroundStyle(Color.colorTextPrimary)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("\(Int((viewModel.sessionProgress * 100).rounded()))%")
                        .foregroundStyle(Color.colorTextSecondary)
                        .font(.caption.monospacedDigit())
                }
                ProgressView(value: viewModel.sessionProgress)
                    .tint(Color.colorGreen)
                HStack {
                    Text("Cycles: \(viewModel.completedCycles)")
                        .foregroundStyle(Color.colorTextSecondary)
                        .font(.caption)
                    Spacer()
                    Text(sessionStatusText)
                        .foregroundStyle(Color.colorTextTertiary)
                        .font(.caption)
                }
            }
        }
    }

    private var sessionStatusText: String {
        if viewModel.isCompleted { return "Complete" }
        if viewModel.isRunning { return "Breathing..." }
        return "Ready"
    }

    // MARK: – Controls

    private var controls: some View {
        NButton(title: primaryActionTitle, action: handlePrimaryAction)
            .disabled(didSubmitCompletion || viewModel.isCompleted)
    }

    private var primaryActionTitle: String {
        viewModel.isRunning ? "Stop Session" : "Start Session"
    }

    private func handlePrimaryAction() {
        if viewModel.isRunning {
            viewModel.stop()
            onClose()
        } else {
            viewModel.start()
        }
    }
}
