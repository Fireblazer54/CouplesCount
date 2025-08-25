import UIKit
import CoreHaptics

enum Haptics {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    private static var engine: CHHapticEngine?
    private static var lastLong: Date = .distantPast

    static func long() {
        let now = Date()
        guard now.timeIntervalSince(lastLong) > 0.5 else { return }
        lastLong = now
        if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            do {
                if engine == nil { engine = try CHHapticEngine() }
                try engine?.start()
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.4)
                let pattern = try CHHapticPattern(events: [event], parameters: [])
                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
                engine?.notifyWhenPlayersFinished { _ in .stopEngine }
            } catch {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        } else {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
}
