//
//  Extensions.swift
//  GustavTimer
//
//  Created by AI Assistant on 10.08.2024.
//

import Foundation

extension Duration {
    func formatted(timeFormat: String = "mm:ss") -> String {
        let seconds = Int(self.components.seconds)
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        if timeFormat == "ss" {
            return String(format: "%d", seconds)
        } else {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }
    }
    
    var shortDescription: String {
        let seconds = Int(self.components.seconds)
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        if minutes > 0 {
            return "\(minutes)m \(remainingSeconds)s"
        } else {
            return "\(remainingSeconds)s"
        }
    }
}

extension Array where Element == IntervalItem {
    var totalDuration: Duration {
        return self.reduce(Duration.zero) { total, interval in
            total + interval.duration
        }
    }
}

// MARK: - UserDefaults helpers
extension UserDefaults {
    func isValidTimeFormat(_ format: String) -> Bool {
        return format == "ss" || format == "mm:ss"
    }
}