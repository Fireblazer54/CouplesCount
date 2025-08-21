import Foundation
import SwiftData

@Model
final class Friend {
    var id: UUID
    var name: String
    var identifier: String

    init(id: UUID = UUID(), name: String, identifier: String) {
        self.id = id
        self.name = name
        self.identifier = identifier
    }
}
