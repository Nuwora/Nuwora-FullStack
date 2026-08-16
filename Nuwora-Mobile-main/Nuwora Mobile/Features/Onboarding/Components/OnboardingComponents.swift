import SwiftUI

struct OnboardingProgressHeader: View {
    let stepIndex: Int
    let totalSteps: Int
    let stepTitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Nuwora")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color.colorTextPrimary)
            Text("Mind Gym onboarding")
                .font(.subheadline)
                .foregroundStyle(Color.colorTextSecondary)

            HStack(spacing: 6) {
                ForEach(0..<totalSteps, id: \.self) { idx in
                    Capsule()
                        .fill(idx <= stepIndex ? Color.colorTeal : Color.appCard.opacity(0.9))
                        .frame(height: 6)
                }
            }

            Text("Step \(stepIndex + 1) of \(totalSteps) · \(stepTitle)")
                .font(.caption)
                .foregroundStyle(Color.colorTextTertiary)
        }
    }
}

struct OnboardingGoalsStep: View {
    @Binding var selectedGoals: Set<PrimaryGoal>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose your primary goals")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.colorTextPrimary)

            ForEach(PrimaryGoal.allCases) { goal in
                Button {
                    toggle(goal)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(goal.rawValue)
                                .font(.headline)
                                .foregroundStyle(Color.colorTextPrimary)
                            Text(goalSubtitle(for: goal))
                                .font(.caption)
                                .foregroundStyle(Color.colorTextSecondary)
                        }
                        Spacer()
                        Image(systemName: selectedGoals.contains(goal) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedGoals.contains(goal) ? Color.colorGreen : Color.colorTextTertiary)
                    }
                    .padding(14)
                    .background(Color.appCard.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(selectedGoals.contains(goal) ? Color.colorGreen.opacity(0.45) : Color.colorBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            if selectedGoals.isEmpty {
                Text("Select at least one goal to continue.")
                    .font(.caption)
                    .foregroundStyle(Color.colorAmber)
            }
        }
    }

    private func toggle(_ goal: PrimaryGoal) {
        if selectedGoals.contains(goal) {
            selectedGoals.remove(goal)
        } else {
            selectedGoals.insert(goal)
        }
    }

    private func goalSubtitle(for goal: PrimaryGoal) -> String {
        switch goal {
        case .focus: return "Sustain deep work with less distraction."
        case .stressRelief: return "Downshift quickly in tense moments."
        case .memory: return "Strengthen recall and mental agility."
        case .resilience: return "Recover faster after pressure."
        }
    }
}

struct OnboardingAssessmentStep: View {
    let questions: [String]
    @Binding var assessmentAnswers: [Int]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick cognitive assessment")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.colorTextPrimary)

                ForEach(Array(questions.enumerated()), id: \.offset) { index, question in
                    NCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(question)
                                .foregroundStyle(Color.colorTextPrimary)
                                .font(.subheadline.weight(.semibold))

                            VStack(spacing: 4) {
                                HStack(spacing: 8) {
                                    ForEach(1...5, id: \.self) { value in
                                        Button {
                                            assessmentAnswers[index] = value
                                        } label: {
                                            Text("\(value)")
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(assessmentAnswers[index] == value ? Color.appBackground : Color.colorTextSecondary)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 32)
                                                .background(assessmentAnswers[index] == value ? Color.accent : Color.appCard.opacity(0.8))
                                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        }
                                        .buttonStyle(.plain)
                                        .accessibilityLabel("Rating \(value) of 5")
                                    }
                                }

                                HStack {
                                    Text("Low")
                                        .font(.caption2)
                                        .foregroundStyle(Color.colorTextTertiary)
                                    Spacer()
                                    Text("High")
                                        .font(.caption2)
                                        .foregroundStyle(Color.colorTextTertiary)
                                }
                                .padding(.horizontal, DesignTokens.Spacing.xxs)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 4)
        }
    }
}

struct OnboardingWearablesStep: View {
    @Binding var connectedWearables: Set<OnboardingView.WearableKind>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sync wearables")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.colorTextPrimary)
            Text("Use real-time HRV, heart rate and sleep to adapt your daily mind workouts.")
                .font(.subheadline)
                .foregroundStyle(Color.colorTextSecondary)

            ForEach(OnboardingView.WearableKind.allCases) { device in
                HStack {
                    Label(device.rawValue, systemImage: device.icon)
                        .foregroundStyle(Color.colorTextPrimary)
                    Spacer()
                    Button(connectedWearables.contains(device) ? "Connected" : "Connect") {
                        if connectedWearables.contains(device) {
                            connectedWearables.remove(device)
                        } else {
                            connectedWearables.insert(device)
                        }
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(connectedWearables.contains(device) ? Color.colorGreen : Color.colorTeal)
                }
                .padding(14)
                .background(Color.appCard.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.colorBorder, lineWidth: 1)
                )
            }

            NCard {
                Text("HealthKit permissions will be requested after onboarding. You can skip and enable later in Settings.")
                    .font(.caption)
                    .foregroundStyle(Color.colorTextSecondary)
            }
        }
    }
}

struct OnboardingScoreStep: View {
    let scoreResult: Int
    let scoreTier: String
    let cognitiveResult: Int
    let biometricResult: Int
    let moodResult: Int

    var body: some View {
        VStack(spacing: 14) {
            NCard(glow: .colorTeal) {
                VStack(spacing: 12) {
                    NScoreGauge(score: scoreResult)
                        .frame(width: 174, height: 174)

                    Text(scoreTier)
                        .font(.headline)
                        .foregroundStyle(Color.colorTextPrimary)

                    Text("Cognitive \(cognitiveResult)% · Biometric \(biometricResult)% · Mood \(moodResult)%")
                        .font(.caption)
                        .foregroundStyle(Color.colorTextSecondary)
                }
                .frame(maxWidth: .infinity)
            }

            NCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Next")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.colorTeal)
                    Text("Your first daily plan will include short breathing drills, one focus block, and a reflection prompt.")
                        .font(.subheadline)
                        .foregroundStyle(Color.colorTextSecondary)
                }
            }
        }
    }
}

struct OnboardingBottomActions: View {
    let showBack: Bool
    let canContinue: Bool
    let isLastStep: Bool
    let isWorking: Bool
    let onBack: () -> Void
    let onContinue: () -> Void
    let onFinish: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            if showBack {
                NButton(title: "Back", style: .ghost, action: onBack)
            }

            NButton(
                title: isWorking ? "Saving..." : (isLastStep ? "Start Mind Gym" : "Continue"),
                style: canContinue ? .primary : .secondary
            ) {
                if isLastStep {
                    onFinish()
                } else {
                    onContinue()
                }
            }
            .disabled(canContinue == false)
            .saturation(canContinue ? 1 : 0)
        }
    }
}
