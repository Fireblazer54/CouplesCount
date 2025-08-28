import SwiftUI

// A soft, modern card container we can reuse
struct SettingsCard<Content: View>: View {
    var content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14, content: content)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.12), radius: 12, y: 6)
            .padding(.horizontal, 16)
    }
}

struct SettingsButtonRow: View {
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
                    .foregroundStyle(Color("Foreground"))
                    .frame(width: 30, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("Foreground").opacity(0.1))
                    )
                    .accessibilityHidden(true)
                Text(title)
                    .font(.body)
                    .foregroundStyle(Color("Foreground"))
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct SettingsKeyValueRow: View {
    let key: String
    let value: String

    var body: some View {
        HStack {
            Text(key)
                .foregroundStyle(Color("Foreground"))
            Spacer()
            Text(value)
                .foregroundStyle(Color("Secondary"))
        }
        .font(.body)
    }
}

