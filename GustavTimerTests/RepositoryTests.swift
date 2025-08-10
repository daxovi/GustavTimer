//
//  RepositoryTests.swift
//  GustavTimerTests
//
//  Created by AI Assistant on 10.08.2024.
//

import XCTest
import SwiftData
@testable import GustavTimer

final class RepositoryTests: XCTestCase {
    
    var container: ModelContainer!
    var repository: TimersRepositorySwiftData!
    
    override func setUpWithError() throws {
        container = try ModelContainer(for: TimerTemplate.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        repository = TimersRepositorySwiftData(modelContext: container.mainContext)
    }
    
    override func tearDownWithError() throws {
        container = nil
        repository = nil
    }
    
    func testCreateAndFetchTimer() {
        let intervals = [
            IntervalItem(title: "Warm up", duration: Duration.seconds(30), order: 0),
            IntervalItem(title: "Work", duration: Duration.seconds(45), order: 1)
        ]
        
        let timer = repository.createTimer(name: "Test Timer", intervals: intervals, isFavorite: false)
        
        XCTAssertEqual(timer.name, "Test Timer")
        XCTAssertEqual(timer.intervals.count, 2)
        XCTAssertFalse(timer.isFavorite)
        
        let fetchedTimers = repository.fetchAll()
        XCTAssertEqual(fetchedTimers.count, 1)
        XCTAssertEqual(fetchedTimers.first?.name, "Test Timer")
    }
    
    func testFetchFavorites() {
        let intervals = [
            IntervalItem(title: "Test", duration: Duration.seconds(30), order: 0)
        ]
        
        let _ = repository.createTimer(name: "Regular Timer", intervals: intervals, isFavorite: false)
        let _ = repository.createTimer(name: "Favorite Timer", intervals: intervals, isFavorite: true)
        
        let favorites = repository.fetchFavorites()
        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites.first?.name, "Favorite Timer")
        XCTAssertTrue(favorites.first?.isFavorite ?? false)
    }
    
    func testUpdateTimer() {
        let intervals = [
            IntervalItem(title: "Original", duration: Duration.seconds(30), order: 0)
        ]
        
        let timer = repository.createTimer(name: "Original Name", intervals: intervals, isFavorite: false)
        let originalUpdatedAt = timer.updatedAt
        
        // Modify the timer
        timer.name = "Updated Name"
        timer.isFavorite = true
        
        // Small delay to ensure timestamp difference
        Thread.sleep(forTimeInterval: 0.01)
        
        repository.updateTimer(timer)
        
        let fetchedTimers = repository.fetchAll()
        XCTAssertEqual(fetchedTimers.count, 1)
        XCTAssertEqual(fetchedTimers.first?.name, "Updated Name")
        XCTAssertTrue(fetchedTimers.first?.isFavorite ?? false)
        XCTAssertGreaterThan(fetchedTimers.first?.updatedAt ?? Date.distantPast, originalUpdatedAt)
    }
    
    func testDeleteTimer() {
        let intervals = [
            IntervalItem(title: "Test", duration: Duration.seconds(30), order: 0)
        ]
        
        let timer = repository.createTimer(name: "To Delete", intervals: intervals, isFavorite: false)
        
        var fetchedTimers = repository.fetchAll()
        XCTAssertEqual(fetchedTimers.count, 1)
        
        repository.deleteTimer(timer)
        
        fetchedTimers = repository.fetchAll()
        XCTAssertEqual(fetchedTimers.count, 0)
    }
    
    func testDuplicateTimer() {
        let intervals = [
            IntervalItem(title: "First", duration: Duration.seconds(30), order: 0),
            IntervalItem(title: "Second", duration: Duration.seconds(45), order: 1)
        ]
        
        let originalTimer = repository.createTimer(name: "Original", intervals: intervals, isFavorite: true)
        let duplicatedTimer = repository.duplicateTimer(originalTimer)
        
        XCTAssertEqual(duplicatedTimer.name, "Original Copy")
        XCTAssertFalse(duplicatedTimer.isFavorite)
        XCTAssertEqual(duplicatedTimer.intervals.count, 2)
        XCTAssertEqual(duplicatedTimer.intervals[0].title, "First")
        XCTAssertEqual(duplicatedTimer.intervals[1].title, "Second")
        
        let fetchedTimers = repository.fetchAll()
        XCTAssertEqual(fetchedTimers.count, 2)
    }
    
    func testReorderIntervals() {
        let intervals = [
            IntervalItem(title: "First", duration: Duration.seconds(30), order: 0),
            IntervalItem(title: "Second", duration: Duration.seconds(45), order: 1),
            IntervalItem(title: "Third", duration: Duration.seconds(60), order: 2)
        ]
        
        let timer = repository.createTimer(name: "Test Reorder", intervals: intervals, isFavorite: false)
        
        // Reorder: move first item (index 0) to position 2
        repository.reorderIntervals(in: timer, from: IndexSet(integer: 0), to: 2)
        
        let reorderedIntervals = timer.intervals
        XCTAssertEqual(reorderedIntervals[0].title, "Second")
        XCTAssertEqual(reorderedIntervals[0].order, 0)
        XCTAssertEqual(reorderedIntervals[1].title, "First")
        XCTAssertEqual(reorderedIntervals[1].order, 1)
        XCTAssertEqual(reorderedIntervals[2].title, "Third")
        XCTAssertEqual(reorderedIntervals[2].order, 2)
    }
    
    func testIntervalOrderPersistence() {
        let intervals = [
            IntervalItem(title: "A", duration: Duration.seconds(10), order: 0),
            IntervalItem(title: "B", duration: Duration.seconds(20), order: 1),
            IntervalItem(title: "C", duration: Duration.seconds(30), order: 2)
        ]
        
        let timer = repository.createTimer(name: "Order Test", intervals: intervals, isFavorite: false)
        
        // Reorder and verify persistence
        repository.reorderIntervals(in: timer, from: IndexSet(integer: 2), to: 0)
        
        // Fetch fresh from repository
        let fetchedTimers = repository.fetchAll()
        let fetchedTimer = fetchedTimers.first!
        
        XCTAssertEqual(fetchedTimer.intervals[0].title, "C")
        XCTAssertEqual(fetchedTimer.intervals[0].order, 0)
        XCTAssertEqual(fetchedTimer.intervals[1].title, "A")
        XCTAssertEqual(fetchedTimer.intervals[1].order, 1)
        XCTAssertEqual(fetchedTimer.intervals[2].title, "B")
        XCTAssertEqual(fetchedTimer.intervals[2].order, 2)
    }
}