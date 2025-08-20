import SwiftUI

// A soft, modern card container we can reuse
struct SettingsCard<Content: View>: View {
    @EnvironmentObject private var theme: ThemeManager
    var content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14, content: content)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
            .padding(.horizontal, 16)
    }
}

// Section label that floats above the card
struct SectionHeader: View {
    let text: String
    var body: some View {
        HStack {
            Text(text.uppercased())
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }
}

// A large, tappable theme swatch
struct ThemeSwatch: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let theme: ColorTheme
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(theme.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? theme.accent : .white.opacity(0.08), lineWidth: isSelected ? 2 : 1)
                    )
                    .frame(height: 88)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, theme.accent)
                        .padding(8)
                        .shadow(radius: 4, y: 2)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Circle().fill(theme.accent).frame(width: 10, height: 10)
                        Circle().fill(.white.opacity(0.85)).frame(width: 10, height: 10)
                        Circle().fill(.black.opacity(0.6)).frame(width: 10, height: 10)
                    }
                    .padding(.top, 12)

                    Text(theme.displayName)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
}

// A tiny live preview of a countdown card inside Settings
struct MiniCountdownPreview: View {
    let title: String
    let days: Int
    let dateText: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.tint.opacity(0.18))
                Text("\(days)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .frame(width: 56, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(dateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.background)
                .shadow(radius: 2, y: 1)
        )
    }
}
