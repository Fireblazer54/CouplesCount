import Foundation
import UserNotifications

enum NotificationManager {
    static func requestAuthorizationIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        }
    }

    static func scheduleReminders(for cd: Countdown) {
        for offset in cd.reminderOffsets {
            let content = UNMutableNotificationContent()
            content.title = "Upcoming: \(cd.title)"
            content.body = "Happening soon."
            content.sound = .default

            // Fire at targetDate + offset (offset negative = before event)
            let fire = cd.targetDate.addingTimeInterval(TimeInterval(offset * 60))
            guard fire > Date() else { continue }

            let comps = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: fire)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let req = UNNotificationRequest(identifier: "cd-\(cd.id)-\(offset)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(req)
        }
    }

    static func cancelAll(for id: UUID) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { reqs in
            let toRemove = reqs.filter { $0.identifier.hasPrefix("cd-\(id)") }.map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: toRemove)
        }
    }
}
