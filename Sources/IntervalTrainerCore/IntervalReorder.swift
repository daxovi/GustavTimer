import Foundation

public struct Interval: Equatable, Identifiable {
    public var id: UUID
    public var title: String
    public var duration: Duration
    public var order: Int
    public init(id: UUID = UUID(), title: String, duration: Duration, order: Int) {
        self.id = id
        self.title = title
        self.duration = duration
        self.order = order
    }
}

public enum IntervalReorder {
    public static func reorder(_ intervals: [Interval], fromOffsets: IndexSet, toOffset: Int) -> [Interval] {
        var result = intervals
        let moving = fromOffsets.sorted().map { result[$0] }
        for index in fromOffsets.sorted(by: >) {
            result.remove(at: index)
        }
        var insertIndex = toOffset
        for element in moving {
            result.insert(element, at: insertIndex)
            insertIndex += 1
        }
        for i in result.indices {
            result[i].order = i
        }
        return result
    }
}
