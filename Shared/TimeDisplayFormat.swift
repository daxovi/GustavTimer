//
//  TimeDisplayFormat.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 26.07.2025.
//

import Foundation

enum TimeDisplayFormat: String, CaseIterable, Codable {
    case seconds = "seconds"
    case minutesSecondsHundredths = "minutesSecondsHundredths"
    
    var displayName: String {
        switch self {
        case .seconds:
            return "Seconds"
        case .minutesSecondsHundredths:
            return "Minutes:Seconds.Hundredths"
        }
    }
}