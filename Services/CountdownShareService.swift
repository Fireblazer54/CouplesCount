import Foundation
import SwiftData

struct CountdownShareData: Codable {
    let title: String
    let targetDate: Date
    let timeZoneID: String
    let backgroundStyle: String
    let backgroundColorHex: String?
    let backgroundImageData: Data?
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
    static func exportURL(for countdown: Countdown) -> URL? {
        let payload = CountdownShareData(
            title: countdown.title,
            targetDate: countdown.targetDate,
            timeZoneID: countdown.timeZoneID,
            backgroundStyle: countdown.backgroundStyle,
            backgroundColorHex: countdown.backgroundColorHex,
            backgroundImageData: countdown.backgroundImageData
        )
        guard let json = try? JSONEncoder().encode(payload) else { return nil }
        let base64 = json.base64EncodedString()
        guard let escaped = base64.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        return URL(string: "couplescount://import?data=\(escaped)")
    }

    static func importCountdown(from url: URL, context: ModelContext) throws {
        guard
            url.scheme == "couplescount",
            url.host == "import",
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let dataItem = components.queryItems?.first(where: { $0.name == "data" })?.value,
            let decodedBase64 = dataItem.removingPercentEncoding,
            let data = Data(base64Encoded: decodedBase64)
        else { throw CountdownShareError.invalidURL }

        guard let payload = try? JSONDecoder().decode(CountdownShareData.self, from: data) else {
            throw CountdownShareError.decodeFailed
        }

        let cd = Countdown(
            title: payload.title,
            targetDate: payload.targetDate,
            timeZoneID: payload.timeZoneID,
            backgroundStyle: payload.backgroundStyle,
            backgroundColorHex: payload.backgroundColorHex,
            backgroundImageData: payload.backgroundImageData
        )
        context.insert(cd)
        try context.save()
    }
}

