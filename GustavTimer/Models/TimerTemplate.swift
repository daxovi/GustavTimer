//
//  TimerTemplate.swift
//  GustavTimer
//
//  Created by AI Assistant on 10.08.2024.
//

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
    
    init(name: String, intervals: [IntervalItem], isFavorite: Bool = false) {
        self.id = UUID()
        self.name = name
        self.intervals = intervals
        self.isFavorite = isFavorite
        let now = Date()
        self.createdAt = now
        self.updatedAt = now
    }
    
    func updateTimestamp() {
        self.updatedAt = Date()
    }
}

// This is the TimerModel referenced in the main app - we'll create an alias for compatibility
typealias TimerModel = TimerTemplate