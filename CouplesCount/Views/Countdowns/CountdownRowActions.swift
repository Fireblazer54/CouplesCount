import SwiftUI
import UIKit

@ViewBuilder
func DeleteSwipeButton(
    _ action: @escaping () -> Void,
    label: String = "Delete",
    hint: String = "Remove countdown",
    iconOnly: Bool = true,
    background: Color = .red,
    foreground: Color = .white
) -> some View {
    Button(role: .destructive, action: action) {
        if iconOnly {
            Image(systemName: "trash")
                .font(.system(size: UIFontMetrics(forTextStyle: .body).scaledValue(for: 16), weight: .bold))
                .frame(width: 44, height: 44)
                .background(Circle().fill(background))
                .foregroundStyle(foreground)
                .accessibilityLabel(label)
                .accessibilityHint(hint)
        } else {
            Label(label, systemImage: "trash")
        }
    }
    .tint(iconOnly ? .clear : background)
    .contentShape(Rectangle())
}

@ViewBuilder
func ArchiveSwipeButton(
    _ action: @escaping () -> Void,
    label: String = "Archive",
    systemImage: String = "archivebox",
    hint: String = "Archive countdown",
    iconOnly: Bool = true,
    background: Color = .blue,
    foreground: Color = .white
) -> some View {
    Button(action: action) {
        if iconOnly {
            Image(systemName: systemImage)
                .font(.system(size: UIFontMetrics(forTextStyle: .body).scaledValue(for: 16), weight: .bold))
                .frame(width: 44, height: 44)
                .background(Circle().fill(background))
                .foregroundStyle(foreground)
                .accessibilityLabel(label)
                .accessibilityHint(hint)
        } else {
            Label(label, systemImage: systemImage)
        }
    }
    .tint(iconOnly ? .clear : background)
    .contentShape(Rectangle())
}

@ViewBuilder
func ShareSwipeButton(
    _ action: @escaping () -> Void,
    label: String = "Share",
    hint: String = "Share countdown",
    iconOnly: Bool = true,
    background: Color = .blue,
    foreground: Color = .white
) -> some View {
    Button(action: action) {
        if iconOnly {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: UIFontMetrics(forTextStyle: .body).scaledValue(for: 16), weight: .bold))
                .frame(width: 44, height: 44)
                .background(Circle().fill(background))
                .foregroundStyle(foreground)
                .accessibilityLabel(label)
                .accessibilityHint(hint)
        } else {
            Label(label, systemImage: "square.and.arrow.up")
        }
    }
    .tint(iconOnly ? .clear : background)
    .contentShape(Rectangle())
}

