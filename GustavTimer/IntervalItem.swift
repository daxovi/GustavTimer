import Foundation
import SwiftData

@Model
struct IntervalItem {
    var id: UUID
    var title: String
    var duration: Duration
    var order: Int

    init(id: UUID = UUID(), title: String, duration: Duration, order: Int) {
        self.id = id
        self.title = title
        self.duration = duration
        self.order = order
    }
}
