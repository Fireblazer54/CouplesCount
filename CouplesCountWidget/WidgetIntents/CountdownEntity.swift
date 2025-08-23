import AppIntents
import Foundation
import SwiftUI

// MARK: - AppEntity used by the widget’s picker
struct CountdownEntity: AppEntity, Identifiable, Hashable {
    // iOS 18+ API: TypeDisplayRepresentable
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Countdown"
    static var defaultQuery = CountdownQuery()

    // Identity + fields we need in the widget
    var id: UUID
    var title: String
    var targetDate: Date
    var timeZoneID: String
    var cardFontStyle: CardFontStyle

    // How each item shows up in the picker
    var displayRepresentation: DisplayRepresentation {
        .init(title: "\(title)")
    }

    // Fallback preview (used when no App Group yet on free account)
    static var preview: CountdownEntity = .init(
        id: UUID(),
        title: "Anniversary",
        targetDate: Calendar.current.date(byAdding: .day, value: 30, to: .now)!,
        timeZoneID: TimeZone.current.identifier,
        cardFontStyle: .classic
    )
}

// MARK: - Query that supplies entities to the picker
struct CountdownQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [CountdownEntity] {
        let all = try await suggestedEntities()
        let set = Set(identifiers)
        return all.filter { set.contains($0.id) }
    }

    func suggestedEntities() async throws -> [CountdownEntity] {
        let dtos = WidgetSnapshotStore.read()
        if dtos.isEmpty {
#if DEBUG
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1",
               let url = Bundle.main.url(forResource: "preview-countdowns", withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let previews = try? JSONDecoder().decode([CountdownDTO].self, from: data) {
                return previews.map {
                    CountdownEntity(
                        id: $0.id,
                        title: $0.title,
                        targetDate: $0.targetUTC,
                        timeZoneID: $0.timeZoneID,
                        cardFontStyle: .classic
                    )
                }
            }
#endif
            return [CountdownEntity.preview]
        }
        return dtos.map {
            CountdownEntity(
                id: $0.id,
                title: $0.title,
                targetDate: $0.targetUTC,
                timeZoneID: $0.timeZoneID,
                cardFontStyle: .classic
            )
        }
    }
}
