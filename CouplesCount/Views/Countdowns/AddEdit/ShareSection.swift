import SwiftUI

struct ShareSection: View {
    @Binding var isShared: Bool
    @Binding var selectedFriends: Set<UUID>
    var friends: [Friend]

    var body: some View {
        SettingsCard {
            Toggle("Shared countdown", isOn: $isShared)
                .foregroundStyle(Color("Foreground"))
            if isShared {
                ForEach(friends) { friend in
                    let isSelected = Binding<Bool>(
                        get: { selectedFriends.contains(friend.id) },
                        set: { newVal in
                            if newVal { selectedFriends.insert(friend.id) } else { selectedFriends.remove(friend.id) }
                        }
                    )
                    Toggle(friend.name, isOn: isSelected)
                        .foregroundStyle(Color("Foreground"))
                }
            }
        }
    }
}

