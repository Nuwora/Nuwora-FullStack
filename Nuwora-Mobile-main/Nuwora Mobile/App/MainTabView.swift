import SwiftUI
import UIKit

struct MainTabView: View {
    @Environment(AppStore.self) private var appStore
    @State private var loadedTabs: Set<TabItem> = [.home]
    @State private var dashboardViewModel: DashboardViewModel?
    @State private var coachViewModel: CoachViewModel?
    @State private var planViewModel: PlanViewModel?
    @State private var analyticsViewModel: AnalyticsViewModel?
    @State private var profileViewModel: GamificationViewModel?

    init() {
        configureTabBarAppearance()
    }

    var body: some View {
        @Bindable var appStore = appStore

        Group {
            if #available(iOS 26, *) {
                tabContainer(selectedTab: $appStore.selectedTab)
                    .tabBarStyle(.automatic)
            } else {
                tabContainer(selectedTab: $appStore.selectedTab)
            }
        }
        .tint(Color.accent)
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            prepareViewModelsIfNeeded()
            loadedTabs.insert(appStore.selectedTab)
        }
        .onChange(of: appStore.selectedTab) { _, newTab in
            loadedTabs.insert(newTab)
        }
    }

    private func tabContainer(selectedTab: Binding<TabItem>) -> some View {
        TabView(selection: selectedTab) {
            ForEach(TabItem.allCases) { tab in
                Group {
                    if loadedTabs.contains(tab) {
                        tabView(for: tab)
                    } else {
                        Color.clear
                    }
                }
                .tabItem {
                    Label(tab.tabLabel, systemImage: tab.icon)
                }
                .tag(tab)
            }
        }
    }

    @ViewBuilder
    private func tabView(for tab: TabItem) -> some View {
        switch tab {
        case .home:
            DashboardView(
                viewModel: dashboardViewModel ?? DashboardViewModel(
                    repository: appStore.dependencies.dashboardRepository,
                    profileRepository: appStore.dependencies.profileRepository
                )
            )
        case .coach:
            CoachView(viewModel: coachViewModel ?? CoachViewModel(repository: appStore.dependencies.coachRepository))
        case .mindGym:
            PlanView(viewModel: planViewModel ?? PlanViewModel(repository: appStore.dependencies.planRepository))
        case .insights:
            InsightsView(viewModel: analyticsViewModel ?? AnalyticsViewModel(repository: appStore.dependencies.analyticsRepository))
        case .profile:
            ProfileView(viewModel: profileViewModel ?? GamificationViewModel(repository: appStore.dependencies.profileRepository))
        }
    }

    private func prepareViewModelsIfNeeded() {
        if dashboardViewModel == nil {
            dashboardViewModel = DashboardViewModel(
                repository: appStore.dependencies.dashboardRepository,
                profileRepository: appStore.dependencies.profileRepository
            )
        }
        if coachViewModel == nil {
            coachViewModel = CoachViewModel(repository: appStore.dependencies.coachRepository)
        }
        if planViewModel == nil {
            planViewModel = PlanViewModel(repository: appStore.dependencies.planRepository)
        }
        if analyticsViewModel == nil {
            analyticsViewModel = AnalyticsViewModel(repository: appStore.dependencies.analyticsRepository)
        }
        if profileViewModel == nil {
            profileViewModel = GamificationViewModel(repository: appStore.dependencies.profileRepository)
        }
    }

    private func configureTabBarAppearance() {
        let selectedColor = UIColor(Color.accent)
        let unselectedColor = UIColor(Color.textSecondary)

        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()

        configureItemAppearance(appearance.stackedLayoutAppearance, selected: selectedColor, unselected: unselectedColor)
        configureItemAppearance(appearance.inlineLayoutAppearance, selected: selectedColor, unselected: unselectedColor)
        configureItemAppearance(appearance.compactInlineLayoutAppearance, selected: selectedColor, unselected: unselectedColor)

        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.standardAppearance = appearance
        tabBarAppearance.scrollEdgeAppearance = appearance
        tabBarAppearance.unselectedItemTintColor = unselectedColor
        tabBarAppearance.tintColor = selectedColor
    }

    private func configureItemAppearance(
        _ itemAppearance: UITabBarItemAppearance,
        selected: UIColor,
        unselected: UIColor
    ) {
        itemAppearance.normal.iconColor = unselected
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: unselected]
        itemAppearance.selected.iconColor = selected
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: selected]
    }
}

private enum NativeTabBarStyle {
    case automatic
}

private extension View {
    @ViewBuilder
    func tabBarStyle(_ style: NativeTabBarStyle) -> some View {
        switch style {
        case .automatic:
            tabViewStyle(.automatic)
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppStore())
}
