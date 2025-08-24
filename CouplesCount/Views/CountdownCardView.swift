import SwiftUI
import UIKit

struct CountdownCardView: View {
    @EnvironmentObject private var theme: ThemeManager

    let title: String
    let targetDate: Date
    let timeZoneID: String
    let dateText: String
    let archived: Bool
    let backgroundStyle: String
    let colorHex: String?
    let imageData: Data?
    let fontStyle: CardFontStyle

    let shared: Bool
    let shareAction: (() -> Void)?
    let height: CGFloat

    init(
        title: String,
        targetDate: Date,
        timeZoneID: String,
        dateText: String,
        archived: Bool,
        backgroundStyle: String,
        colorHex: String?,
        imageData: Data?,
        fontStyle: CardFontStyle = .classic,
        shared: Bool,
        shareAction: (() -> Void)? = nil,
        height: CGFloat = 120
    ) {
        self.title = title
        self.targetDate = targetDate
        self.timeZoneID = timeZoneID
        self.dateText = dateText
        self.archived = archived
        self.backgroundStyle = backgroundStyle
        self.colorHex = colorHex
        self.imageData = imageData
        self.fontStyle = fontStyle
        self.shared = shared
        self.shareAction = shareAction
        self.height = height
    }


    private let corner: CGFloat = 22
    @State private var now = Date()

    private var isDefaultBackground: Bool {
        if backgroundStyle == "image" { return false }
        let hex = colorHex?.uppercased() ?? ""
        return hex == "" || hex == "#FFFFFF"
    }

    private var primaryText: Color { isDefaultBackground ? .black : .white }
    private var secondaryText: Color { isDefaultBackground ? .black.opacity(0.7) : .white.opacity(0.95) }
    private var shareButtonBg: Color { isDefaultBackground ? .black.opacity(0.05) : .white.opacity(0.25) }

    var body: some View {
        ZStack(alignment: .leading) {
            // Background color or image
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(backgroundFill)
                .overlay(
                    Group {
                        if let data = imageData,
                           backgroundStyle == "image",
                           let ui = UIImage(data: data) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .accessibilityHidden(true)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .stroke(Color.black.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 10, y: 6)

            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(CardTypography.font(for: fontStyle, role: .title))
                    .lineLimit(1)
                    .foregroundStyle(primaryText)

                Text(DateUtils.remainingText(to: targetDate, from: now, in: timeZoneID))
                    .font(CardTypography.font(for: fontStyle, role: .number))
                    .foregroundStyle(primaryText)

                Text(dateText)
                    .font(CardTypography.font(for: fontStyle, role: .date))
                    .foregroundStyle(secondaryText)
            }
            .padding(18)
        }
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 4) {
                if shared {
                    Image(systemName: "person.2.fill")
                        .accessibilityHidden(true)
                }
                if let shareAction {
                    Button(action: shareAction) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: UIFontMetrics(forTextStyle: .body).scaledValue(for: 18), weight: .semibold))

                            .frame(width: 44, height: 44)
                            .background(
                                Circle().fill(shareButtonBg)
                            )
                            .contentShape(Rectangle())
                            .accessibilityLabel("Share")
                            .accessibilityHint("Share this countdown")
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .foregroundStyle(primaryText)
        }
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
        .saturation(archived ? 0 : 1)
        .opacity(archived ? 0.55 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: archived)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(DateUtils.remainingText(to: targetDate, from: now, in: timeZoneID)), \(dateText)")
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { now = $0 }
    }

    private var backgroundFill: some ShapeStyle {
        if backgroundStyle == "color",
           let hex = colorHex?.uppercased(),
           hex != "#FFFFFF",
           let c = Color(hex: hex) {
            return AnyShapeStyle(
                LinearGradient(colors: [c, c.opacity(0.75)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
        }
        return AnyShapeStyle(Color.white)
    }
}
