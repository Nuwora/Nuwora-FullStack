import SwiftUI

struct PlanProgressCard: View {
    let doneCount: Int
    let totalCount: Int
    let completionProgress: Double

    var body: some View {
        NCard(glow: .colorGreen) {
            VStack(alignment: .leading, spacing: 10) {
                Text("\(doneCount) of \(max(totalCount, 1)) sessions complete")
                    .foregroundStyle(Color.colorTextPrimary)
                    .font(.headline)

                ProgressView(value: completionProgress)
                    .tint(Color.colorGreen)

                Text("Daily XP target: \(totalCount * 65) · Current: \(doneCount * 65)")
                    .foregroundStyle(Color.colorTextSecondary)
                    .font(.caption)
            }
        }
    }
}

struct PlanTimelineSection: View {
    let exercises: [Exercise]
    let completedExerciseIDs: Set<UUID>
    let onSelectExercise: (Exercise) -> Void

    var body: some View {
        NCard {
            LazyVStack(alignment: .leading, spacing: 12) {
                Text("Today's Timeline")
                    .foregroundStyle(Color.colorTextPrimary)
                    .font(.headline)

                ForEach(exercises.indices, id: \.self) { index in
                    let exercise = exercises[index]
                    let isCompleted = completedExerciseIDs.contains(exercise.id)
                    let isLast = index == exercises.count - 1

                    Button {
                        onSelectExercise(exercise)
                    } label: {
                        PlanTimelineRowContent(exercise: exercise, isCompleted: isCompleted, isLast: isLast)
                            .equatable()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct PlanTimelineRowContent: View, Equatable {
    let exercise: Exercise
    let isCompleted: Bool
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 0) {
                Circle()
                    .fill(isCompleted ? Color.colorGreen : exercise.type.color)
                    .frame(width: 12, height: 12)
                if isLast == false {
                    Rectangle()
                        .fill(Color.borderSubtle)
                        .frame(width: 2, height: 44)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(exercise.title)
                        .foregroundStyle(Color.colorTextPrimary)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("\(exercise.durationSeconds / 60) min")
                        .font(.caption)
                        .foregroundStyle(Color.colorTextSecondary)
                }

                Text(exercise.subtitle)
                    .foregroundStyle(Color.colorTextSecondary)
                    .font(.caption)

                HStack(spacing: 8) {
                    badge(text: "+\(exercise.xpReward) XP", tint: .colorGreen)
                    if exercise.type == .breathing {
                        badge(text: "Live", tint: .colorTeal)
                    }
                    if isCompleted {
                        badge(text: "Done", tint: .colorPurple)
                    }
                }
            }
        }
    }

    private func badge(text: String, tint: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, DesignTokens.Insets.chipHorizontal)
            .padding(.vertical, DesignTokens.Insets.chipVertical)
            .background(tint.opacity(0.12))
            .clipShape(Capsule())
    }
}

struct PlanModulesSection: View {
    let onStartModule: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Training Modules")
                .font(.headline)
                .foregroundStyle(Color.colorTextPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(trainingModules) { module in
                    NCard(glow: module.tint) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(module.title, systemImage: module.icon)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.colorTextPrimary)
                            Text(module.subtitle)
                                .font(.caption)
                                .foregroundStyle(Color.colorTextSecondary)
                                .lineLimit(3)
                            NButton(title: "Start", style: .ghost) {
                                onStartModule(module.id)
                            }
                        }
                    }
                }
            }
        }
    }

    private var trainingModules: [TrainingModule] {
        [
            TrainingModule(id: "resilience", title: "Resilience", subtitle: "Recover faster after stress spikes.", icon: "shield.lefthalf.filled", tint: .colorPurple),
            TrainingModule(id: "focus", title: "Focus", subtitle: "Sustain deep attention with fewer switches.", icon: "scope", tint: .colorGreen),
            TrainingModule(id: "memory", title: "Memory", subtitle: "Boost recall through short cognitive drills.", icon: "brain", tint: .colorTeal),
            TrainingModule(id: "emotional", title: "Emotional", subtitle: "Build regulation with reflection prompts.", icon: "heart.text.square", tint: .colorPurple),
            TrainingModule(id: "sleep", title: "Sleep", subtitle: "Evening routines for better restoration.", icon: "moon.stars", tint: .colorTeal),
            TrainingModule(id: "nutrition", title: "Nutrition", subtitle: "Fuel routines that support focus stability.", icon: "leaf", tint: .colorGreen)
        ]
    }
}

struct PlanBadgesSection: View {
    var body: some View {
        NCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Motivation")
                    .font(.headline)
                    .foregroundStyle(Color.colorTextPrimary)
                HStack(spacing: 8) {
                    badge(text: "Consistency +12", tint: .colorGreen)
                    badge(text: "Calm Streak", tint: .colorTeal)
                    badge(text: "Focus Builder", tint: .colorPurple)
                }
            }
        }
    }

    private func badge(text: String, tint: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, DesignTokens.Insets.chipHorizontal)
            .padding(.vertical, DesignTokens.Insets.chipVertical)
            .background(tint.opacity(0.12))
            .clipShape(Capsule())
    }
}

struct PlanCoachReflectionCard: View {
    let onTalkToCoach: () -> Void

    var body: some View {
        NCard(glow: .colorTeal) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Would you like to talk about how that felt?")
                    .foregroundStyle(Color.colorTextPrimary)
                    .font(.headline)
                NButton(title: "Talk to Coach", style: .secondary, action: onTalkToCoach)
                    .accessibilityHint("Switches to Coach for post-session reflection.")
            }
        }
    }
}

struct PlanActionErrorCard: View {
    let error: AppError

    var body: some View {
        NCard {
            VStack(alignment: .leading, spacing: 6) {
                Text(error.message)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.colorRose)
                Text(error.retryHint)
                    .font(.caption)
                    .foregroundStyle(Color.colorTextSecondary)
            }
        }
    }
}

struct PlanNextExerciseBar: View {
    let exercise: Exercise
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            NButton(title: "Start \(exercise.title)", action: onStart)
                .accessibilityHint("Starts your next suggested exercise.")
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Layout.floatingBarBottomPadding)
                .padding(.top, DesignTokens.Layout.floatingBarTopPadding)
        }
        .background(Color.colorBackground.opacity(0.38).background(.ultraThinMaterial))
    }
}

struct PlanSessionOverlay: View {
    let exercise: Exercise
    let onBeginSession: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(exercise.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.colorTextPrimary)
                Spacer()
                Text("\(exercise.durationSeconds / 60) min")
                    .foregroundStyle(Color.colorTextSecondary)
            }

            NCard(glow: exercise.type.color) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(exercise.subtitle)
                        .foregroundStyle(Color.colorTextSecondary)
                    Text(guidanceText)
                        .font(.caption)
                        .foregroundStyle(Color.colorTextTertiary)
                }
            }

            NButton(title: "Begin Session", action: onBeginSession)
                .accessibilityHint("Marks this exercise as completed for today's plan.")
            NButton(title: "Close", style: .ghost, action: onClose)
        }
        .padding(DesignTokens.Insets.modal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(NSceneBackground(style: .mindGym))
    }

    private var guidanceText: String {
        switch exercise.type {
        case .breathing: return "Stay steady. Inhale for 4, exhale for 6."
        case .cognitive: return "Focus on speed and accuracy. Trust your instincts."
        case .mindfulness: return "Observe your thoughts without judgment. Return to the present."
        case .focus: return "Eliminate distractions. Commit to this single task."
        case .journaling: return "Write freely. No wrong answers — just honest reflection."
        }
    }
}

struct PlanBreathingCard: View {
    let exercise: Exercise
    let onStart: () -> Void

    var body: some View {
        Button(action: onStart) {
            NCard(glow: .colorTeal) {
                HStack(alignment: .center, spacing: DesignTokens.Spacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.standard, style: .continuous)
                            .fill(Color.colorTeal.opacity(0.14))
                            .frame(width: 50, height: 50)
                        Image(systemName: "wind")
                            .font(.system(size: 22, weight: .light))
                            .foregroundStyle(Color.colorTeal)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text(exercise.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.colorTextPrimary)
                        Text("Inhale · Hold · Exhale · Hold — calm the nervous system.")
                            .font(.caption)
                            .foregroundStyle(Color.colorTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 6) {
                            breathingChip("\(exercise.durationSeconds / 60) min", tint: .colorTeal)
                            breathingChip("Stress relief", tint: .colorGreen)
                        }
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.colorTeal.opacity(0.6))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(exercise.title), \(exercise.durationSeconds / 60) minutes. Tap to start a breathing session.")
    }

    private func breathingChip(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, DesignTokens.Insets.chipHorizontal)
            .padding(.vertical, DesignTokens.Insets.chipVertical)
            .background(tint.opacity(0.12))
            .clipShape(Capsule())
    }
}

struct TrainingModule: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
}
