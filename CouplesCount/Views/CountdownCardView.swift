import SwiftUI
import UIKit

struct CountdownCardView: View {

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
        height: CGFloat = 140
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


    private let corner: CGFloat = 16
    @EnvironmentObject private var nowProvider: NowProvider

    private var cardColor: Color {
        resolvedCardColor(backgroundStyle: backgroundStyle, colorHex: colorHex)
    }

    private var primaryText: Color { cardColor.readablePrimary }

    private var secondaryText: Color { cardColor.readableSecondary }

    private var shareButtonBg: Color {
        primaryText.opacity(cardColor.isLight ? 0.05 : 0.25)
    }

    private var remaining: (value: String, unit: String) {
        let text = DateUtils.remainingText(to: targetDate, from: nowProvider.now, in: timeZoneID)
        let parts = text.split(separator: " ")
        let value = parts.first.map(String.init) ?? ""
        let unit = parts.dropFirst().first.map { $0.uppercased() } ?? ""
        return (value, unit)
    }

    private static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df
    }()

    private var timeText: String {
        let formatter = Self.timeFormatter
        formatter.timeZone = TimeZone(identifier: timeZoneID)
        return formatter.string(from: targetDate)
    }

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
                        .stroke(Color(hex: "#E0E0E0") ?? Color(red: 224/255, green: 224/255, blue: 224/255), lineWidth: 1)
                )
                .shadow(color: Color(hex: "#0000000D") ?? Color.black.opacity(0.05), radius: 4, y: 2)

            // Content
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            Text(dateText)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().stroke(Color("Border"))
                        )

                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text(timeText)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().stroke(Color("Border"))
                        )
                    }
                    .font(CardTypography.font(for: fontStyle, role: .date))
                    .foregroundStyle(secondaryText)

                    Text(title)
                        .font(CardTypography.font(for: fontStyle, role: .title))
                        .lineLimit(1)
                        .foregroundStyle(primaryText)

                    Text("\(remaining.unit) REMAINING")
                        .font(.caption2)
                        .foregroundStyle(secondaryText)
                }

                Spacer()

                VStack(alignment: .center, spacing: 4) {
                    Text(remaining.value)
                        .font(CardTypography.font(for: fontStyle, role: .number))
                        .monospacedDigit()
                        .foregroundStyle(primaryText)

                    Text(remaining.unit)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .font(.caption.bold())
                        .tracking(1)
                        .background(
                            Capsule().stroke(primaryText)
                        )
                        .foregroundStyle(primaryText)
                }
            }
            .padding(20)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(accentGradient)
                .frame(height: 1)
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
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
        .accessibilityLabel("\(title), \(DateUtils.remainingText(to: targetDate, from: nowProvider.now, in: timeZoneID)), \(dateText)")
    }

    private var accentGradient: LinearGradient {
        if backgroundStyle == "color",
           let hex = colorHex,
           hex.contains(",") {
            let parts = hex.split(separator: ",")
            if let c1 = Color(hex: String(parts[0])),
               let c2 = Color(hex: String(parts.count > 1 ? parts[1] : parts[0])) {
                return LinearGradient(colors: [c1, c2], startPoint: .leading, endPoint: .trailing)
            }
        }
        let c = cardColor
        return LinearGradient(colors: [c, c], startPoint: .leading, endPoint: .trailing)
    }

    private var backgroundFill: some ShapeStyle {
        if backgroundStyle == "color" {
            if let hex = colorHex, hex.contains(",") {
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
