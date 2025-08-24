import SwiftUI

struct WidgetPreview: View {
    let title: String
    let targetDate: Date
    let tzID: String
    let style: CardFontStyle
    let backgroundStyle: String
    let bgColorHex: String?
    let imageData: Data?

    @State private var now = Date()

    private var isDefaultBackground: Bool {
        if backgroundStyle == "image" { return false }
        let hex = bgColorHex?.uppercased() ?? ""
        return hex == "" || hex == "#FFFFFF"
    }

    private var primaryText: Color { isDefaultBackground ? .black : .white }
    private var secondaryText: Color { isDefaultBackground ? .black.opacity(0.7) : .white.opacity(0.9) }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(backgroundFill)
                .overlay(
                    Group {
                        if let data = imageData, backgroundStyle == "image", let ui = UIImage(data: data) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                .accessibilityHidden(true)
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.black.opacity(0.25), lineWidth: 1)
                )
                .frame(height: 140)

            VStack(spacing: 6) {
                Text(title)
                    .font(CardTypography.font(for: style, role: .title))
                    .foregroundStyle(primaryText)
                    .lineLimit(1)

                Text(DateUtils.remainingText(to: targetDate, from: now, in: tzID))
                    .font(CardTypography.font(for: style, role: .number))
                    .foregroundStyle(primaryText)

                Text(targetDate, style: .date)
                    .font(CardTypography.font(for: style, role: .date))
                    .foregroundStyle(secondaryText)
            }
            .shadow(color: isDefaultBackground ? .black.opacity(0.1) : .black.opacity(0.3), radius: 6, y: 3)
            .padding()
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { now = $0 }
    }

    private var backgroundFill: some ShapeStyle {
        if backgroundStyle == "color", let hex = bgColorHex?.uppercased(), hex != "#FFFFFF", let c = Color(hex: hex) {
            return AnyShapeStyle(LinearGradient(colors: [c, c.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        return AnyShapeStyle(Color.white)
    }
}
