//
//  SettingsViewModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 26.07.2025.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    @ObservedObject var timerViewModel: TimerViewModel

    init(timerViewModel: TimerViewModel = .shared) {
        self.timerViewModel = timerViewModel
    }

    // MARK: Timer settings wrappers
    var timers: [TimerData] {
        get { timerViewModel.timers }
        set { timerViewModel.timers = newValue }
    }

    var isTimerFull: Bool { timerViewModel.isTimerFull }

    var isLooping: Bool {
        get { timerViewModel.isLooping }
        set { timerViewModel.isLooping = newValue }
    }

    var showingSheet: Bool {
        get { timerViewModel.showingSheet }
        set { timerViewModel.showingSheet = newValue }
    }

    var showingWhatsNew: Bool {
        get { timerViewModel.showingWhatsNew }
        set { timerViewModel.showingWhatsNew = newValue }
    }

    var isSoundOn: Bool {
        get { timerViewModel.isSoundOn }
        set { timerViewModel.isSoundOn = newValue }
    }

    var activeSoundTheme: String {
        get { timerViewModel.activeSoundTheme }
        set { timerViewModel.activeSoundTheme = newValue }
    }

    var soundThemeArray: [String] { timerViewModel.soundThemeArray }

    var bgIndex: Int {
        get { timerViewModel.bgIndex }
        set { timerViewModel.bgIndex = newValue }
    }

    // MARK: Wrapped methods
    func addTimer() { timerViewModel.addTimer() }
    func removeTimer(at offsets: IndexSet) { timerViewModel.removeTimer(at: offsets) }
    func setBG(index: Int) { timerViewModel.setBG(index: index) }
    func getImage() -> Image { timerViewModel.getImage() }
    func saveSettings() { timerViewModel.saveSettings() }
    func showWhatsNew() { timerViewModel.showWhatsNew() }

    // Monthly challenge
    var monthlyCounter: Int {
        get { timerViewModel.monthlyCounter }
        set { timerViewModel.monthlyCounter = newValue }
    }

    var actualMonth: Int { timerViewModel.actualMonth }
    func getChallengeText() -> LocalizedStringKey { timerViewModel.getChallengeText() }
    func incrementMonthlyCounter() { timerViewModel.incrementMonthlyCounter() }
}

