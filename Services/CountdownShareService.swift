import Foundation
import SwiftData
import Compression

struct CountdownShareData: Codable {
    let title: String
    let targetDate: Date
    let timeZoneID: String
    let cardFontStyle: CardFontStyle
    let backgroundStyle: String
    let backgroundColorHex: String?
    let backgroundImageData: Data?

    private enum CodingKeys: String, CodingKey {
        case title, targetDate, timeZoneID, cardFontStyle, backgroundStyle, backgroundColorHex, backgroundImageData
    }

    init(title: String, targetDate: Date, timeZoneID: String, cardFontStyle: CardFontStyle, backgroundStyle: String, backgroundColorHex: String?, backgroundImageData: Data?) {
        self.title = title
        self.targetDate = targetDate
        self.timeZoneID = timeZoneID
        self.cardFontStyle = cardFontStyle
        self.backgroundStyle = backgroundStyle
        self.backgroundColorHex = backgroundColorHex
        self.backgroundImageData = backgroundImageData
    }

    // Backwards compatibility for older payloads that lacked `cardFontStyle`.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        targetDate = try container.decode(Date.self, forKey: .targetDate)
        timeZoneID = try container.decode(String.self, forKey: .timeZoneID)
        backgroundStyle = try container.decode(String.self, forKey: .backgroundStyle)
        backgroundColorHex = try container.decodeIfPresent(String.self, forKey: .backgroundColorHex)
        backgroundImageData = try container.decodeIfPresent(Data.self, forKey: .backgroundImageData)
        cardFontStyle = (try? container.decode(CardFontStyle.self, forKey: .cardFontStyle)) ?? .classic
    }
}

enum CountdownShareError: LocalizedError {
    case invalidURL
    case decodeFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Link is invalid."
        case .decodeFailed: return "Could not decode countdown."
        }
    }
}

enum CountdownShareService {
    /// Encodes a countdown into a compact shareable URL.
    /// The payload is encoded as a binary property list, compressed,
    /// then base64 encoded so the resulting link is much shorter than
    /// the previous JSON-only approach.
    static func exportURL(for countdown: Countdown) -> URL? {
        let payload = CountdownShareData(
            title: countdown.title,
            targetDate: countdown.targetDate,
            timeZoneID: countdown.timeZoneID,
            cardFontStyle: countdown.cardFontStyle,
            backgroundStyle: countdown.backgroundStyle,
            backgroundColorHex: countdown.backgroundColorHex,
            backgroundImageData: countdown.backgroundImageData
        )

        // Encode using a binary property list to avoid the inherent base64
        // expansion that JSON introduces for `Data` properties.
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        guard
            let plist = try? encoder.encode(payload),
            let compressed = try? plist.compressed(using: COMPRESSION_LZFSE)

        else { return nil }

        let base64 = compressed.base64EncodedString()
        var components = URLComponents()
        components.scheme = "couplescount"
        components.host = "import"
        components.queryItems = [URLQueryItem(name: "data", value: base64)]
        return components.url
    }

    /// Imports a countdown from a previously generated share URL.
    static func importCountdown(from url: URL, context: ModelContext) throws {
        guard
            url.scheme == "couplescount",
            url.host == "import",
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let dataItem = components.queryItems?.first(where: { $0.name == "data" })?.value,
            let data = Data(base64Encoded: dataItem),
            let decompressed = try? data.decompressed(using: COMPRESSION_LZFSE)

        else { throw CountdownShareError.invalidURL }

        let decoder = PropertyListDecoder()
        guard let payload = try? decoder.decode(CountdownShareData.self, from: decompressed) else {
            throw CountdownShareError.decodeFailed
        }

        let cd = Countdown(
            title: payload.title,
            targetDate: payload.targetDate,
            timeZoneID: payload.timeZoneID,
            cardFontStyle: payload.cardFontStyle,
            backgroundStyle: payload.backgroundStyle,
            backgroundColorHex: payload.backgroundColorHex,
            backgroundImageData: payload.backgroundImageData
        )
        context.insert(cd)
        try context.save()
        NotificationManager.scheduleReminders(for: cd)
        let all = try context.fetch(FetchDescriptor<Countdown>())
        updateWidgetSnapshot(afterSaving: all)
    }
}

