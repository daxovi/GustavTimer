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

/// ViewModel pro správu nastavení - zjednodušená verze s českými komentáři
class SettingsViewModel: ObservableObject {
    // MARK: - Publikované vlastnosti
    @Published var showSaveAlert = false
    @Published var showDeleteAlert = false
    @Published var newTimerName = ""
    @Published var timerToDelete: TimerData?
    
    // MARK: - Nastavení (AppStorage)
    @AppStorage("actualMonth") var actualMonth: Int = 1
    @AppStorage("monthlyCounter") var monthlyCounter: Int = 0
    @AppStorage("isLooping") var isLooping: Bool = true
    @AppStorage("isVibrating") var isVibrating: Bool = false
    @AppStorage("selectedSound") var selectedSound: String = "beep"
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    @AppStorage("timeDisplayFormat") var timeDisplayFormat: TimeDisplayFormat = .seconds
    
    /// Aktuální měsíc z kalendáře
    private var currentMonth: Int { Calendar.current.component(.month, from: Date()) }
    
    // MARK: - Inicializace
    init() {
        checkCurrentMonth()
    }
    
    // MARK: - Měsíční výzva
    /// Kontrola a aktualizace aktuálního měsíce
    func checkCurrentMonth() {
        let currentYear = Calendar.current.component(.year, from: Date())
        
        // Pro testování v roce 2024 použít testovací měsíc
        if currentYear == 2024 {
            actualMonth = MonthlyConfig.testingMonth
            return
        }
        
        // Resetování počítadla při změně měsíce
        if actualMonth != currentMonth {
            actualMonth = currentMonth
            monthlyCounter = 0
        }
    }
    
    func areTimersEqual(_ timer1: TimerData, _ defaultTimer: TimerData) -> Bool {
        let intervalsMatch = timer1.intervals.count == defaultTimer.intervals.count &&
        zip(timer1.intervals, defaultTimer.intervals).allSatisfy { stored, current in
            stored.value == current.value && stored.name == current.name
        }
        
        // Porovnání efektivního zvuku (nil pokud je vypnutý, jinak selectedSound)
        let effectiveSound1 = timer1.selectedSound != nil ? timer1.selectedSound : nil
        let effectiveSound2 = isSoundEnabled ? selectedSound : nil
        
        return intervalsMatch &&
               timer1.isLooping == isLooping &&
               timer1.isVibrating == isVibrating &&
               effectiveSound1 == effectiveSound2
    }

    
    /// Získání textu pro měsíční výzvu
    func getChallengeText() -> LocalizedStringKey {
        let challengeTexts: [LocalizedStringKey] = [
            "January challenge", "February challenge", "March challenge",
            "April challenge", "May challenge", "June challenge", 
            "July challenge", "August challenge", "September challenge",
            "October challenge", "November challenge", "December challenge"
        ]
        
        return (1...12).contains(actualMonth) ? challengeTexts[actualMonth - 1] : "Monthly challenge"
    }
    
    /// Zvýšení počítadla měsíční výzvy
    func incrementMonthlyCounter() {
        monthlyCounter += 1
    }
    
    // MARK: - Správa časovačů
    /// Načtení dat časovače (pomocí notifikace)
    func loadTimerData(_ timer: TimerData) {
        DispatchQueue.main.async {
            // Skutečné načtení bude zpracováno view s přístupem k ModelContext
            NotificationCenter.default.post(name: .loadTimerData, object: timer)
        }
    }
    
    /// Zobrazení dialogu pro uložení časovače
    func saveTimerData() {
        newTimerName = ""
        showSaveAlert = true
    }
    
    /// Provedení uložení časovače s novým jménem
    func performSaveTimerData(context: ModelContext, defaultTimer: TimerData) {
        guard !newTimerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        do {
            // Najít nejvyšší existující ID pro generování nového
            let descriptor = FetchDescriptor<TimerData>(
                sortBy: [SortDescriptor(\.id, order: .reverse)]
            )
            let existingTimers = try context.fetch(descriptor)
            let newId = (existingTimers.first?.id ?? 0) + 1
            
            // Vytvořit nový časovač s kopií dat z výchozího
            let newTimer = TimerData(id: newId, name: newTimerName.trimmingCharacters(in: .whitespacesAndNewlines), isLooping: isLooping, selectedSound: isSoundEnabled ? selectedSound : nil, isVibrating: isVibrating)
            newTimer.intervals = defaultTimer.intervals.map { interval in
                IntervalData(value: interval.value, name: interval.name)
            }
            
            context.insert(newTimer)
            try context.save()
            
        } catch {
            print("Chyba při ukládání časovače: \(error)")
        }
        
        newTimerName = ""
    }
    
    /// Zobrazení dialogu pro smazání časovače
    func deleteTimerData(_ timer: TimerData) {
        // Zamezit smazání výchozího časovače (id: 0)
        guard timer.id != 0 else { return }
        
        timerToDelete = timer
        showDeleteAlert = true
    }
    
    /// Provedení smazání časovače
    func performDeleteTimerData(context: ModelContext, defaultTimer: TimerData) {
        guard let timerToDelete = timerToDelete else { return }
        
        do {
            // Smazat časovač z kontextu
            context.delete(timerToDelete)
            try context.save()
            
            // Resetovat výchozí časovač pokud byl načten
            let intervalsMatch = timerToDelete.intervals.count == defaultTimer.intervals.count &&
                                zip(timerToDelete.intervals, defaultTimer.intervals).allSatisfy { stored, current in
                                    stored.value == current.value && stored.name == current.name
                                }
            
            if intervalsMatch {
                // Reset na výchozí stav
                defaultTimer.intervals = [
                    IntervalData(value: 30, name: "Práce"),
                    IntervalData(value: 15, name: "Odpočinek")
                ]
                defaultTimer.isLooping = true
                try context.save()
            }
            
        } catch {
            print("Chyba při mazání časovače: \(error)")
        }
        
        self.timerToDelete = nil
    }
    
    // MARK: - Správa intervalů časovače
    /// Přidání intervalu k časovači
    func addInterval(to timerData: TimerData) {
        guard timerData.intervals.count < 5 else { return }
        timerData.intervals.append(IntervalData(value: 5, name: "Kolo \(timerData.intervals.count + 1)"))
    }
    
    /// Odstranění intervalů podle indexu
    func deleteInterval(at offsets: IndexSet, from timerData: TimerData) {
        timerData.intervals.remove(atOffsets: offsets)
    }
    
    /// Přesun intervalu na novou pozici
    func moveInterval(from source: IndexSet, to destination: Int, in timerData: TimerData) {
        timerData.intervals.move(fromOffsets: source, toOffset: destination)
    }
    
    /// Aktualizace jména intervalu
    func updateIntervalName(_ name: String, for intervalId: UUID, in timerData: TimerData) {
        if let index = timerData.intervals.firstIndex(where: { $0.id == intervalId }) {
            timerData.intervals[index].name = name
        }
    }
    
    /// Aktualizace hodnoty intervalu
    func updateIntervalValue(_ value: Int, for intervalId: UUID, in timerData: TimerData) {
        if let index = timerData.intervals.firstIndex(where: { $0.id == intervalId }) {
            timerData.intervals[index].value = value
        }
    }
}
