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
                .font(CardTypography.font(for: entry.entity.cardFontStyle, role: .title))
                .lineLimit(1)
                .foregroundStyle(ColorTheme.default.textPrimary)

            Text(DateUtils.remainingText(to: entry.entity.targetDate, from: entry.date, in: entry.entity.timeZoneID))
                .font(CardTypography.font(for: entry.entity.cardFontStyle, role: .number))
                .foregroundStyle(ColorTheme.default.primary)

            Text(entry.entity.targetDate, style: .date)
                .font(CardTypography.font(for: entry.entity.cardFontStyle, role: .date))
                .foregroundStyle(ColorTheme.default.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(ColorTheme.default.backgroundGradient, for: .widget)
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
