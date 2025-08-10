//
//  TimerCalculationTests.swift
//  GustavTimerTests
//
//  Created by AI Assistant on 10.08.2024.
//

import XCTest
@testable import GustavTimer

final class TimerCalculationTests: XCTestCase {
    
    func testSingleCycleNoLoop_PartialFirstInterval() {
        // Setup: [30s, 20s], loop off, 25s elapsed
        let intervals = [
            IntervalItem(title: "First", duration: Duration.seconds(30), order: 0),
            IntervalItem(title: "Second", duration: Duration.seconds(20), order: 1)
        ]
        
        let result = calculateTimerState(
            intervals: intervals,
            startingIndex: 0,
            startingCycle: 1,
            remainingInInterval: Duration.seconds(30),
            elapsedTime: Duration.seconds(25),
            loopEnabled: false
        )
        
        XCTAssertEqual(result.index, 0, "Should still be in first interval")
        XCTAssertEqual(result.remaining, Duration.seconds(5), "Should have 5 seconds remaining", accuracy: 0.1)
        XCTAssertEqual(result.cycle, 1, "Should be in cycle 1")
    }
    
    func testSingleCycleNoLoop_SecondInterval() {
        // Setup: [30s, 20s], loop off, 40s elapsed
        let intervals = [
            IntervalItem(title: "First", duration: Duration.seconds(30), order: 0),
            IntervalItem(title: "Second", duration: Duration.seconds(20), order: 1)
        ]
        
        let result = calculateTimerState(
            intervals: intervals,
            startingIndex: 0,
            startingCycle: 1,
            remainingInInterval: Duration.seconds(30),
            elapsedTime: Duration.seconds(40),
            loopEnabled: false
        )
        
        XCTAssertEqual(result.index, 1, "Should be in second interval")
        XCTAssertEqual(result.remaining, Duration.seconds(10), "Should have 10 seconds remaining", accuracy: 0.1)
        XCTAssertEqual(result.cycle, 1, "Should be in cycle 1")
    }
    
    func testSingleCycleNoLoop_Finished() {
        // Setup: [30s, 20s], loop off, 60s elapsed
        let intervals = [
            IntervalItem(title: "First", duration: Duration.seconds(30), order: 0),
            IntervalItem(title: "Second", duration: Duration.seconds(20), order: 1)
        ]
        
        let result = calculateTimerState(
            intervals: intervals,
            startingIndex: 0,
            startingCycle: 1,
            remainingInInterval: Duration.seconds(30),
            elapsedTime: Duration.seconds(60),
            loopEnabled: false
        )
        
        XCTAssertEqual(result.index, -1, "Timer should be finished")
        XCTAssertEqual(result.cycle, 1, "Should be in cycle 1")
    }
    
    func testLoopEnabled_SecondCycle() {
        // Setup: [30s, 20s], loop on, 70s elapsed (should be in second cycle, first interval with 20s remaining)
        let intervals = [
            IntervalItem(title: "First", duration: Duration.seconds(30), order: 0),
            IntervalItem(title: "Second", duration: Duration.seconds(20), order: 1)
        ]
        
        let result = calculateTimerState(
            intervals: intervals,
            startingIndex: 0,
            startingCycle: 1,
            remainingInInterval: Duration.seconds(30),
            elapsedTime: Duration.seconds(70),
            loopEnabled: true
        )
        
        XCTAssertEqual(result.index, 0, "Should be in first interval of second cycle")
        XCTAssertEqual(result.remaining, Duration.seconds(10), "Should have 10 seconds remaining", accuracy: 0.1)
        XCTAssertEqual(result.cycle, 2, "Should be in cycle 2")
    }
    
    func testLoopEnabled_MultipleCycles() {
        // Setup: [30s, 20s], loop on, 170s elapsed (should be in fourth cycle, first interval with 20s remaining)
        let intervals = [
            IntervalItem(title: "First", duration: Duration.seconds(30), order: 0),
            IntervalItem(title: "Second", duration: Duration.seconds(20), order: 1)
        ]
        
        let result = calculateTimerState(
            intervals: intervals,
            startingIndex: 0,
            startingCycle: 1,
            remainingInInterval: Duration.seconds(30),
            elapsedTime: Duration.seconds(170),
            loopEnabled: true
        )
        
        XCTAssertEqual(result.index, 0, "Should be in first interval")
        XCTAssertEqual(result.remaining, Duration.seconds(10), "Should have 10 seconds remaining", accuracy: 0.1)
        XCTAssertEqual(result.cycle, 4, "Should be in cycle 4")
    }
    
    func testStartFromMiddleInterval() {
        // Setup: Starting from second interval with 15s remaining, 25s elapsed
        let intervals = [
            IntervalItem(title: "First", duration: Duration.seconds(30), order: 0),
            IntervalItem(title: "Second", duration: Duration.seconds(20), order: 1),
            IntervalItem(title: "Third", duration: Duration.seconds(15), order: 2)
        ]
        
        let result = calculateTimerState(
            intervals: intervals,
            startingIndex: 1,
            startingCycle: 1,
            remainingInInterval: Duration.seconds(15),
            elapsedTime: Duration.seconds(25),
            loopEnabled: false
        )
        
        XCTAssertEqual(result.index, 2, "Should be in third interval")
        XCTAssertEqual(result.remaining, Duration.seconds(5), "Should have 5 seconds remaining", accuracy: 0.1)
        XCTAssertEqual(result.cycle, 1, "Should be in cycle 1")
    }
    
    func testEdgeCaseExactCompletion() {
        // Setup: [30s, 20s], exactly 50s elapsed - should finish timer
        let intervals = [
            IntervalItem(title: "First", duration: Duration.seconds(30), order: 0),
            IntervalItem(title: "Second", duration: Duration.seconds(20), order: 1)
        ]
        
        let result = calculateTimerState(
            intervals: intervals,
            startingIndex: 0,
            startingCycle: 1,
            remainingInInterval: Duration.seconds(30),
            elapsedTime: Duration.seconds(50),
            loopEnabled: false
        )
        
        XCTAssertEqual(result.index, -1, "Timer should be finished")
        XCTAssertEqual(result.cycle, 1, "Should be in cycle 1")
    }
    
    func testEmptyIntervals() {
        let result = calculateTimerState(
            intervals: [],
            startingIndex: 0,
            startingCycle: 1,
            remainingInInterval: Duration.seconds(30),
            elapsedTime: Duration.seconds(10),
            loopEnabled: false
        )
        
        XCTAssertEqual(result.index, -1, "Should indicate finished/invalid state")
    }
    
    func testInvalidStartingIndex() {
        let intervals = [
            IntervalItem(title: "First", duration: Duration.seconds(30), order: 0)
        ]
        
        let result = calculateTimerState(
            intervals: intervals,
            startingIndex: 5, // Invalid index
            startingCycle: 1,
            remainingInInterval: Duration.seconds(30),
            elapsedTime: Duration.seconds(10),
            loopEnabled: false
        )
        
        XCTAssertEqual(result.index, -1, "Should indicate invalid state")
    }
}

// Helper extension for Duration comparison with tolerance
extension XCTAssertEqual where T == Duration {
    static func assertEqual(_ expression1: Duration, _ expression2: Duration, accuracy: Double, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
        let diff = abs(expression1.components.seconds - expression2.components.seconds)
        XCTAssertLessThanOrEqual(diff, accuracy, message, file: file, line: line)
    }
}

// Custom assertion for Duration with accuracy
func XCTAssertEqual(_ expression1: Duration, _ expression2: Duration, accuracy: Double, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
    let diff = abs(expression1.components.seconds - expression2.components.seconds)
    XCTAssertLessThanOrEqual(diff, accuracy, message, file: file, line: line)
}