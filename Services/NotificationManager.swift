import Foundation
import UserNotifications

enum NotificationManager {
    private static let defaultsKey = "notificationsAuthorized"

    private static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            AppGroup.defaults.set(granted, forKey: defaultsKey)
            #if DEBUG
            if let error = error {
                print("Notification authorization error: \(error)")
            } else if !granted {
                print("Notification authorization denied")
            }
            #endif
        }
    }

    static func requestAuthorizationIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                requestAuthorization()
            case .authorized:
                AppGroup.defaults.set(true, forKey: defaultsKey)
            default:
                AppGroup.defaults.set(false, forKey: defaultsKey)
            }
        }
    }

    static func scheduleReminders(for countdown: Countdown) {
        let tz = TimeZone(identifier: countdown.timeZoneID) ?? .current
        var cal = Calendar.current; cal.timeZone = tz

        for offsetMinutes in countdown.reminderOffsets {
            let content = UNMutableNotificationContent()
            content.title = "Upcoming: \(countdown.title)"
            content.body = "Happening soon."
            content.sound = .default

            // Fire at target date minus offset minutes
            guard let fire = cal.date(byAdding: .minute, value: -offsetMinutes, to: countdown.targetUTC) else { continue }
            guard fire > Date() else { continue }

            let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: fire)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let identifier = "cd-\(countdown.id.uuidString)-\(offsetMinutes)"
            let req = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(req) { error in
                #if DEBUG
                if let error = error {
                    print("Notification scheduling error: \(error)")
                }
                #endif
            }
        }
    }

    static func cancelAll(for id: UUID) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { reqs in
            let prefix = "cd-\(id.uuidString)-"
            let toRemove = reqs.filter { $0.identifier.hasPrefix(prefix) }.map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: toRemove)
        }
    }

    static func cancelReminders(for id: UUID) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { reqs in
            let prefix = "cd-\(id.uuidString)-"
            let toRemove = reqs.filter { $0.identifier.hasPrefix(prefix) }.map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: toRemove)
        }
    }

    static func scheduleCheckInReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Check in"
        content.body = "See how your countdowns are doing."
        content.sound = .default

        var cal = Calendar.current
        cal.timeZone = .current
        let tomorrow = cal.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        var comps = cal.dateComponents([.year, .month, .day], from: tomorrow)
        comps.hour = 9
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let req = UNNotificationRequest(identifier: "checkin-\(UUID().uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }
}
