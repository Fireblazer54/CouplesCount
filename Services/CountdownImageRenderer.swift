import SwiftUI
import UIKit

enum CountdownImageRenderer {
    /// Renders a countdown card into a high-resolution image suitable for sharing.
    /// - Parameters:
    ///   - countdown: Countdown model to render.
    ///   - theme: Theme manager supplying colors.
    ///   - includeWatermark: Whether to include a watermark overlay. Default is `false`.
    /// - Returns: A rendered UIImage or `nil` if rendering failed.
    static func render(countdown: Countdown, theme: ThemeManager, includeWatermark: Bool = false) -> UIImage? {
        let exportSize = CGSize(width: 1080, height: 1350)
        let padding: CGFloat = 80
        let cardSize = exportSize.width - (padding * 2)

        let card = CountdownCardView(
            title: countdown.title,
            targetDate: countdown.targetDate,
            timeZoneID: countdown.timeZoneID,
            dateText: DateUtils.readableDate.string(from: countdown.targetDate),
            archived: countdown.isArchived,
            backgroundStyle: countdown.backgroundStyle,
            colorHex: countdown.backgroundColorHex,
            imageData: countdown.backgroundImageData,
            fontStyle: countdown.cardFontStyle,
            shared: countdown.isShared,
            height: cardSize
        )
        .environmentObject(theme)
        .frame(width: cardSize, height: cardSize)

        let content = ZStack {
            theme.theme.background
            card
                .padding(.all, padding)
            if includeWatermark {
                Text("CouplesCount")
                    .font(.caption2)
                    .padding(6)
                    .background(Color.black.opacity(0.6))
                    .foregroundStyle(.white)
                    .cornerRadius(4)
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        }
        .frame(width: exportSize.width, height: exportSize.height)
        .environmentObject(theme)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 1
        return renderer.uiImage
    }
}

