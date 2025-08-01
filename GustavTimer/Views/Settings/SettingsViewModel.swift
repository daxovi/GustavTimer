//
//  SettingsViewModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 26.07.2025.
//

import SwiftUI
import SwiftData

class SettingsViewModel: ObservableObject {

    private var currentMonth: Int { return Calendar.current.component(.month, from: Date()) }
    private var modelContext: ModelContext?
    
    @AppStorage("actualMonth") var actualMonth: Int = 1
    @AppStorage("monthlyCounter") var monthlyCounter: Int = 0
    
    @Published var timers: [IntervalData] = []
    @Published var timerIsFull: Bool = false
    
    @AppStorage("isLooping") var isLooping: Bool = true
    @AppStorage("selectedSound") var selectedSound: String = "beep"
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    
    init() {
        checkCurrentMonth()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadTimersFromSwiftData()
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
}

extension SettingsViewModel {
    // Načíst timery ze SwiftData
    private func loadTimersFromSwiftData() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<TimerData>()
            let timerDataArray = try context.fetch(descriptor)
            
            if let timerData = timerDataArray.first {
                // Převést TimerData na IntervalData
                self.timers = timerData.intervals.map { interval in
                    IntervalData(value: interval.value, name: interval.name)
                }
            } else {
                // Pokud nejsou data, vytvoř výchozí
                createDefaultTimerData()
            }
        } catch {
            print("Error loading timers from SwiftData: \(error)")
            createDefaultTimerData()
        }
    }
    
    // Uložit timery do SwiftData
    private func saveTimersToSwiftData() {
        guard let context = modelContext else { return }
        
        do {
            // Načti existující TimerData nebo vytvoř nový
            let descriptor = FetchDescriptor<TimerData>()
            let timerDataArray = try context.fetch(descriptor)
            
            let timerData: TimerData
            if let existingTimerData = timerDataArray.first {
                timerData = existingTimerData
            } else {
                timerData = TimerData(id: 0)
                context.insert(timerData)
            }
            
            // Aktualizuj intervals
            timerData.intervals = timers.map { timer in
                IntervalData(value: timer.value, name: timer.name)
            }
            
            try context.save()
        } catch {
            print("Error saving timers to SwiftData: \(error)")
        }
    }
    
    // Vytvoř výchozí data
    private func createDefaultTimerData() {
        self.timers = [IntervalData(value: 60, name: "Work"), IntervalData(value: 30, name: "Rest")]
        saveTimersToSwiftData()
    }
}
