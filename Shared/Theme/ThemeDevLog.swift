#if DEBUG
import Foundation

enum ThemeDevLog {
    static func log() {
        let colors = 25
        let updated = ["ContentView", "ProfileView", "CountdownListView"].joined(separator: ", ")
        let approximated = ["Foreground", "Secondary", "Ring", "Destructive (dark)", "DestructiveForeground (dark)"]
            .joined(separator: ", ")
        print("Theme setup: \(colors) colors, updated: \(updated), approximated: \(approximated)")
    }
}
#endif
