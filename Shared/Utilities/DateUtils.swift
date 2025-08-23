import SwiftUI

enum DateUtils {
    static func daysUntil(target: Date, in tzID: String) -> Int {
        let tz = TimeZone(identifier: tzID) ?? .current
        var cal = Calendar.current; cal.timeZone = tz
        let s = cal.startOfDay(for: .now)
        let e = cal.startOfDay(for: target)
        return cal.dateComponents([.day], from: s, to: e).day ?? 0
    }

    static func remainingText(to target: Date, from now: Date = .now, in tzID: String) -> String {
        let tz = TimeZone(identifier: tzID) ?? .current
        var cal = Calendar.current; cal.timeZone = tz

        if now >= target { return "Today" }

        let comps = cal.dateComponents([.day, .hour, .minute], from: now, to: target)
        let d = comps.day ?? 0
        if d >= 1 {
            return "\(d) day" + (d == 1 ? "" : "s")
        }

        let h = comps.hour ?? 0
        if h >= 1 {
            return "\(h) hour" + (h == 1 ? "" : "s")
        }

        let m = comps.minute ?? 0
        if m >= 1 {
            return "\(m) minute" + (m == 1 ? "" : "s")
        }

        return "Today"
    }

    static let readableDate: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
}

extension Color {
    init?(hex: String) {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if str.hasPrefix("#") { str.removeFirst() }
        guard str.count == 6, let v = Int(str, radix: 16) else { return nil }
        self = Color(red: Double((v >> 16) & 0xFF)/255,
                     green: Double((v >> 8) & 0xFF)/255,
                     blue: Double(v & 0xFF)/255)
    }
    var hexString: String {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        let v = (Int(r*255)<<16) | (Int(g*255)<<8) | (Int(b*255)<<0)
        return String(format: "#%06X", v)
    }
}
