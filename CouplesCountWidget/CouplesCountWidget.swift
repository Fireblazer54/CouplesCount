import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Intent used by the widget configuration
struct SelectCountdown: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Choose Countdown"
    static var description = IntentDescription("Pick which countdown to show.")

    @Parameter(title: "Countdown")
    var countdown: CountdownEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("Show \(\.$countdown)")
    }
}

// MARK: - Timeline payload
struct CouplesCountEntry: TimelineEntry {
    let date: Date
    let entity: CountdownEntity
}

// MARK: - Provider
struct CouplesCountProvider: AppIntentTimelineProvider {
    typealias Intent = SelectCountdown
    typealias Entry = CouplesCountEntry

    func placeholder(in context: Context) -> Entry {
        .init(date: .now, entity: .preview)
    }

    func snapshot(for configuration: SelectCountdown, in context: Context) async -> Entry {
        let chosen = configuration.countdown ?? .preview
        return .init(date: .now, entity: chosen)
    }

    func timeline(for configuration: SelectCountdown, in context: Context) async -> Timeline<Entry> {
        let chosen = configuration.countdown ?? .preview
        let midnight = Calendar.current.nextDate(
            after: .now,
            matching: DateComponents(hour: 0, minute: 1),
            matchingPolicy: .nextTime
        ) ?? .now.addingTimeInterval(86_400)
        return Timeline(entries: [.init(date: .now, entity: chosen)], policy: .after(midnight))
    }
}

// MARK: - View
struct CouplesCountWidgetView: View {
    var entry: CouplesCountEntry

    var body: some View {
        VStack(spacing: 6) {
            Text(entry.entity.title)
                .font(.headline)
                .lineLimit(1)

            Text(daysText(to: entry.entity.targetDate, tzID: entry.entity.timeZoneID))
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text(entry.entity.targetDate, style: .date)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private func daysText(to date: Date, tzID: String) -> String {
        let tz = TimeZone(identifier: tzID) ?? .current
        var cal = Calendar.current; cal.timeZone = tz
        let start = cal.startOfDay(for: .now)
        let end = cal.startOfDay(for: date)
        let d = cal.dateComponents([.day], from: start, to: end).day ?? 0
        return "\(d) days"
    }
}

// MARK: - Widget
struct CouplesCountWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "CouplesCountWidget",
            intent: SelectCountdown.self,
            provider: CouplesCountProvider()
        ) { entry in
            CouplesCountWidgetView(entry: entry)
        }
        .configurationDisplayName("CouplesCount")
        .description("Pin a specific countdown.")
        .supportedFamilies([.systemSmall])
    }
}
