import SwiftUI

struct CountdownDetailView: View {
    let countdown: Countdown
    @Environment(\.dismiss) private var dismiss
    @State private var shareURL: URL? = nil
    @State private var showShareSheet = false

    private var dateString: String {
        var df = DateUtils.readableDate
        df.timeZone = TimeZone(identifier: countdown.timeZoneID)
        return df.string(from: countdown.targetDate)
    }

    private var timeString: String {
        let tf = DateFormatter()
        tf.dateStyle = .none
        tf.timeStyle = .short
        tf.timeZone = TimeZone(identifier: countdown.timeZoneID)
        return tf.string(from: countdown.targetDate)
    }

    private var daysRemaining: Int {
        max(DateUtils.daysUntil(target: countdown.targetDate, in: countdown.timeZoneID), 0)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Theme.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Text(countdown.title)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .padding(.top, 80)
                        .padding(.horizontal)

                    HStack(spacing: 16) {
                        InfoCard(system: "calendar", text: dateString)
                        InfoCard(system: "clock", text: timeString)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 12) {
                        Text("\(daysRemaining)")
                            .font(.system(size: 96, weight: .bold))
                            .foregroundStyle(.black)
                            .minimumScaleFactor(0.5)

                        Text("DAYS")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                                    .overlay(
                                        Capsule().stroke(Color("Border"), lineWidth: 1)
                                    )
                            )
                    }

                    ReactionRow()
                        .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }

            header
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareURL {
                ShareSheet(activityItems: [shareURL])
            }
        }
    }

    private var header: some View {
        ZStack {
            HStack {
                CircleButton(system: "chevron.left") { dismiss() }
                Spacer()
                CircleButton(system: "square.and.arrow.up") {
                    if let url = CountdownShareService.exportURL(for: countdown) {
                        shareURL = url
                        showShareSheet = true
                    }
                }
            }
            Text("Swipe down to close")
                .font(.footnote)
                .foregroundStyle(Color("Secondary"))
        }
        .padding()
    }
}

private struct InfoCard: View {
    let system: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: system)
                .foregroundStyle(Color("Foreground"))
            Text(text)
                .font(.body)
                .foregroundStyle(Color("Foreground"))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color("Border"), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        )
    }
}

private struct ReactionRow: View {
    struct Reaction: Identifiable {
        let id = UUID()
        let icon: String
        let label: String
        let color: Color
    }

    let reactions: [Reaction] = [
        .init(icon: "❤️", label: "Love", color: .pink.opacity(0.2)),
        .init(icon: "👆", label: "Poke", color: .orange.opacity(0.2)),
        .init(icon: "📝", label: "Note", color: .yellow.opacity(0.2))
    ]

    var body: some View {
        HStack(spacing: 16) {
            ForEach(reactions) { reaction in
                Button {
                    Haptics.light()
                } label: {
                    VStack(spacing: 4) {
                        Text(reaction.icon)
                        Text(reaction.label)
                            .font(.footnote)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(reaction.color)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color("Border"), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    )
                }
                .buttonStyle(.plain)
                .frame(minWidth: 44, minHeight: 44)
            }
        }
    }
}

private struct CircleButton: View {
    let system: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 20, weight: .semibold))
                .frame(width: 44, height: 44)
                .background(
                    Circle().fill(.ultraThinMaterial)
                )
                .foregroundStyle(Color("Foreground"))
        }
        .buttonStyle(.plain)
        .frame(minWidth: 44, minHeight: 44)
    }
}

#Preview {
    CountdownDetailView(countdown: .init(title: "Trip to Paris", targetDate: .now.addingTimeInterval(60*60*24*23), timeZoneID: TimeZone.current.identifier))
}

