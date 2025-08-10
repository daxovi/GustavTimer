//
//  SampleDataSeeder.swift
//  GustavTimer
//
//  Created by AI Assistant on 10.08.2024.
//

import Foundation
import SwiftData

struct SampleDataSeeder {
    static func seedSampleData(repository: TimersRepository) {
        // Check if we already have data
        if !repository.fetchAll().isEmpty {
            return
        }
        
        // Create a basic warm-up timer
        let warmUpIntervals = [
            IntervalItem(title: "Easy Pace", duration: Duration.seconds(120), order: 0),
            IntervalItem(title: "Dynamic Stretch", duration: Duration.seconds(90), order: 1),
            IntervalItem(title: "Light Jog", duration: Duration.seconds(180), order: 2)
        ]
        
        let _ = repository.createTimer(
            name: "5-Minute Warm Up",
            intervals: warmUpIntervals,
            isFavorite: true
        )
        
        // Create a HIIT timer
        let hiitIntervals = [
            IntervalItem(title: "Work Hard", duration: Duration.seconds(45), order: 0),
            IntervalItem(title: "Rest", duration: Duration.seconds(15), order: 1)
        ]
        
        let _ = repository.createTimer(
            name: "HIIT 45/15",
            intervals: hiitIntervals,
            isFavorite: true
        )
        
        // Create a strength training timer
        let strengthIntervals = [
            IntervalItem(title: "Exercise", duration: Duration.seconds(40), order: 0),
            IntervalItem(title: "Setup", duration: Duration.seconds(20), order: 1),
            IntervalItem(title: "Rest", duration: Duration.seconds(60), order: 2)
        ]
        
        let _ = repository.createTimer(
            name: "Strength Circuit",
            intervals: strengthIntervals,
            isFavorite: false
        )
        
        // Create a meditation timer
        let meditationIntervals = [
            IntervalItem(title: "Breathing", duration: Duration.seconds(180), order: 0),
            IntervalItem(title: "Body Scan", duration: Duration.seconds(300), order: 1),
            IntervalItem(title: "Mindfulness", duration: Duration.seconds(240), order: 2),
            IntervalItem(title: "Gratitude", duration: Duration.seconds(120), order: 3)
        ]
        
        let _ = repository.createTimer(
            name: "Mindfulness Session",
            intervals: meditationIntervals,
            isFavorite: false
        )
    }
}

#if DEBUG
extension SampleDataSeeder {
    // Quick development helper
    static func resetAndSeedData(repository: TimersRepository) {
        // Delete all existing timers
        let existingTimers = repository.fetchAll()
        for timer in existingTimers {
            repository.deleteTimer(timer)
        }
        
        // Seed fresh data
        seedSampleData(repository: repository)
    }
}
#endif