import SwiftUI
import SwiftData

@main
struct CouplesCountApp: App {
    @StateObject private var theme = ThemeManager()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showDeniedInfo = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding {
                    ContentView()
                        .environmentObject(theme)
                        // Use a custom container so the widget and app share data
                        .modelContainer(Persistence.container)
                } else {
                    OnboardingView {
                        showDeniedInfo = true
                    }
                    .environmentObject(theme)
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
        }
    }
}
