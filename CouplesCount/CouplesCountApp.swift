import SwiftUI
import SwiftData

@main
struct CouplesCountApp: App {
    @StateObject private var pro: ProStatusProvider
    @StateObject private var theme: ThemeManager
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showDeniedInfo = false

    init() {
        let provider = ProStatusProvider()
        _pro = StateObject(wrappedValue: provider)
        let themeManager = ThemeManager()
        _theme = StateObject(wrappedValue: themeManager)
        Entitlements.setProvider(provider)
        if AppConfig.isStrictLight {
            themeManager.setTheme(.light)
        }
        ThemeDevLog.log()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding {
                    ContentView()
                        .environmentObject(theme)
                        .environmentObject(pro)
                        // Use a custom container so the widget and app share data
                        .modelContainer(Persistence.container)
                } else {
                    OnboardingView {
                        showDeniedInfo = true
                    }
                    .environmentObject(theme)
                    .environmentObject(pro)
                }
            }
            .sheet(isPresented: $showDeniedInfo) {
                VStack(spacing: 16) {
                    Text("Notifications Disabled")
                        .font(.headline)
                    Text("Enable notifications anytime in Settings to get reminders.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                    Button("OK") { showDeniedInfo = false }
                        .padding(.top, 8)
                }
                .padding()
                .presentationDetents([.medium])
            }
            .onChange(of: pro.isProPublished, initial: false) { _, newValue in
                if AppConfig.entitlementsMode == .live && !newValue {
                    theme.setTheme(.light)
                }
            }
            .preferredColorScheme(AppConfig.isStrictLight ? .light : nil)
            .applyTheme()
        }
    }
}
