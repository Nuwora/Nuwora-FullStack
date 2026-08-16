import SwiftUI

struct SettingsView: View {
    @Environment(AppStore.self) private var appStore
    @AppStorage("settings.reminders.enabled") private var remindersEnabled = true
    @AppStorage("settings.reminder.timeInterval") private var reminderTimeInterval = Date.now.timeIntervalSinceReferenceDate
    @AppStorage("settings.theme") private var selectedTheme = "Auto"
    @AppStorage("settings.haptics.enabled") private var hapticsEnabled = true
    @AppStorage("settings.haptics.intensity") private var hapticIntensity = 0.7
    @State private var isShowingLogOutConfirmation = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                settingsCard(title: "Coach & Presence", rows: ["Coach Personality"])

                NCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sound and Haptics")
                            .foregroundStyle(Color.colorTextPrimary)
                            .font(.headline)

                        Toggle("Haptics enabled", isOn: $hapticsEnabled)
                            .tint(Color.colorGreen)
                            .foregroundStyle(Color.colorTextPrimary)

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Breathing intensity")
                                    .foregroundStyle(Color.colorTextSecondary)
                                    .font(.subheadline)
                                Spacer()
                                Text("\(Int((hapticIntensity * 100).rounded()))%")
                                    .foregroundStyle(Color.colorTextTertiary)
                                    .font(.caption.monospacedDigit())
                            }
                            Slider(value: $hapticIntensity, in: 0.1 ... 1.0, step: 0.1)
                                .tint(Color.colorGreen)
                                .disabled(hapticsEnabled == false)
                        }
                    }
                }

                NCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Theme")
                            .foregroundStyle(Color.colorTextPrimary)
                            .font(.headline)
                        Picker("Theme", selection: $selectedTheme) {
                            Text("Auto").tag("Auto")
                            Text("Light").tag("Light")
                            Text("Dark").tag("Dark")
                        }
                        .pickerStyle(.segmented)
                        .tint(Color.colorGreen)
                    }
                }

                NCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notifications")
                            .foregroundStyle(Color.colorTextPrimary)
                            .font(.headline)
                        Toggle("Daily reminders", isOn: $remindersEnabled)
                            .tint(Color.colorGreen)
                            .foregroundStyle(Color.colorTextPrimary)
                        DatePicker("Reminder time", selection: reminderTimeBinding, displayedComponents: .hourAndMinute)
                            .foregroundStyle(Color.colorTextSecondary)
                    }
                }

                settingsCard(title: "Privacy & Control", rows: ["Privacy and Data", "Subscriptions", "Export Data"])

                logOutCard
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.xl)
            .padding(.bottom, DesignTokens.Spacing.xxl)
        }
        .navigationTitle("Profile & Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(for: SettingsRoute.self) { route in
            SettingsComingSoonView(title: route.title)
        }
        .confirmationDialog(
            "Log out of Nuwora?",
            isPresented: $isShowingLogOutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Log Out", role: .destructive) {
                appStore.logOut()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You can log back in anytime with your account, or continue as a guest.")
        }
    }

    private var logOutCard: some View {
        NCard {
            Button {
                isShowingLogOutConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundStyle(Color.colorAmber)
                        .font(.footnote.weight(.semibold))
                        .frame(width: 20)
                    Text("Log Out")
                        .foregroundStyle(Color.colorAmber)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }
                .padding(.vertical, DesignTokens.Spacing.xs)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Log Out")
        }
    }

    private var reminderTimeBinding: Binding<Date> {
        Binding(
            get: { Date(timeIntervalSinceReferenceDate: reminderTimeInterval) },
            set: { reminderTimeInterval = $0.timeIntervalSinceReferenceDate }
        )
    }

    private func settingsCard(title: String, rows: [String]) -> some View {
        NCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .foregroundStyle(Color.colorTextPrimary)
                    .font(.headline)

                ForEach(rows, id: \.self) { row in
                    if let route = SettingsRoute(row: row) {
                        NavigationLink(value: route) {
                            settingsRow(title: row)
                        }
                        .buttonStyle(.plain)
                    } else {
                        settingsRow(title: row)
                    }
                }
            }
        }
    }

    private func settingsRow(title: String) -> some View {
        HStack {
            Image(systemName: icon(for: title))
                .foregroundStyle(Color.colorTeal.opacity(0.9))
                .font(.footnote.weight(.semibold))
                .frame(width: 20)
            Text(title)
                .foregroundStyle(Color.colorTextSecondary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.colorTextTertiary)
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
        .contentShape(Rectangle())
    }

    private func icon(for row: String) -> String {
        switch row {
        case "Coach Personality": return "message"
        case "Privacy and Data": return "lock.shield"
        case "Subscriptions": return "creditcard"
        case "Export Data": return "square.and.arrow.up"
        default: return "gearshape"
        }
    }
}

private enum SettingsRoute: Hashable {
    case coachPersonality
    case privacyAndData
    case subscriptions
    case exportData

    init?(row: String) {
        switch row {
        case "Coach Personality": self = .coachPersonality
        case "Privacy and Data": self = .privacyAndData
        case "Subscriptions": self = .subscriptions
        case "Export Data": self = .exportData
        default: return nil
        }
    }

    var title: String {
        switch self {
        case .coachPersonality: return "Coach Personality"
        case .privacyAndData: return "Privacy and Data"
        case .subscriptions: return "Subscriptions"
        case .exportData: return "Export Data"
        }
    }
}

private struct SettingsComingSoonView: View {
    let title: String

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                NCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Coming soon", systemImage: "clock.badge")
                            .font(.headline)
                            .foregroundStyle(Color.colorTextTertiary)
                        Text("This feature will be available in an upcoming update.")
                            .font(.subheadline)
                            .foregroundStyle(Color.colorTextSecondary)
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.xl)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(AppStore())
}
