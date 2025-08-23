import Foundation
import SwiftData

enum Persistence {
    static var container: ModelContainer = {
        let url = AppGroup.containerURL.appendingPathComponent("CouplesCount.store")

        let config = ModelConfiguration(url: url)
        let schema = Schema([Countdown.self, Friend.self])
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // If the persistent store is incompatible or corrupt, remove it and retry
            do {
                if FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.removeItem(at: url)
                }
                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                fatalError("ModelContainer error: \(error)")
            }
        }
    }()
}
