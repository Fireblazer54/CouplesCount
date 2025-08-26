import SwiftUI

struct CountdownDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let countdown: Countdown

    var body: some View {
        CountdownDetailContent(countdown: countdown, namespace: nil) {
            dismiss()
        }
    }
}

#Preview {
    let countdown = Countdown(title: "Preview", targetDate: .now.addingTimeInterval(3600), timeZoneID: TimeZone.current.identifier)
    return CountdownDetailView(countdown: countdown)
        .environmentObject(ThemeManager())
}

