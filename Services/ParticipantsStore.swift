import Foundation
import SwiftUI

struct Participant: Identifiable {
    let id: UUID
    let name: String
    let image: Image
}

protocol ParticipantsStoreProtocol {
    func participants(for countdown: Countdown) -> [Participant]
}

struct ParticipantsStore: ParticipantsStoreProtocol {
    func participants(for countdown: Countdown) -> [Participant] {
        // Placeholder participants
        return [
            Participant(id: UUID(), name: "Alex", image: Image(systemName: "person.circle")),
            Participant(id: UUID(), name: "Sam", image: Image(systemName: "person.circle"))
        ]
    }
}
