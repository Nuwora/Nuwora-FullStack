import SwiftUI

struct ProfileView: View {
    @Environment(AppStore.self) private var appStore
    @State private var viewModel: GamificationViewModel
    @State private var ringAnimated = false

    init(viewModel: GamificationViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    headerBar

                    switch viewModel.viewState {
                    case .idle, .loading:
                        NSkeletonView().frame(height: 240)
                        NSkeletonView().frame(height: 120)
                        NSkeletonView().frame(height: 200)
                    case .empty:
                        NFeatureStatusCard.empty(
                            title: "No profile data yet",
                            message: "Complete onboarding and sync to populate your profile."
                        )
                    case let .error(error):
                        NFeatureStatusCard.error(error)
                    case .loaded:
                        content
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.xl)
                .padding(.bottom, DesignTokens.Layout.contentBottomInset)
            }
            .navigationDestination(for: String.self) { value in
                if value == "settings" {
                    SettingsView()
                }
                if value == "corporate" {
                    CorporateDashboardView()
                }
            }
        }
        .task {
            await viewModel.loadProfileIfNeeded()
            withAnimation(.easeOut(duration: 1.1)) {
                ringAnimated = true
            }
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Profile")
                    .font(.nHeading)
                    .foregroundStyle(Color.colorTextPrimary)
                Text("Your growth, your rhythm")
                    .font(.subheadline)
                    .foregroundStyle(Color.colorTextSecondary)
            }
            Spacer()
            NavigationLink(value: "settings") {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.colorTextSecondary)
                    .frame(width: 36, height: 36)
                    .background(Color.appCard.opacity(0.8))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.colorBorder.opacity(0.7), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open settings")
        }
    }

    // MARK: - Content

    private var content: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            heroProfileCard
            quickStatsRow
            achievementsSection
            leaderboardSection
            teamChallengeCard
            navigationLinksCard
        }
    }

    // MARK: - Hero card

    private var heroProfileCard: some View {
        let profile = viewModel.userProfile
        return ZStack {
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appCard,
                            Color.colorTeal.opacity(0.18),
                            Color.colorPurple.opacity(0.22)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card, style: .continuous)
                        .stroke(Color.colorBorder.opacity(0.7), lineWidth: 1)
                )
                .shadow(color: Color.colorTeal.opacity(0.18), radius: 20, y: 10)

            VStack(spacing: DesignTokens.Spacing.md) {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
                    avatarWithRing(progress: levelProgress)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(profile?.name ?? "Guest")
                            .font(.nTitle)
                            .foregroundStyle(Color.colorTextPrimary)
                            .lineLimit(1)

                        HStack(spacing: 6) {
                            levelBadge
                            streakChip
                        }

                        if let joinedAt = profile?.joinedAt {
                            Text("Member since \(joinedAt.formatted(.dateTime.month(.abbreviated).year()))")
                                .font(.caption)
                                .foregroundStyle(Color.colorTextTertiary)
                        }
                    }
                    Spacer(minLength: 0)
                }

                xpProgressBar

                if let goals = profile?.primaryGoals, goals.isEmpty == false {
                    goalChips(goals)
                }
            }
            .padding(DesignTokens.Spacing.lg)
        }
    }

    private func avatarWithRing(progress: Double) -> some View {
        ZStack {
            Circle()
                .stroke(Color.colorBorder.opacity(0.5), lineWidth: 5)
                .frame(width: 86, height: 86)

            Circle()
                .trim(from: 0, to: ringAnimated ? progress : 0)
                .stroke(
                    AngularGradient(
                        colors: [Color.colorTeal, Color.colorGreen, Color.colorPurple, Color.colorTeal],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 86, height: 86)
                .animation(.easeOut(duration: 1.1), value: ringAnimated)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.colorTeal.opacity(0.7), Color.colorPurple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 70, height: 70)
                .overlay(
                    Text(initials)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.colorTextPrimary)
                )
                .shadow(color: Color.colorTeal.opacity(0.35), radius: 12, y: 6)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Avatar with level progress \(Int(progress * 100)) percent")
    }

    private var levelBadge: some View {
        let level = viewModel.userProfile?.currentLevel ?? 1
        return HStack(spacing: 5) {
            Image(systemName: "sparkles")
                .font(.system(size: 10, weight: .bold))
            Text("Level \(level)")
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(Color.white)
        .padding(.horizontal, DesignTokens.Insets.pillHorizontal)
        .padding(.vertical, DesignTokens.Insets.pillVertical)
        .background(
            LinearGradient(
                colors: [Color.colorTeal, Color.colorGreen.opacity(0.88)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.32), lineWidth: 1))
        .shadow(color: Color.colorGreen.opacity(0.24), radius: 8, y: 4)
    }

    private var streakChip: some View {
        let streak = viewModel.userProfile?.currentStreak ?? 0
        return HStack(spacing: 5) {
            Image(systemName: "flame.fill")
                .font(.system(size: 10, weight: .bold))
            Text("\(streak)d streak")
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(Color.colorAmber)
        .padding(.horizontal, DesignTokens.Insets.pillHorizontal)
        .padding(.vertical, DesignTokens.Insets.pillVertical)
        .background(Color.colorAmber.opacity(0.16))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.colorAmber.opacity(0.4), lineWidth: 1))
    }

    private var xpProgressBar: some View {
        let level = viewModel.userProfile?.currentLevel ?? 1
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("XP to Level \(level + 1)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.colorTextSecondary)
                Spacer()
                Text("\(currentXP) / \(xpForNextLevel)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.colorTextPrimary)
                    .monospacedDigit()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.appBackground.opacity(0.6))
                        .frame(height: 8)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.colorTeal, Color.colorGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geo.size.width * (ringAnimated ? levelProgress : 0)), height: 8)
                        .shadow(color: Color.colorGreen.opacity(0.45), radius: 4, y: 1)
                        .animation(.easeOut(duration: 1.1), value: ringAnimated)
                }
            }
            .frame(height: 8)
        }
    }

    private func goalChips(_ goals: [PrimaryGoal]) -> some View {
        HStack(spacing: 6) {
            ForEach(goals) { goal in
                HStack(spacing: 4) {
                    Image(systemName: icon(for: goal))
                        .font(.system(size: 9, weight: .bold))
                    Text(goal.rawValue)
                        .font(.caption2.weight(.bold))
                }
                .foregroundStyle(Color.colorTextPrimary)
                .padding(.horizontal, DesignTokens.Insets.chipHorizontal + 2)
                .padding(.vertical, DesignTokens.Insets.chipVertical)
                .background(Color.appBackground.opacity(0.55))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.colorBorder.opacity(0.6), lineWidth: 1))
            }
            Spacer(minLength: 0)
        }
    }

    private func icon(for goal: PrimaryGoal) -> String {
        switch goal {
        case .focus: return "target"
        case .stressRelief: return "leaf.fill"
        case .memory: return "brain.head.profile"
        case .resilience: return "shield.lefthalf.filled"
        }
    }

    // MARK: - Quick stats

    private var quickStatsRow: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            quickStatTile(icon: "waveform.path.ecg", value: "42", label: "Sessions", tint: .colorTeal)
            quickStatTile(icon: "flame.fill", value: "\(viewModel.userProfile?.currentStreak ?? 0)", label: "Streak", tint: .colorAmber)
            quickStatTile(icon: "chart.bar.fill", value: "78", label: "Avg Score", tint: .colorGreen)
            quickStatTile(icon: "rosette", value: "\(unlockedCount)", label: "Badges", tint: .colorPurple)
        }
    }

    private func quickStatTile(icon: String, value: String, label: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(tint)
                Spacer(minLength: 0)
            }
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(Color.colorTextPrimary)
                .monospacedDigit()
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.colorTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DesignTokens.Insets.cardCompact)
        .padding(.vertical, DesignTokens.Insets.cardRegular)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium, style: .continuous)
                .fill(Color.appCard.opacity(0.85))
        }
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium, style: .continuous)
                .stroke(Color.colorBorder.opacity(0.7), lineWidth: 1)
        )
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(tint.opacity(0.85))
                .frame(height: 3)
                .padding(.horizontal, 14)
                .offset(y: -1.5)
        }
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        let unlocked = viewModel.achievements.filter(\.isUnlocked)
        let locked = viewModel.achievements.filter { $0.isUnlocked == false }
        let total = viewModel.achievements.count
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Achievements")
                        .font(.headline)
                        .foregroundStyle(Color.colorTextPrimary)
                    Text("\(unlocked.count) of \(total) unlocked")
                        .font(.caption)
                        .foregroundStyle(Color.colorTextSecondary)
                }
                Spacer()
                Text("\(Int(achievementsProgress * 100))%")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.colorGreen)
                    .padding(.horizontal, DesignTokens.Insets.pillHorizontal)
                    .padding(.vertical, DesignTokens.Insets.pillVertical)
                    .background(Color.colorGreen.opacity(0.14))
                    .clipShape(Capsule())
            }

            ProgressView(value: achievementsProgress)
                .tint(.colorGreen)

            if unlocked.isEmpty == false {
                Text("Recently unlocked")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.colorTextTertiary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(unlocked) { badge in
                            featuredAchievementCard(badge)
                        }
                    }
                }
            }

            if locked.isEmpty == false {
                Text("Locked")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.colorTextTertiary)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(locked) { badge in
                        lockedAchievementRow(badge)
                    }
                }
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card, style: .continuous)
                .fill(Color.appCard.opacity(0.85))
        }
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card, style: .continuous)
                .stroke(Color.colorBorder.opacity(0.7), lineWidth: 1)
        )
    }

    private func featuredAchievementCard(_ badge: Achievement) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.colorGreen.opacity(0.18))
                    .frame(width: 56, height: 56)
                Circle()
                    .stroke(Color.colorGreen.opacity(0.55), lineWidth: 1.5)
                    .frame(width: 56, height: 56)
                Image(systemName: badge.iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.colorGreen)
            }
            .shadow(color: Color.colorGreen.opacity(0.35), radius: 10, y: 4)

            Text(badge.title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.colorTextPrimary)
                .lineLimit(1)

            if let unlockedAt = badge.unlockedAt {
                Text(unlockedAt.formatted(.relative(presentation: .numeric, unitsStyle: .narrow)))
                    .font(.caption2)
                    .foregroundStyle(Color.colorTextTertiary)
                    .lineLimit(1)
            }
        }
        .frame(width: 108)
        .padding(.vertical, DesignTokens.Insets.cardCompact)
        .padding(.horizontal, DesignTokens.Insets.cardCompact)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large, style: .continuous)
                .fill(Color.appBackground.opacity(0.55))
        }
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.large, style: .continuous)
                .stroke(Color.colorGreen.opacity(0.35), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(badge.title), unlocked")
    }

    private func lockedAchievementRow(_ badge: Achievement) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.colorTextTertiary.opacity(0.12))
                    .frame(width: 34, height: 34)
                Image(systemName: badge.iconName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.colorTextTertiary)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(badge.title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.colorTextSecondary)
                    .lineLimit(1)
                Text(badge.description)
                    .font(.caption2)
                    .foregroundStyle(Color.colorTextTertiary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            Image(systemName: "lock.fill")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.colorTextTertiary)
        }
        .padding(DesignTokens.Insets.cardCompact)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium, style: .continuous)
                .fill(Color.appBackground.opacity(0.4))
        }
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium, style: .continuous)
                .stroke(Color.colorBorder.opacity(0.5), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(badge.title), locked. \(badge.description)")
    }

    // MARK: - Leaderboard

    private var leaderboardSection: some View {
        let entries = viewModel.leaderboardPreview
        let podium = Array(entries.prefix(3))
        let rest = Array(entries.dropFirst(3))
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Weekly Leaderboard")
                        .font(.headline)
                        .foregroundStyle(Color.colorTextPrimary)
                    Text("Top minds this week")
                        .font(.caption)
                        .foregroundStyle(Color.colorTextSecondary)
                }
                Spacer()
                if let userRank = userLeaderboardRank {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 9, weight: .bold))
                        Text("You · #\(userRank)")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(Color.colorTeal)
                    .padding(.horizontal, DesignTokens.Insets.pillHorizontal)
                    .padding(.vertical, DesignTokens.Insets.pillVertical)
                    .background(Color.colorTeal.opacity(0.16))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.colorTeal.opacity(0.4), lineWidth: 1))
                }
            }

            if podium.count == 3 {
                podiumRow(first: podium[0], second: podium[1], third: podium[2])
                    .padding(.top, 4)
            }

            if rest.isEmpty == false {
                VStack(spacing: 6) {
                    ForEach(rest) { entry in
                        leaderboardRow(entry)
                    }
                }
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card, style: .continuous)
                .fill(Color.appCard.opacity(0.85))
        }
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card, style: .continuous)
                .stroke(Color.colorBorder.opacity(0.7), lineWidth: 1)
        )
    }

    private func podiumRow(first: LeaderboardEntry, second: LeaderboardEntry, third: LeaderboardEntry) -> some View {
        HStack(alignment: .bottom, spacing: 10) {
            podiumColumn(entry: second, height: 78, color: .colorTextSecondary, medal: "2", crown: false)
            podiumColumn(entry: first, height: 100, color: .colorAmber, medal: "1", crown: true)
            podiumColumn(entry: third, height: 64, color: Color(red: 0.78, green: 0.49, blue: 0.27), medal: "3", crown: false)
        }
        .frame(maxWidth: .infinity)
    }

    private func podiumColumn(entry: LeaderboardEntry, height: CGFloat, color: Color, medal: String, crown: Bool) -> some View {
        let highlight = isCurrentUser(entry)
        return VStack(spacing: 8) {
            if crown {
                Image(systemName: "crown.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(color)
                    .shadow(color: color.opacity(0.6), radius: 6)
            } else {
                Spacer().frame(height: 16)
            }

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.7), color.opacity(0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 46, height: 46)
                Circle()
                    .stroke(highlight ? Color.colorTeal : color.opacity(0.55), lineWidth: highlight ? 2 : 1.2)
                    .frame(width: 46, height: 46)
                Text(String(entry.alias.prefix(1)).uppercased())
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.colorTextPrimary)
            }

            Text(entry.alias)
                .font(.caption.weight(.bold))
                .foregroundStyle(highlight ? Color.colorTeal : Color.colorTextPrimary)
                .lineLimit(1)

            VStack(spacing: 2) {
                Text("\(entry.score)")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.colorTextPrimary)
                    .monospacedDigit()
                Text(medal)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(color.opacity(0.18))
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .frame(height: height)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.18), color.opacity(0.06)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium, style: .continuous)
                    .stroke(highlight ? Color.colorTeal.opacity(0.65) : color.opacity(0.4), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity)
    }

    private func leaderboardRow(_ entry: LeaderboardEntry) -> some View {
        let highlight = isCurrentUser(entry)
        return HStack(spacing: 10) {
            Text("#\(entry.rank)")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.colorTextSecondary)
                .frame(width: 30, alignment: .leading)

            ZStack {
                Circle()
                    .fill(highlight ? Color.colorTeal.opacity(0.45) : Color.colorPurple.opacity(0.3))
                    .frame(width: 28, height: 28)
                Text(String(entry.alias.prefix(1)).uppercased())
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.colorTextPrimary)
            }

            Text(entry.alias)
                .font(.subheadline.weight(highlight ? .bold : .regular))
                .foregroundStyle(highlight ? Color.colorTeal : Color.colorTextPrimary)
                .lineLimit(1)

            Spacer()

            Text("\(entry.score)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(highlight ? Color.colorTeal : Color.colorTextPrimary)
                .monospacedDigit()
        }
        .padding(.horizontal, DesignTokens.Insets.cardRegular)
        .padding(.vertical, 9)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium, style: .continuous)
                .fill(highlight ? Color.colorTeal.opacity(0.12) : Color.appBackground.opacity(0.45))
        }
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium, style: .continuous)
                .stroke(highlight ? Color.colorTeal.opacity(0.55) : Color.colorBorder.opacity(0.4), lineWidth: 1)
        )
    }

    // MARK: - Team challenge & nav

    private var teamChallengeCard: some View {
        NCard(glow: .colorPurple) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "person.3.sequence.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.colorPurple)
                    Text("Team Challenge")
                        .font(.headline)
                        .foregroundStyle(Color.colorTextPrimary)
                    Spacer()
                    Text("This week")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.colorPurple)
                        .padding(.horizontal, DesignTokens.Insets.pillHorizontal)
                        .padding(.vertical, DesignTokens.Insets.pillVertical)
                        .background(Color.colorPurple.opacity(0.18))
                        .clipShape(Capsule())
                }
                Text("Collectively complete 220 minutes of focus practice this week.")
                    .font(.subheadline)
                    .foregroundStyle(Color.colorTextSecondary)
                ProgressView(value: 0.64)
                    .tint(.colorPurple)
                HStack {
                    Text("140 / 220 min")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.colorTextPrimary)
                    Spacer()
                    Text("64%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.colorPurple)
                }
            }
        }
    }

    private var navigationLinksCard: some View {
        NCard {
            VStack(alignment: .leading, spacing: 10) {
                if appStore.hasPermission(.viewCorporateDashboard) {
                    NavigationLink(value: "corporate") {
                        rowLink(icon: "building.2.fill", title: "Corporate Dashboard", subtitle: "Anonymized team metrics and integrations")
                    }
                    .buttonStyle(.plain)
                    Divider().overlay(Color.colorBorder.opacity(0.5))
                }

                NavigationLink(value: "settings") {
                    rowLink(icon: "gearshape.fill", title: "Settings", subtitle: "Coach personality, sound, privacy, theme")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func rowLink(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.colorTeal.opacity(0.15))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.colorTeal)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.colorTextPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.colorTextSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.colorTextTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, DesignTokens.Spacing.xs)
        .contentShape(Rectangle())
    }

    // MARK: - Derivations

    private var initials: String {
        let name = viewModel.userProfile?.name ?? "G"
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        let parts = trimmed.split(separator: " ")
        if parts.count >= 2, let first = parts.first?.first, let last = parts.last?.first {
            return "\(first)\(last)".uppercased()
        }
        return String(trimmed.prefix(2)).uppercased()
    }

    private var unlockedCount: Int {
        viewModel.achievements.filter(\.isUnlocked).count
    }

    private var achievementsProgress: Double {
        let total = viewModel.achievements.count
        guard total > 0 else { return 0 }
        return Double(unlockedCount) / Double(total)
    }

    private var levelProgress: Double {
        Double(currentXP) / Double(xpForNextLevel)
    }

    private var xpForNextLevel: Int { 1000 }

    private var currentXP: Int {
        let level = max(1, viewModel.userProfile?.currentLevel ?? 1)
        return (level * 137) % xpForNextLevel
    }

    private var userLeaderboardRank: Int? {
        guard let name = viewModel.userProfile?.name else { return nil }
        return viewModel.leaderboardPreview.first { $0.alias == name }?.rank
    }

    private func isCurrentUser(_ entry: LeaderboardEntry) -> Bool {
        viewModel.userProfile?.name == entry.alias
    }
}

#Preview {
    ProfileView(viewModel: GamificationViewModel(repository: MockProfileRepository()))
        .environment(AppStore())
}
