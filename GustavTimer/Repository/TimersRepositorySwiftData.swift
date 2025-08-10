//
//  TimersRepositorySwiftData.swift
//  GustavTimer
//
//  Created by AI Assistant on 10.08.2024.
//

import Foundation
import SwiftData

final class TimersRepositorySwiftData: TimersRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchAll() -> [TimerTemplate] {
        do {
            let descriptor = FetchDescriptor<TimerTemplate>(
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching timers: \(error)")
            return []
        }
    }
    
    func fetchFavorites() -> [TimerTemplate] {
        do {
            let descriptor = FetchDescriptor<TimerTemplate>(
                predicate: #Predicate { $0.isFavorite == true },
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching favorite timers: \(error)")
            return []
        }
    }
    
    func createTimer(name: String, intervals: [IntervalItem], isFavorite: Bool = false) -> TimerTemplate {
        let timer = TimerTemplate(name: name, intervals: intervals, isFavorite: isFavorite)
        modelContext.insert(timer)
        saveContext()
        return timer
    }
    
    func updateTimer(_ timer: TimerTemplate) {
        timer.updateTimestamp()
        saveContext()
    }
    
    func deleteTimer(_ timer: TimerTemplate) {
        modelContext.delete(timer)
        saveContext()
    }
    
    func duplicateTimer(_ timer: TimerTemplate) -> TimerTemplate {
        let duplicatedIntervals = timer.intervals.enumerated().map { index, interval in
            IntervalItem(title: interval.title, duration: interval.duration, order: index)
        }
        
        let duplicatedTimer = TimerTemplate(
            name: timer.name + " Copy",
            intervals: duplicatedIntervals,
            isFavorite: false
        )
        
        modelContext.insert(duplicatedTimer)
        saveContext()
        return duplicatedTimer
    }
    
    func reorderIntervals(in timer: TimerTemplate, from sourceIndices: IndexSet, to destinationIndex: Int) {
        var updatedIntervals = timer.intervals
        updatedIntervals.move(fromOffsets: sourceIndices, toOffset: destinationIndex)
        
        // Update order property for all intervals
        for index in updatedIntervals.indices {
            updatedIntervals[index].order = index
        }
        
        timer.intervals = updatedIntervals
        updateTimer(timer)
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}