import Foundation
import SwiftData

@Model
final class TimerTemplate {
    var id: UUID
    var name: String
    var intervals: [IntervalItem]
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), name: String, intervals: [IntervalItem], isFavorite: Bool = false, createdAt: Date = .now, updatedAt: Date = .now) {
        self.id = id
        self.name = name
        self.intervals = intervals
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
