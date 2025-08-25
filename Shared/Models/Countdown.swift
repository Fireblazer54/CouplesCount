import Foundation
import SwiftData

@Model
final class Countdown {
    var id: UUID
    var title: String
    @Attribute(originalName: "targetDate") var targetUTC: Date
    var timeZoneID: String
    var includeTime: Bool
    @Attribute(originalName: "backgroundColorHex") var colorTheme: String
    var hasImage: Bool
    @Attribute(originalName: "backgroundImageData") var imageData: Data?
    @Attribute var cardFontStyleRaw: String = CardFontStyle.classic.rawValue
    @Attribute(originalName: "reminderOffsets") var reminderOffsetsMinutes: [Int]
    var lastEdited: Date
    var version: Int
    var ownerUserID: String?

    // Legacy fields
    var backgroundStyle: String
    var isArchived: Bool
    var isShared: Bool
    @Relationship(deleteRule: .cascade) var sharedWith: [Friend]

    // Backwards-compatible accessors
    var targetDate: Date {
        get { targetUTC }
        set { targetUTC = newValue }
    }

    var cardFontStyle: CardFontStyle {
        get { CardFontStyle(rawValue: cardFontStyleRaw) ?? .classic }
        set { cardFontStyleRaw = newValue.rawValue }
    }

    var backgroundColorHex: String? {
        get { colorTheme }
        set { colorTheme = newValue ?? colorTheme }
    }

    var backgroundImageData: Data? {
        get { imageData }
        set { imageData = newValue }
    }

    var reminderOffsets: [Int] {
        get { reminderOffsetsMinutes }
        set { reminderOffsetsMinutes = newValue }
    }

    init(id: UUID = UUID(),
         title: String,
         targetDate: Date,
         timeZoneID: String,
         isArchived: Bool = false,
         cardFontStyle: CardFontStyle = .classic,
         backgroundStyle: String = "color",
         backgroundColorHex: String? = "#F9FBFF",
         backgroundImageData: Data? = nil,
         reminderOffsets: [Int] = [],
         isShared: Bool = false,
         sharedWith: [Friend] = []) {
        self.id = id
        self.title = title
        self.targetUTC = targetDate
        self.timeZoneID = timeZoneID
        self.includeTime = true
        self.colorTheme = backgroundColorHex ?? "#F9FBFF"
        self.hasImage = backgroundStyle == "image"
        self.imageData = backgroundImageData
        self.cardFontStyleRaw = cardFontStyle.rawValue
        self.reminderOffsetsMinutes = reminderOffsets
        self.lastEdited = .now
        self.version = 1
        self.ownerUserID = nil
        self.backgroundStyle = backgroundStyle
        self.isArchived = isArchived
        self.isShared = isShared
        self.sharedWith = sharedWith
    }
}
