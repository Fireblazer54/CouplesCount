import Foundation
import SwiftData

@Model
final class Countdown {
    var id: UUID
    var title: String
    var targetDate: Date
    var timeZoneID: String
    var isArchived: Bool

    // Background
    // "color" or "image"
    var backgroundStyle: String
    // HEX like "#3871FF" when style == "color"
    var backgroundColorHex: String?
    // Raw image data (jpeg) when style == "image"
    var backgroundImageData: Data?

    // Reminder offset in minutes before target (nil = no reminder)
    var reminderOffsetMinutes: Int?

    init(id: UUID = UUID(),
         title: String,
         targetDate: Date,
         timeZoneID: String,
         isArchived: Bool = false,
         backgroundStyle: String = "color",
         backgroundColorHex: String? = "#0A84FF",
         backgroundImageData: Data? = nil,
         reminderOffsetMinutes: Int? = nil) {
        self.id = id
        self.title = title
        self.targetDate = targetDate
        self.timeZoneID = timeZoneID
        self.isArchived = isArchived
        self.backgroundStyle = backgroundStyle
        self.backgroundColorHex = backgroundColorHex
        self.backgroundImageData = backgroundImageData
        self.reminderOffsetMinutes = reminderOffsetMinutes
    }
}
