import SwiftUI

struct DashboardScoreCard: View {
    let score: MindFitnessScore?
    let emotionalSummary: String
    let lastSyncedText: String

    var body: some View {
        NCard {
            VStack(spacing: 14) {
                HStack {
                    Text("Mind Score")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.colorTextSecondary)
                    Spacer()
                    Text("Today")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.colorTeal)
                        .padding(.horizontal, DesignTokens.Insets.chipHorizontal)
                        .padding(.vertical, DesignTokens.Insets.chipVertical)
                        .background(Color.colorTeal.opacity(0.12))
                        .clipShape(Capsule())
                }

                NScoreGauge(score: score?.overallScore ?? 0)
                    .frame(width: 164, height: 164)

                VStack(spacing: 3) {
                    Text(emotionalSummary)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.colorTextPrimary)
                        .multilineTextAlignment(.center)
                    Text("Synced \(lastSyncedText)")
                        .font(.caption)
                        .foregroundStyle(Color.colorTextTertiary)
                }

                HStack(spacing: 8) {
                    statChip(title: "Focus", value: score?.focusSubscore ?? 0, tint: .colorGreen)
                    statChip(title: "Calm", value: score?.calmSubscore ?? 0, tint: .colorTeal)
                    statChip(title: "Energy", value: score?.energySubscore ?? 0, tint: .colorPurple)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func statChip(title: String, value: Int, tint: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 3) {
                Circle()
                    .fill(tint)
                    .frame(width: 5, height: 5)
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(Color.colorTextSecondary)
            }
            Text("\(value)")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.colorTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(Color.colorSurface.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.compact, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.compact, style: .continuous)
                .stroke(tint.opacity(0.22), lineWidth: 1)
        )
    }
}

struct DashboardQuickCardRow: View {
    let planCount: Int
    let sleepSummary: String
    let onOpenMindGym: () -> Void
    let onOpenCoach: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                quickCard(icon: "figure.mind.and.body", title: "Daily Plan", subtitle: "\(planCount) mind workouts", action: onOpenMindGym)
                quickCard(icon: "message.badge.waveform", title: "AI Coach", subtitle: "Talk through your state", action: onOpenCoach)
                quickCard(icon: "bed.double.fill", title: "Sleep", subtitle: sleepSummary)
            }
            .padding(.horizontal, DesignTokens.Spacing.xxs)
        }
    }

    private func quickCard(icon: String, title: String, subtitle: String, action: (() -> Void)? = nil) -> some View {
        let card = VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color.colorTeal)
                .font(.headline)
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.colorTextPrimary)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(Color.colorTextSecondary)
                .lineLimit(2)
        }
        .frame(width: 168, alignment: .leading)
        .padding(DesignTokens.Insets.cardComfortable)
        .background(Color.colorSurface.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large, style: .continuous)
                .stroke(Color.colorBorder, lineWidth: 1)
        )

        return Group {
            if let action {
                Button(action: action) { card }
                    .buttonStyle(.plain)
            } else {
                card
            }
        }
    }
}

struct DashboardMonitoringCard: View {
    let hrvValue: Int
    let focusLevel: Int
    let distractionCount: Int
    let onStartReset: () -> Void

    var body: some View {
        NCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Real-time Monitoring")
                    .font(.headline)
                    .foregroundStyle(Color.colorTextPrimary)

                HStack(spacing: 8) {
                    monitorPill(label: "HRV", value: "\(hrvValue) ms", tint: .colorTeal)
                    monitorPill(label: "Focus", value: "\(focusLevel)%", tint: .colorGreen)
                    monitorPill(label: "Distractions", value: "\(distractionCount)", tint: .colorPurple)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(monitoringMessage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.colorTextPrimary)
                    if showResetButton {
                        NButton(title: "Start 2-Min Reset", style: .ghost, action: onStartReset)
                    }
                }
                .padding(DesignTokens.Insets.cardRegular)
                .background(Color.colorSurface.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium, style: .continuous)
                        .stroke(Color.colorBorder, lineWidth: 1)
                )
            }
        }
    }

    private var monitoringMessage: String {
        switch focusLevel {
        case 70...: return "Focus is strong today. Keep the momentum going."
        case 50..<70: return "Focus is moderate — a quick reset could sharpen it."
        default: return "You're losing focus — want a 2-min reset?"
        }
    }

    private var showResetButton: Bool {
        focusLevel < 70
    }

    private func monitorPill(label: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.colorTextSecondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.colorTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignTokens.Insets.cardCompact)
        .background(tint.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.standard, style: .continuous))
    }
}

struct DashboardMoodCard: View {
    let moodLoggedToday: Bool
    let onOpenMoodSheet: () -> Void

    var body: some View {
        NCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Mood check-in")
                        .font(.headline)
                        .foregroundStyle(Color.colorTextPrimary)
                    Spacer()
                    Text(moodLoggedToday ? "Done" : "Pending")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(moodLoggedToday ? Color.colorGreen : Color.colorTextSecondary)
                }

                Text("How are you feeling today?")
                    .font(.subheadline)
                    .foregroundStyle(Color.colorTextSecondary)

                NButton(title: moodLoggedToday ? "Logged for today" : "Check in", style: .secondary) {
                    if moodLoggedToday == false {
                        onOpenMoodSheet()
                    }
                }
                .accessibilityHint("Opens mood check-in options.")
            }
        }
    }
}

struct DashboardActionErrorCard: View {
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

struct DashboardWorkoutCard: View {
    let exercises: [Exercise]
    let onOpenMindGym: () -> Void

    var body: some View {
        NCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Today's Mind Workout")
                    .font(.headline)
                    .foregroundStyle(Color.colorTextPrimary)

                ForEach(exercises.prefix(3)) { exercise in
                    HStack {
                        Label(exercise.title, systemImage: exercise.type.icon)
                            .foregroundStyle(Color.colorTextSecondary)
                            .font(.subheadline)
                        Spacer()
                        Text("+\(exercise.xpReward) XP")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.colorGreen)
                    }
                }

                NButton(title: "Open Mind Gym", style: .ghost, action: onOpenMindGym)
                    .accessibilityHint("Opens your daily exercise plan.")
            }
        }
    }
}

struct DashboardMoodSheet: View {
    let onSelectedMood: (MoodOption) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("How are you feeling right now?")
                .font(.headline)
                .foregroundStyle(Color.colorTextPrimary)

            HStack(spacing: 10) {
                ForEach(MoodOption.allCases, id: \.self) { mood in
                    Button {
                        onSelectedMood(mood)
                    } label: {
                        VStack(spacing: 6) {
                            Text(mood.emoji)
                                .font(.title3)
                            Text(mood.label)
                                .font(.caption2)
                                .foregroundStyle(Color.colorTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignTokens.Spacing.sm)
                        .background(Color.colorSurface.opacity(0.74))
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.standard, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.standard, style: .continuous)
                                .stroke(Color.colorBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(DesignTokens.Insets.modal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.colorBackground)
    }
}
