//
//  SettingsViewModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 26.07.2025.
//

import SwiftUI
import SwiftData

class SettingsViewModel: ObservableObject {
    private var currentMonth: Int { Calendar.current.component(.month, from: Date()) }
    
    @AppStorage("actualMonth") var actualMonth: Int = 1
    @AppStorage("monthlyCounter") var monthlyCounter: Int = 0
    @AppStorage("isLooping") var isLooping: Bool = true
    @AppStorage("isVibrating") var isVibrating: Bool = false
    @AppStorage("selectedSound") var selectedSound: String = "beep"
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    
    init() {
        checkCurrentMonth()
    }
    
    func checkCurrentMonth() {
        let currentYear = Calendar.current.component(.year, from: Date())
            
        // Podmínka: pokud je aktuální rok 2024, ukončíme funkci
        if currentYear == 2024 {
            actualMonth = MonthlyConfig.testingMonth
            return
        }
        
        // Podmínka: pokud se změnil měsíc, resetujeme počítadlo
        if actualMonth != currentMonth {
            actualMonth = currentMonth
            monthlyCounter = 0
        }
    }
    
    func getChallengeText() -> LocalizedStringKey {
        let monthNames: [LocalizedStringKey] = [
            "January challenge", "February challenge", "March challenge",
            "April challenge", "May challenge", "June challenge",
            "July challenge", "August challenge", "September challenge",
            "October challenge", "November challenge", "December challenge"
        ]
        
        return (1...12).contains(actualMonth) ? monthNames[actualMonth - 1] : "Monthly challenge"
    }
    
    func incrementMonthlyCounter() {
        monthlyCounter += 1
    }
    
    // MARK: - Timer Management
    func addInterval(to timerData: TimerData) {
        guard timerData.intervals.count < 5 else { return }
        timerData.intervals.append(IntervalData(value: 5, name: "Lap \(timerData.intervals.count + 1)"))
    }
    
    func deleteInterval(at offsets: IndexSet, from timerData: TimerData) {
        timerData.intervals.remove(atOffsets: offsets)
    }
    
    func moveInterval(from source: IndexSet, to destination: Int, in timerData: TimerData) {
        timerData.intervals.move(fromOffsets: source, toOffset: destination)
    }
    
    func updateIntervalName(_ name: String, for intervalId: UUID, in timerData: TimerData) {
        if let index = timerData.intervals.firstIndex(where: { $0.id == intervalId }) {
            timerData.intervals[index].name = name
        }
    }
    
    func updateIntervalValue(_ value: Int, for intervalId: UUID, in timerData: TimerData) {
        if let index = timerData.intervals.firstIndex(where: { $0.id == intervalId }) {
            timerData.intervals[index].value = value
        }
    }
}
