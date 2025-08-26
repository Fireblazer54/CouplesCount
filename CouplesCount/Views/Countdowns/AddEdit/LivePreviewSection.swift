import SwiftUI

struct LivePreviewSection: View {
    let previewTitle: String
    let previewDate: Date
    let timeZoneID: String
    let cardFontStyle: CardFontStyle
    let backgroundStyle: String
    let colorHex: String
    let imageData: Data?

    var body: some View {
        TabView {
            WidgetPreview(
                title: previewTitle,
                targetDate: previewDate,
                tzID: timeZoneID,
                style: cardFontStyle,
                backgroundStyle: backgroundStyle,
                bgColorHex: colorHex,
                imageData: imageData
            )
            .frame(width: 160, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .padding(.vertical, 8)

            WidgetPreview(
                title: previewTitle,
                targetDate: previewDate,
                tzID: timeZoneID,
                style: cardFontStyle,
                backgroundStyle: backgroundStyle,
                bgColorHex: colorHex,
                imageData: imageData
            )
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .padding(.vertical, 8)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .automatic))
        .frame(height: 180)
        .padding(.horizontal, 16)
    }
}

