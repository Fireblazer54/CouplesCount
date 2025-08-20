import SwiftUI
import SwiftData

@main
struct CouplesCountApp: App {
    @StateObject private var theme = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(theme)
                .modelContainer(for: Countdown.self)
                // Use a custom container so the widget and app share data
                .modelContainer(Persistence.container)
                .onAppear {
                    NotificationManager.requestAuthorizationIfNeeded()   // ← add
                    NotificationManager.requestAuthorizationIfNeeded()
                }
        }
    }
}
