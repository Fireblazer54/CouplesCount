import SwiftUI

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
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                .overlay(
                    // tiny inner highlight
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 10, y: 6)

            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(CardTypography.font(for: fontStyle, role: .title))
                    .lineLimit(1)

                Text(DateUtils.remainingText(to: targetDate, from: now, in: timeZoneID))
                    .font(CardTypography.font(for: fontStyle, role: .number))

                Text(dateText)
                    .font(CardTypography.font(for: fontStyle, role: .date))
                    .opacity(0.95)
            }
            .padding(18)
            .foregroundStyle(.white)
        }
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 4) {
                if shared {
                    Image(systemName: "person.2.fill")
                }
                if let shareAction {
                    Button(action: shareAction) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(8)
                            .background(
                                Circle().fill(Color.white.opacity(0.25))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
        .saturation(archived ? 0 : 1)
        .opacity(archived ? 0.55 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: archived)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(DateUtils.remainingText(to: targetDate, from: now, in: timeZoneID)), \(dateText)")
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { now = $0 }
    }

    private var accent: Color { theme.theme.accent }

    private var backgroundFill: some ShapeStyle {
        if backgroundStyle == "color",
           let hex = colorHex,
           let c = Color(hex: hex) {
            return AnyShapeStyle(
                LinearGradient(colors: [c, c.opacity(0.75)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
        }
        return AnyShapeStyle(
            LinearGradient(colors: [accent, accent.opacity(0.75)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
        )
    }
}
