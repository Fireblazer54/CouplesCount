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
                .frame(height: 140)

            VStack(spacing: 6) {
                Text(title)
                    .font(CardTypography.font(for: style, role: .title))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(DateUtils.remainingText(to: targetDate, from: now, in: tzID))
                    .font(CardTypography.font(for: style, role: .number))
                    .foregroundStyle(.white)

                Text(targetDate, style: .date)
                    .font(CardTypography.font(for: style, role: .date))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
            .padding()
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { now = $0 }
    }

    private var backgroundFill: some ShapeStyle {
        if backgroundStyle == "color", let hex = bgColorHex, let c = Color(hex: hex) {
            return AnyShapeStyle(LinearGradient(colors: [c, c.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        return AnyShapeStyle(.black.opacity(0.25))
    }
}
