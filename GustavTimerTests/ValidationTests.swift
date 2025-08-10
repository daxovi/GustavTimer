//
//  ValidationTests.swift
//  GustavTimerTests
//
//  Created by AI Assistant on 10.08.2024.
//

import XCTest
@testable import GustavTimer

final class ValidationTests: XCTestCase {
    
    func testValidTimerName() {
        XCTAssertTrue(TimerValidation.isValidTimerName("Valid Timer"))
        XCTAssertTrue(TimerValidation.isValidTimerName("A"))
        XCTAssertFalse(TimerValidation.isValidTimerName(""))
        XCTAssertFalse(TimerValidation.isValidTimerName("   "))
        XCTAssertFalse(TimerValidation.isValidTimerName("\t\n"))
    }
    
    func testValidIntervalName() {
        XCTAssertTrue(TimerValidation.isValidIntervalName("Warm up"))
        XCTAssertTrue(TimerValidation.isValidIntervalName("X"))
        XCTAssertFalse(TimerValidation.isValidIntervalName(""))
        XCTAssertFalse(TimerValidation.isValidIntervalName("   "))
    }
    
    func testValidIntervalDuration() {
        XCTAssertTrue(TimerValidation.isValidIntervalDuration(Duration.seconds(1)))
        XCTAssertTrue(TimerValidation.isValidIntervalDuration(Duration.seconds(30)))
        XCTAssertTrue(TimerValidation.isValidIntervalDuration(Duration.seconds(600))) // 10 minutes
        
        XCTAssertFalse(TimerValidation.isValidIntervalDuration(Duration.seconds(0)))
        XCTAssertFalse(TimerValidation.isValidIntervalDuration(Duration.seconds(601))) // Over 10 minutes
    }
    
    func testValidIntervalCount() {
        XCTAssertTrue(TimerValidation.isValidIntervalCount(1))
        XCTAssertTrue(TimerValidation.isValidIntervalCount(3))
        XCTAssertTrue(TimerValidation.isValidIntervalCount(6))
        
        XCTAssertFalse(TimerValidation.isValidIntervalCount(0))
        XCTAssertFalse(TimerValidation.isValidIntervalCount(7))
    }
    
    func testValidateTimer_ValidCases() {
        let validIntervals = [
            IntervalItem(title: "Warm up", duration: Duration.seconds(30), order: 0),
            IntervalItem(title: "Work", duration: Duration.seconds(45), order: 1)
        ]
        
        let result = TimerValidation.validateTimer(name: "Test Timer", intervals: validIntervals)
        XCTAssertTrue(result.isValid)
        XCTAssertNil(result.errorMessage)
    }
    
    func testValidateTimer_InvalidName() {
        let validIntervals = [
            IntervalItem(title: "Warm up", duration: Duration.seconds(30), order: 0)
        ]
        
        let result = TimerValidation.validateTimer(name: "", intervals: validIntervals)
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Timer name cannot be empty")
    }
    
    func testValidateTimer_NoIntervals() {
        let result = TimerValidation.validateTimer(name: "Test", intervals: [])
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Timer must have 1-6 intervals")
    }
    
    func testValidateTimer_TooManyIntervals() {
        let tooManyIntervals = Array(0..<7).map { index in
            IntervalItem(title: "Interval \(index)", duration: Duration.seconds(30), order: index)
        }
        
        let result = TimerValidation.validateTimer(name: "Test", intervals: tooManyIntervals)
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Timer must have 1-6 intervals")
    }
    
    func testValidateTimer_InvalidIntervalName() {
        let intervalsWithEmptyName = [
            IntervalItem(title: "Valid", duration: Duration.seconds(30), order: 0),
            IntervalItem(title: "", duration: Duration.seconds(45), order: 1)
        ]
        
        let result = TimerValidation.validateTimer(name: "Test", intervals: intervalsWithEmptyName)
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "All intervals must have a name")
    }
    
    func testValidateTimer_InvalidIntervalDuration() {
        let intervalsWithInvalidDuration = [
            IntervalItem(title: "Valid", duration: Duration.seconds(30), order: 0),
            IntervalItem(title: "Invalid", duration: Duration.seconds(0), order: 1)
        ]
        
        let result = TimerValidation.validateTimer(name: "Test", intervals: intervalsWithInvalidDuration)
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Interval duration must be between 1 second and 10 minutes")
    }
}