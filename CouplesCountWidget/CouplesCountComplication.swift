import WidgetKit
import SwiftUI
import AppIntents

/// Timeline entry for the watch complication widget.
struct CouplesCountComplicationEntry: TimelineEntry {
    let date: Date
    let entity: CountdownEntity
}

/// Provider for the watch complication that refreshes once per day.
struct CouplesCountComplicationProvider: AppIntentTimelineProvider {
    typealias Entry = CouplesCountComplicationEntry
    typealias Intent = SelectCountdown

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

/// View shown in the watch complication families.
struct CouplesCountComplicationView: View {
    var entry: CouplesCountComplicationEntry

    private var cardColor: Color {
        resolvedCardColor(backgroundStyle: "color", colorHex: nil)
    }

    private var primaryText: Color { cardColor.readablePrimary }
    private var secondaryText: Color { cardColor.readableSecondary }

    var body: some View {
        VStack(spacing: 4) {
            Text(entry.entity.title)
                .font(CardTypography.font(for: entry.entity.cardFontStyle, role: .title))
                .foregroundStyle(primaryText)
                .lineLimit(1)

            Text(DateUtils.remainingText(to: entry.entity.targetDate, from: entry.date, in: entry.entity.timeZoneID))
                .font(CardTypography.font(for: entry.entity.cardFontStyle, role: .number))
                .foregroundStyle(primaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(
            AnyShapeStyle(cardColor),
            for: .widget
        )
    }
}

/// Watch complication widget configuration.
struct CouplesCountComplication: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "CouplesCountComplication",
            intent: SelectCountdown.self,
            provider: CouplesCountComplicationProvider()
        ) { entry in
            CouplesCountComplicationView(entry: entry)
        }
        .configurationDisplayName("Countdown")
        .description("Shows a selected countdown.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}

#Preview(as: .accessoryCircular) {
    CouplesCountComplication()
} timeline: {
    CouplesCountComplicationEntry(date: .now, entity: .preview)
}

