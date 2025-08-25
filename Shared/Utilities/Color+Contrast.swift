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

/// Resolves a countdown card color given an optional override and theme.
/// - Parameters:
///   - theme: Active `ColorTheme` providing the default color.
///   - backgroundStyle: `"color"` or `"image"`.
///   - colorHex: Optional hex override saved with the countdown.
/// - Returns: Chosen color following precedence: override > theme default > white.
func resolvedCardColor(theme: ColorTheme, backgroundStyle: String, colorHex: String?) -> Color {
    guard backgroundStyle == "color" else { return theme.primary }
    let upper = colorHex?.uppercased() ?? ""
    if upper != "" && upper != "#FFFFFF" && upper != theme.primary.hexString.uppercased(),
       let c = Color(hex: upper) {
        return c
    }
    return theme.primary
}
