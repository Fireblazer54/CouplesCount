import AppIntents
import Foundation
import SwiftData

// MARK: - Storage bridge (works now without App Group; reads real data later)
enum WidgetStoreBridge {
    // After you enroll in the Apple Developer Program, set this to your App Group id.
    // Example: "group.com.fireblazer.CouplesCount"
    static let appGroupID: String? = nil

    static func modelContainerIfAvailable() -> ModelContainer? {
        // Widgets can only read the app’s data via an App Group.
        guard let group = appGroupID,
              let base = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)
        else { return nil }

        let url = base.appendingPathComponent("CouplesCount.store")
        let config = ModelConfiguration(url: url)

        do {
            let schema = Schema([Countdown.self])
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            return nil
        }
    }

    static func fetchCountdowns() -> [Countdown] {
        guard let container = modelContainerIfAvailable() else { return [] }
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Countdown>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [.init(\.targetDate, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
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

    // How each item shows up in the picker
    var displayRepresentation: DisplayRepresentation {
        .init(title: "\(title)")
    }

    // Fallback preview (used when no App Group yet on free account)
    static var preview: CountdownEntity = .init(
        id: UUID(),
        title: "Anniversary",
        targetDate: Calendar.current.date(byAdding: .day, value: 30, to: .now)!,
        timeZoneID: TimeZone.current.identifier
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
        // If you’re on a free account (no App Group), this returns [] and we fall back to preview.
        let items = WidgetStoreBridge.fetchCountdowns()
        guard !items.isEmpty else {
            return [CountdownEntity.preview]
        }
        return items.map {
            CountdownEntity(id: $0.id,
                            title: $0.title,
                            targetDate: $0.targetDate,
                            timeZoneID: $0.timeZoneID)
        }
    }
}
