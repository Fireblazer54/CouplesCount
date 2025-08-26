import SwiftUI

struct ShareSection: View {
    @EnvironmentObject private var theme: ThemeManager
    @Binding var isShared: Bool
    @Binding var selectedFriends: Set<UUID>
    var friends: [Friend]

    var body: some View {
        SettingsCard {
            Toggle("Shared countdown", isOn: $isShared)
                .foregroundStyle(theme.theme.textPrimary)
            if isShared {
                ForEach(friends) { friend in
                    let isSelected = Binding<Bool>(
                        get: { selectedFriends.contains(friend.id) },
                        set: { newVal in
                            if newVal { selectedFriends.insert(friend.id) } else { selectedFriends.remove(friend.id) }
                        }
                    )
                    Toggle(friend.name, isOn: isSelected)
                        .foregroundStyle(theme.theme.textPrimary)
                }
            }
        }
    }
}

