import SwiftUI

enum Theme {
    static let backgroundTop = Color(red: 1.0, green: 0.95, blue: 0.92)
    static let backgroundBottom = Color(red: 1.0, green: 0.90, blue: 0.85)
    static let backgroundGradient = LinearGradient(
        colors: [backgroundTop, backgroundBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let accent = Color.orange
}
