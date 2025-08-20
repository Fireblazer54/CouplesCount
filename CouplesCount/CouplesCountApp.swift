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
                .onAppear {
                    NotificationManager.requestAuthorizationIfNeeded()   // ← add
                }
        }
    }
}
