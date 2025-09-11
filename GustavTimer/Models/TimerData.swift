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
    var id: Int
    var name: String
    var isVibrating: Bool
    var selectedSound: String?
    var rounds: Int
    
    var intervals: [IntervalData] = [
        IntervalData(value: 30, name: "Work"),
        IntervalData(value: 15, name: "Rest")
    ]

    init(id: Int, name: String, rounds: Int, selectedSound: String?, isVibrating: Bool) {
        self.id = id
        self.name = name
        self.selectedSound = selectedSound
        self.isVibrating = isVibrating
        self.rounds = rounds
    }
}

