import SwiftUI

struct CountdownDetailView: View {
    @EnvironmentObject private var theme: ThemeManager
    let countdown: Countdown

    var body: some View {
        ScrollView {
            CountdownCardView(
                title: countdown.title,
                targetDate: countdown.targetDate,
                timeZoneID: countdown.timeZoneID,
                dateText: DateUtils.readableDate.string(from: countdown.targetDate),
                archived: countdown.isArchived,
                backgroundStyle: countdown.backgroundStyle,
                colorHex: countdown.backgroundColorHex,
                imageData: countdown.backgroundImageData,
                titleFontName: countdown.titleFontName,
                shared: countdown.isShared,
                shareAction: nil
            )
            .environmentObject(theme)
            .padding()
        }
        .background(theme.theme.background.ignoresSafeArea())
        .navigationTitle(countdown.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let countdown = Countdown(title: "Preview", targetDate: .now.addingTimeInterval(3600), timeZoneID: TimeZone.current.identifier)
    return NavigationStack {
        CountdownDetailView(countdown: countdown)
            .environmentObject(ThemeManager())
    }
}
