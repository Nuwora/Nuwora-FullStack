import SwiftUI
import SwiftData

@main
struct Nuwora_MobileApp: App {
    @State private var appStore: AppStore
    @State private var isShowingSplash = true
    private let container: ModelContainer
    // Mirrors the same key written by SettingsView; triggers re-render on change
    @AppStorage("settings.theme") private var selectedTheme = "Auto"

    init() {
        DomainRuleChecks.runInDebug()
        let bootstrap = SwiftDataStack.bootstrapContainer()
        let appEnvironment = AppEnvironment.fromProcess()
        let dependencies = AppDependencies.make(environment: appEnvironment)
        _appStore = State(
            initialValue: AppStore(
                dependencies: dependencies,
                degradedMode: bootstrap.isDegradedMode
            )
        )
        container = bootstrap.container
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                AppRootView()
                    .environment(appStore)
                    .modelContainer(container)

                if isShowingSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .preferredColorScheme(resolvedColorScheme)
            .task {
                guard isShowingSplash else { return }
                try? await Task.sleep(for: .milliseconds(1050))
                withAnimation(.easeInOut(duration: 0.42)) {
                    isShowingSplash = false
                }
            }
        }
    }

    private var resolvedColorScheme: ColorScheme? {
        switch selectedTheme {
        case "Light": return .light
        case "Dark":  return .dark
        default:      return nil  // "Auto" — follow system
        }
    }
}
