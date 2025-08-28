import SwiftUI

/// Provides fonts for countdown cards across SwiftUI and UIKit.
struct CardTypography {
    enum Role {
        case title
        case number
        case date
    }

    /// SwiftUI font for a given style and role.
    static func font(for style: CardFontStyle, role: Role) -> Font {
        let font = Font(uiFont(for: style, role: role))
        return role == .number ? font.monospacedDigit() : font
    }

    /// UIKit font for a given style and role.
    static func uiFont(for style: CardFontStyle, role: Role) -> UIFont {
        let (textStyle, weight): (UIFont.TextStyle, UIFont.Weight) = {
            switch role {
            case .title: return (.headline, .semibold)
            case .number: return (.largeTitle, .black)
            case .date: return (.footnote, .regular)
            }
        }()
        let baseSize = UIFont.preferredFont(forTextStyle: textStyle).pointSize
        let name = style.fontName

        // Attempt to load the desired font; fallback to system if unavailable.
        var font: UIFont
        if let name = name, let custom = UIFont(name: name, size: baseSize) {
            let descriptor = custom.fontDescriptor.addingAttributes([
                UIFontDescriptor.AttributeName.traits: [
                    UIFontDescriptor.TraitKey.weight: weight
                ]
            ])
            font = UIFont(descriptor: descriptor, size: baseSize)
        } else {
            font = UIFont.systemFont(ofSize: baseSize, weight: weight)
        }
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }
}

