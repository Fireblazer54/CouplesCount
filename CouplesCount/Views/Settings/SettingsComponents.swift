import SwiftUI

// A soft, modern card container we can reuse
struct SettingsCard<Content: View>: View {
    @Environment(\.theme) private var theme
    var content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14, content: content)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(theme.color(.Card))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(theme.color(.Border), lineWidth: 1)
                    )
            )
            .shadow(color: theme.color(.Foreground).opacity(0.12), radius: 12, y: 6)
            .padding(.horizontal, 16)
    }
}

// Section label that floats above the card
struct SectionHeader: View {
    @Environment(\.theme) private var theme
    let text: String
    var body: some View {
        HStack {
            Text(text.uppercased())
                .font(.footnote.weight(.semibold))
                .foregroundStyle(theme.color(.MutedForeground))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }
}

// A large, tappable theme swatch
struct ThemeSwatch: View {
    let theme: ColorTheme
    let isSelected: Bool
    let isLocked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(theme.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? theme.primary : .clear, lineWidth: 2)
                    )
                    .frame(height: 88)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(theme.primary, theme.textPrimary)
                        .padding(8)
                        .shadow(color: theme.textPrimary.opacity(0.4), radius: 4, y: 2)
                        .accessibilityHidden(true)
                }

                if isLocked {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .accessibilityHidden(true)
                        Text("Pro")
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(theme.textPrimary)
                    .padding(6)
                    .background(theme.accent)
                    .clipShape(Capsule())
                    .padding(6)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Circle().fill(theme.accent).frame(width: 10, height: 10)
                        Circle().fill(theme.textPrimary).frame(width: 10, height: 10)
                        Circle().fill(theme.textSecondary).frame(width: 10, height: 10)
                    }
                    .padding(.top, 12)

                    Text(theme.displayName)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(theme.textPrimary)
                        .lineLimit(1)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
}

struct SettingsButtonRow: View {
    @Environment(\.theme) private var theme
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(theme.color(.Foreground))
                    .frame(width: 30, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.color(.Foreground).opacity(0.1))
                    )
                    .accessibilityHidden(true)
                Text(title)
                    .font(.body)
                    .foregroundStyle(theme.color(.Foreground))
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct SettingsKeyValueRow: View {
    @Environment(\.theme) private var theme
    let key: String
    let value: String

    var body: some View {
        HStack {
            Text(key)
                .foregroundStyle(theme.color(.Foreground))
            Spacer()
            Text(value)
                .foregroundStyle(theme.color(.MutedForeground))
        }
        .font(.body)
    }
}

