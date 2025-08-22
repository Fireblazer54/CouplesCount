import Foundation
import SwiftData

enum Persistence {
    // App Group identifier used for shared storage
    private static let appGroupID: String? = "group.com.fireblazer.CouplesCount"

    static var container: ModelContainer = {
        let url: URL
        if let group = appGroupID,
           let base = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) {
            url = base.appendingPathComponent("CouplesCount.store")
        } else {
            // Local documents directory (works on free provisioning)
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            url = docs.appendingPathComponent("CouplesCount.store")
        }

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
