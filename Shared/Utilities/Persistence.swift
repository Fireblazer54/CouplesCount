import Foundation
import SwiftData

enum Persistence {
    // When you join the paid program, set this to your App Group id and use groupURL() below
    private static let appGroupID: String? = nil

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
        do {
            let schema = Schema([Countdown.self])
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("ModelContainer error: \(error)")
        }
    }()
}
