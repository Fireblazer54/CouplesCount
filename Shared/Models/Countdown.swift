import Foundation
import SwiftData

@Model
final class Countdown {
    var id: UUID
    var title: String
    var targetDate: Date
    var timeZoneID: String
    var isArchived: Bool

    // Title font style ("default", "rounded", etc.)
    var titleFontName: String

    // Background
    // "color" or "image"
    var backgroundStyle: String
    // HEX like "#3871FF" when style == "color"
    var backgroundColorHex: String?
    // Raw image data (jpeg) when style == "image"
    var backgroundImageData: Data?

    // Reminder offset in minutes before target (nil = no reminder)
    var reminderOffsetMinutes: Int?

    // Sharing
    var isShared: Bool
    @Relationship(deleteRule: .cascade) var sharedWith: [Friend]

    init(id: UUID = UUID(),
         title: String,
         targetDate: Date,
         timeZoneID: String,
         isArchived: Bool = false,
         titleFontName: String = TitleFont.default.rawValue,
         backgroundStyle: String = "color",
         backgroundColorHex: String? = "#0A84FF",
         backgroundImageData: Data? = nil,
         reminderOffsetMinutes: Int? = nil,
         isShared: Bool = false,
         sharedWith: [Friend] = []) {
        self.id = id
        self.title = title
        self.targetDate = targetDate
        self.timeZoneID = timeZoneID
        self.isArchived = isArchived
        self.titleFontName = titleFontName
        self.backgroundStyle = backgroundStyle
        self.backgroundColorHex = backgroundColorHex
        self.backgroundImageData = backgroundImageData
        self.reminderOffsetMinutes = reminderOffsetMinutes
        self.isShared = isShared
        self.sharedWith = sharedWith
    }
}
