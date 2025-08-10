import XCTest
@testable import IntervalTrainerCore

final class ReorderTests: XCTestCase {
    func testReorderUpdatesOrder() {
        let durations: [Duration] = [.seconds(10), .seconds(20), .seconds(30)]
        let intervals = zip(0..<durations.count, durations).map { idx, dur in
            Interval(title: "I\(idx)", duration: dur, order: idx)
        }
        let moved = IntervalReorder.reorder(intervals, fromOffsets: IndexSet(integer: 0), toOffset: 1)
        XCTAssertEqual(moved.map{ $0.order }, [0,1,2])
        XCTAssertEqual(moved[0].title, "I1")
        XCTAssertEqual(moved[1].title, "I0")
    }
}
