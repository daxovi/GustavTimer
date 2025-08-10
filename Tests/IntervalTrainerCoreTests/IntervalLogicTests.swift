import XCTest
@testable import IntervalTrainerCore

final class IntervalLogicTests: XCTestCase {
    func testNoLoopFirstInterval() {
        let durations: [Duration] = [30, 20].map { .seconds($0) }
        let elapsed = Duration.seconds(25)
        let state = IntervalLogic.state(for: durations, loopEnabled: false, elapsed: elapsed)
        XCTAssertEqual(state.index, 0)
        XCTAssertEqual(state.remaining, .seconds(5))
        XCTAssertEqual(state.cycle, 1)
    }

    func testLoopSecondCycle() {
        let durations: [Duration] = [30, 20].map { .seconds($0) }
        let elapsed = Duration.seconds(70)
        let state = IntervalLogic.state(for: durations, loopEnabled: true, elapsed: elapsed)
        XCTAssertEqual(state.index, 0)
        XCTAssertEqual(state.remaining, .seconds(10))
        XCTAssertEqual(state.cycle, 2)
    }
}
