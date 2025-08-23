import UIKit

enum Haptics {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
