//
//  AppSettings.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 18.09.2025.
//

import SwiftUI
import Combine

class AppSettings: ObservableObject {
    @AppStorage("rounds") var rounds: Int = -1
    @AppStorage("isVibrating") var isVibrating: Bool = false
    @AppStorage("selectedSound") var selectedSound: String = "beep"
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    
    func save(rounds: Int, isVibrating: Bool, selectedSound: String?) {
        self.rounds = rounds
        self.isVibrating = isVibrating
        if let sound = selectedSound {
            self.selectedSound = sound
            self.isSoundEnabled = true
        } else {
            self.isSoundEnabled = false
        }
    }
    
    func save(from timerData: TimerData) {
        self.rounds = timerData.rounds
        self.isVibrating = timerData.isVibrating
        if let sound = timerData.selectedSound {
            self.selectedSound = sound
            self.isSoundEnabled = true
        } else {
            self.isSoundEnabled = false
        }
    }
}
