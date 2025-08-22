import SwiftUI

struct CountdownCardView: View {
    @EnvironmentObject private var theme: ThemeManager

    let title: String
    let daysLeft: Int
    let dateText: String
    let archived: Bool
    let backgroundStyle: String
    let colorHex: String?
    let imageData: Data?
    let shared: Bool
    let shareAction: (() -> Void)?


    private let corner: CGFloat = 22
    private let height: CGFloat = 120

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
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 4) {
                if shared {
                    Image(systemName: "person.2.fill")
                }
                if let shareAction {
                    Button(action: shareAction) {

                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .padding(8)
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
