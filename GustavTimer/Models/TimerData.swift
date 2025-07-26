//
//  TimerData.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 26.07.2025.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class TimerData {
    var id = UUID()
    var intervals: [IntervalData] = [IntervalData(value: 30, name: "Work"), IntervalData(value: 15, name: "Rest")]
    var isLoop: Bool = true
    
    init() {
        
    }
}

