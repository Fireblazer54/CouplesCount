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

