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

    private var cardColor: Color {
        resolvedCardColor(backgroundStyle: backgroundStyle, colorHex: bgColorHex)
    }

    private var primaryText: Color { cardColor.readablePrimary }

    private var secondaryText: Color { cardColor.readableSecondary }

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
                        .stroke(Color("Border"), lineWidth: 1)
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
            .shadow(color: cardColor.isLight ? .black.opacity(0.1) : .black.opacity(0.3), radius: 6, y: 3)
            .padding()
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { now = $0 }
    }

    private var backgroundFill: some ShapeStyle {
        if backgroundStyle == "color" {
            if let hex = bgColorHex, hex.contains(",") {
                let parts = hex.split(separator: ",")
                if let c1 = Color(hex: String(parts[0])),
                   let c2 = Color(hex: String(parts.count > 1 ? parts[1] : parts[0])) {
                    return AnyShapeStyle(LinearGradient(colors: [c1, c2], startPoint: .topLeading, endPoint: .bottomTrailing))
                }
            }
            let c = cardColor
            return AnyShapeStyle(c)
        }
        return AnyShapeStyle(Color("Primary"))
    }
}
