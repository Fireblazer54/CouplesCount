import AppIntents
import Foundation
import SwiftUI

// MARK: - Storage bridge reading snapshot JSON from the shared App Group
enum WidgetStoreBridge {
    static let appGroupID: String = "group.com.fireblazer.CouplesCount"
    private static let fileName = "countdowns.json"

    private struct CountdownDTO: Decodable {
        var id: UUID
        var title: String
        var targetDate: Date
        var timeZoneID: String
        var titleFontName: String
    }

    static func fetchCountdowns() -> [CountdownEntity] {
        guard let base = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            return []
        }
        let url = base.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: url),
              let dtos = try? JSONDecoder().decode([CountdownDTO].self, from: data) else {
            return []
        }
        return dtos.map {
            CountdownEntity(id: $0.id,
                            title: $0.title,
                            targetDate: $0.targetDate,
                            timeZoneID: $0.timeZoneID,
                            titleFontName: $0.titleFontName)
        }
    }
}

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
    var titleFontName: String

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
        titleFontName: TitleFont.default.rawValue
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
        // Read countdowns from the shared App Group; fall back to preview when missing.
        let items = WidgetStoreBridge.fetchCountdowns()
        guard !items.isEmpty else {
            return [CountdownEntity.preview]
        }
        return items
    }
}
