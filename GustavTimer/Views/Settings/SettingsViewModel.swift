//
//  SettingsViewModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 26.07.2025.
//

import SwiftUI

class SettingsViewModel: ObservableObject {

    private var currentMonth: Int { return Calendar.current.component(.month, from: Date()) }
    
    @AppStorage("actualMonth") var actualMonth: Int = 1
    @AppStorage("monthlyCounter") var monthlyCounter: Int = 0
    
    @Published var timers: [IntervalData] = [] {
        didSet {
            saveTimersToUserDefaults()
        }
    }
    
    @AppStorage("isLooping") var isLooping: Bool = true
    @AppStorage("selectedSound") var selectedSound: String = "beep"
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    
    init() {
        loadTimersFromUserDefaults()
        checkCurrentMonth()
    }
    
    var isTimerFull: Bool {
        return timers.count >= AppConfig.maxTimerCount
    }
    
    func addInterval() {
        if !isTimerFull {
            timers.append(IntervalData(value: 5, name: "Lap \(timers.count + 1)"))
        }
    }
    
    
    func checkCurrentMonth() {
        
        let currentYear = Calendar.current.component(.year, from: Date())
            
        // Podmínka: pokud je aktuální rok 2024, ukončíme funkci
        if currentYear == 2024 {
            // TESTBUILD
            actualMonth = 1
            actualMonth = MonthlyConfig.testingMonth
            return
        }
        
        // Podmínka: pokud se změnil měsíc, resetujeme počítadlo
        if actualMonth != currentMonth {
            actualMonth = currentMonth
            monthlyCounter = 0
            print("DEBUG checkCurrentMonth: month change")
        }
    }
    
    func getChallengeText() -> LocalizedStringKey {
        switch actualMonth {
        case 1:
            return "January challenge"
        case 2:
            return "February challenge"
        case 3:
            return "March challenge"
        case 4:
            return "April challenge"
        case 5:
            return "May challenge"
        case 6:
            return "June challenge"
        case 7:
            return "July challenge"
        case 8:
            return "August challenge"
        case 9:
            return "September challenge"
        case 10:
            return "October challenge"
        case 11:
            return "November challenge"
        case 12:
            return "December challenge"
        default:
            return "Monthly challenge"
        }
    }
    
    func incrementMonthlyCounter() {
        monthlyCounter += 1
    }
    
    // Uložit pole `TimerData` do UserDefaults
    private func saveTimersToUserDefaults() {
        // Validace hodnoty `Int` a vytvoření nové instance `TimerData`
        let validTimers = timers.map { timer -> IntervalData in
            let validValue = min(timer.value, AppConfig.maxTimerValue)
            return IntervalData(value: validValue, name: timer.name)
        }
        
        if let encodedData = try? JSONEncoder().encode(validTimers) {
            UserDefaults.standard.setValue(encodedData, forKey: "timerData")
        }
    }
    
    // Načíst pole `TimerData` z UserDefaults
    private func loadTimersFromUserDefaults() {
        if let savedData = UserDefaults.standard.data(forKey: "timerData"),
           let decodedTimers = try? JSONDecoder().decode([IntervalData].self, from: savedData) {
            self.timers = decodedTimers
        }
    }
}
