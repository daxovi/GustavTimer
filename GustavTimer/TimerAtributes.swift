//
//  TimerAtributes.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 15.03.2025.
//

import ActivityKit
import SwiftUI

struct TimerAtributes: ActivityAttributes {
    public typealias TimerStatus = ContentState
    var appName: String
    
    public struct ContentState: Codable, Hashable {
        var timerName: String
        var endTime: Date
    }
    
}
