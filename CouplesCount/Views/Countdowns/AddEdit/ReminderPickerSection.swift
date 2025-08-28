import SwiftUI

enum ReminderOption: Int, CaseIterable, Identifiable {
    case h1 = -60
    case h2 = -120
    case h3 = -180
    case h6 = -360
    case h12 = -720
    case d1 = -1440
    case d2 = -2880
    case d3 = -4320
    case d7 = -10080

    var id: Int { rawValue }
    var label: String {
        switch self {
        case .h1: return "1h"
        case .h2: return "2h"
        case .h3: return "3h"
        case .h6: return "6h"
        case .h12: return "12h"
        case .d1: return "1d"
        case .d2: return "2d"
        case .d3: return "3d"
        case .d7: return "7d"
        }
    }
}

struct ReminderPickerSection: View {
    var body: some View {
        SettingsCard {
            VStack(spacing: 8) {
                Image(systemName: "bell")
                    .font(.system(size: 40))
                    .foregroundStyle(Color("Secondary"))
                Text("Reminders coming soon")
                    .foregroundStyle(Color("Secondary"))
            }
            .frame(maxWidth: .infinity, minHeight: 120)
        }
    }
}

