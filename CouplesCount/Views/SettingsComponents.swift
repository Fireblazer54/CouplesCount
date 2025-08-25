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
                    .fill(theme.theme.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.black, lineWidth: 1)
                    )
            )
            .shadow(color: theme.theme.textPrimary.opacity(0.12), radius: 12, y: 6)
            .padding(.horizontal, 16)
    }
}

// Section label that floats above the card
struct SectionHeader: View {
    @EnvironmentObject private var theme: ThemeManager
    let text: String
    var body: some View {
        HStack {
            Text(text.uppercased())
                .font(.footnote.weight(.semibold))
                .foregroundStyle(theme.theme.textSecondary)
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

