//
//  SettingsViewModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 26.07.2025.
//

import SwiftUI
import SwiftData

extension Notification.Name {
    static let loadTimerData = Notification.Name("loadTimerData")
}

class SettingsViewModel: ObservableObject {
    @Published var showSaveAlert = false
    @Published var showDeleteAlert = false
    @Published var newTimerName = ""
    @Published var timerToDelete: TimerData?
    private var currentMonth: Int { Calendar.current.component(.month, from: Date()) }
    
    @AppStorage("actualMonth") var actualMonth: Int = 1
    @AppStorage("monthlyCounter") var monthlyCounter: Int = 0
    @AppStorage("isLooping") var isLooping: Bool = true
    @AppStorage("isVibrating") var isVibrating: Bool = false
    @AppStorage("selectedSound") var selectedSound: String = "beep"
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    @AppStorage("timeDisplayFormat") var timeDisplayFormat: TimeDisplayFormat = .seconds
    
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
    
    func loadTimerData(_ timer: TimerData) {
        // TODO: Load timer data from storage to default timer with id: 0
        // This function should be called with a ModelContext to work properly
        // For now, we'll store the timer data in a way that can be accessed by the view
        DispatchQueue.main.async {
            // The actual loading will be handled by the view that has access to ModelContext
            NotificationCenter.default.post(name: .loadTimerData, object: timer)
        }
    }
    
    func saveTimerData() {
        // TODO: Ask user about name of the saved timer and then save actual timer data with id: 0 to SwiftData with new id (id 0 is reserved for default timer)
        newTimerName = ""
        showSaveAlert = true
    }
    
    func performSaveTimerData(context: ModelContext, defaultTimer: TimerData) {
        guard !newTimerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        do {
            // Get the highest existing ID to generate a new one
            let descriptor = FetchDescriptor<TimerData>(
                sortBy: [SortDescriptor(\.id, order: .reverse)]
            )
            let existingTimers = try context.fetch(descriptor)
            let newId = (existingTimers.first?.id ?? 0) + 1
            
            // Create new timer with copied data from default timer
            let newTimer = TimerData(id: newId, name: newTimerName.trimmingCharacters(in: .whitespacesAndNewlines))
            newTimer.intervals = defaultTimer.intervals.map { interval in
                IntervalData(value: interval.value, name: interval.name)
            }
            newTimer.isLoop = defaultTimer.isLoop
            
            context.insert(newTimer)
            try context.save()
            
        } catch {
            print("Error saving timer: \(error)")
        }
        
        // Clear the input field
        newTimerName = ""
    }
    
    func deleteTimerData(_ timer: TimerData) {
        // TODO: Ask user about deleting, then delete timer data from SwiftData or go back. If timer is loaded, reset default timer data to initial state.
        // Prevent deleting the default timer (id: 0)
        guard timer.id != 0 else { return }
        
        timerToDelete = timer
        showDeleteAlert = true
    }
    
    func performDeleteTimerData(context: ModelContext, defaultTimer: TimerData) {
        guard let timerToDelete = timerToDelete else { return }
        
        do {
            // Delete the timer from context
            context.delete(timerToDelete)
            try context.save()
            
            // Reset default timer to initial state if needed
            // We'll assume the timer was loaded if the intervals match
            let intervalsMatch = timerToDelete.intervals.count == defaultTimer.intervals.count &&
                                zip(timerToDelete.intervals, defaultTimer.intervals).allSatisfy { saved, current in
                                    saved.value == current.value && saved.name == current.name
                                }
            
            if intervalsMatch {
                // Reset to initial default state
                defaultTimer.intervals = [
                    IntervalData(value: 30, name: "Work"),
                    IntervalData(value: 15, name: "Rest")
                ]
                defaultTimer.isLoop = true
                try context.save()
            }
            
        } catch {
            print("Error deleting timer: \(error)")
        }
        
        self.timerToDelete = nil
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
