import SwiftUI
import SwiftData

struct ProfileView: View {
    @EnvironmentObject private var theme: ThemeManager
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Countdown> { $0.isShared && !$0.isArchived },
           sort: \Countdown.targetDate, order: .forward)
    private var shared: [Countdown]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Header similar to Instagram
                HStack {
                    Circle()
                        .fill(theme.theme.accent)
                        .frame(width: 80, height: 80)
                    Spacer()
                    VStack {
                        Text("\(shared.count)")
                            .font(.headline)
                        Text("Posts")
                            .font(.subheadline)
                    }
                    Spacer()
                    VStack {
                        Text("0")
                            .font(.headline)
                        Text("Followers")
                            .font(.subheadline)
                    }
                    Spacer()
                    VStack {
                        Text("0")
                            .font(.headline)
                        Text("Following")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)

                Text("Username")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .padding(.top, 4)

                Button("Add Friend") {
                    // Placeholder for friend adding flow
                }
                .padding(.horizontal)
                .padding(.bottom, 4)

                // Grid of shared countdowns
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                    ForEach(shared) { item in
                        let days = DateUtils.daysUntil(target: item.targetDate, in: item.timeZoneID)
                        let dateText = DateUtils.readableDate.string(from: item.targetDate)
                        CountdownCardView(
                            title: item.title,
                            daysLeft: days,
                            dateText: dateText,
                            archived: item.isArchived,
                            backgroundStyle: item.backgroundStyle,
                            colorHex: item.backgroundColorHex,
                            imageData: item.backgroundImageData,
                            shared: item.isShared
                        )
                        .environmentObject(theme)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .background(theme.theme.background.ignoresSafeArea())
    }
}
