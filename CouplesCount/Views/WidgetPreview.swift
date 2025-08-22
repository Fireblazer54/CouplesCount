import SwiftUI

struct WidgetPreview: View {
    let title: String
    let targetDate: Date
    let tzID: String
    let titleFontName: String
    let backgroundStyle: String
    let bgColorHex: String?
    let imageData: Data?

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
                        }
                    }
                )
                .frame(height: 140)

            VStack(spacing: 6) {
                Text(title)
                    .font(.system(.headline, design: TitleFont(rawValue: titleFontName)?.design ?? .default))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text("\(DateUtils.daysUntil(target: targetDate, in: tzID)) days")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(targetDate, style: .date)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
            .padding()
        }
    }

    private var backgroundFill: some ShapeStyle {
        if backgroundStyle == "color", let hex = bgColorHex, let c = Color(hex: hex) {
            return AnyShapeStyle(LinearGradient(colors: [c, c.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        return AnyShapeStyle(.black.opacity(0.25))
    }
}
