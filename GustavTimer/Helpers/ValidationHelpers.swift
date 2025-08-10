//
//  ValidationHelpers.swift
//  GustavTimer
//
//  Created by AI Assistant on 10.08.2024.
//

import Foundation

struct TimerValidation {
    static func isValidTimerName(_ name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    static func isValidIntervalName(_ name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    static func isValidIntervalDuration(_ duration: Duration) -> Bool {
        let seconds = duration.components.seconds
        return seconds >= 1 && seconds <= 600 // 1 second to 10 minutes
    }
    
    static func isValidIntervalCount(_ count: Int) -> Bool {
        return count >= 1 && count <= 6
    }
    
    static func validateTimer(name: String, intervals: [IntervalItem]) -> ValidationResult {
        if !isValidTimerName(name) {
            return .invalid("Timer name cannot be empty")
        }
        
        if !isValidIntervalCount(intervals.count) {
            return .invalid("Timer must have 1-6 intervals")
        }
        
        for interval in intervals {
            if !isValidIntervalName(interval.title) {
                return .invalid("All intervals must have a name")
            }
            
            if !isValidIntervalDuration(interval.duration) {
                return .invalid("Interval duration must be between 1 second and 10 minutes")
            }
        }
        
        return .valid
    }
}

enum ValidationResult {
    case valid
    case invalid(String)
    
    var isValid: Bool {
        switch self {
        case .valid:
            return true
        case .invalid:
            return false
        }
    }
    
    var errorMessage: String? {
        switch self {
        case .valid:
            return nil
        case .invalid(let message):
            return message
        }
    }
}