import SwiftUI

extension Color {
    /// Rough luminance check to decide whether the color is perceived as light.
    var isLight: Bool {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        // Standard luminance formula
        return (0.299 * r + 0.587 * g + 0.114 * b) > 0.6
    }

    /// Primary text color that contrasts with this color.
    var readablePrimary: Color { isLight ? .black : .white }

    /// Secondary text color that contrasts with this color.
    var readableSecondary: Color { isLight ? Color.black.opacity(0.7) : Color.white.opacity(0.9) }
}

/// Resolves a countdown card color given an optional override.
/// - Parameters:
///   - backgroundStyle: `"color"` or `"image"`.
///   - colorHex: Optional hex override saved with the countdown.
/// - Returns: Chosen color following precedence: override > default > fallback.
func resolvedCardColor(backgroundStyle: String, colorHex: String?) -> Color {
    guard backgroundStyle == "color" else { return Color("Primary") }
    let upper = colorHex?.uppercased() ?? ""
    let first = upper.split(separator: ",").first.map(String.init) ?? upper
    if first != "" && first != "#FFFFFF", let c = Color(hex: first) {
        return c
    }
    return Color("Primary")
}
