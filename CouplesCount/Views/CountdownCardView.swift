import SwiftUI

struct CountdownCardView: View {
    @EnvironmentObject private var theme: ThemeManager

    let title: String
    let daysLeft: Int
    let dateText: String
    let archived: Bool

    private let corner: CGFloat = 22
    private let height: CGFloat = 120

    var body: some View {
        ZStack(alignment: .leading) {
            // Themed background (simple, sleek)
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(LinearGradient(
                    colors: [accent, accent.opacity(0.75)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .overlay(                         // tiny inner highlight
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 10, y: 6)

            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)

                Text("\(daysLeft) days")
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                Text(dateText)
                    .font(.footnote)
                    .opacity(0.95)
            }
            .padding(18)
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
        .saturation(archived ? 0 : 1)
        .opacity(archived ? 0.55 : 1)
        .animation(.easeInOut(duration: 0.2), value: archived)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(daysLeft) days, \(dateText)")
    }

    private var accent: Color { theme.theme.accent }
}
