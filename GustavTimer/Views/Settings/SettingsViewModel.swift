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

/// ViewModel pro správu nastavení - zjednodušená verze
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
    private var aktualniMesic: Int { Calendar.current.component(.month, from: Date()) }
    
    // MARK: - Inicializace
    init() {
        zkontrolovatAktualniMesic()
    }
    
    
    // MARK: - Měsíční výzva
    /// Kontrola a aktualizace aktuálního měsíce
    private func zkontrolovatAktualniMesic() {
        let aktualniRok = Calendar.current.component(.year, from: Date())
        
        // Pro testování v roce 2024 použít testovací měsíc
        if aktualniRok == 2024 {
            actualMonth = MonthlyConfig.testingMonth
            return
        }
        
        // Resetování počítadla při změně měsíce
        if actualMonth != aktualniMesic {
            actualMonth = aktualniMesic
            monthlyCounter = 0
        }
    }
    
    /// Získání textu pro měsíční výzvu
    func ziskatTextVyzvy() -> LocalizedStringKey {
        let mesiceVyzev: [LocalizedStringKey] = [
            "January challenge", "February challenge", "March challenge",
            "April challenge", "May challenge", "June challenge", 
            "July challenge", "August challenge", "September challenge",
            "October challenge", "November challenge", "December challenge"
        ]
        
        return (1...12).contains(actualMonth) ? mesiceVyzev[actualMonth - 1] : "Monthly challenge"
    }
    
    /// Zvýšení počítadla měsíční výzvy
    func zvysitPocitadloVyzvy() {
        monthlyCounter += 1
    }
    
    
    // MARK: - Správa časovačů
    /// Načtení dat časovače (pomocí notifikace)
    func nacistDataCasovace(_ timer: TimerData) {
        DispatchQueue.main.async {
            // Skutečné načtení bude zpracováno view s přístupem k ModelContext
            NotificationCenter.default.post(name: .loadTimerData, object: timer)
        }
    }
    
    /// Zobrazení dialogu pro uložení časovače
    func ulozitDataCasovace() {
        newTimerName = ""
        showSaveAlert = true
    }
    
    /// Provedení uložení časovače s novým jménem
    func provesesUlozeniCasovace(context: ModelContext, vychoziCasovac: TimerData) {
        guard !newTimerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        do {
            // Najít nejvyšší existující ID pro generování nového
            let descriptor = FetchDescriptor<TimerData>(
                sortBy: [SortDescriptor(\.id, order: .reverse)]
            )
            let existujiciCasovace = try context.fetch(descriptor)
            let noveId = (existujiciCasovace.first?.id ?? 0) + 1
            
            // Vytvořit nový časovač s kopií dat z výchozího
            let novyCasovac = TimerData(id: noveId, name: newTimerName.trimmingCharacters(in: .whitespacesAndNewlines))
            novyCasovac.intervals = vychoziCasovac.intervals.map { interval in
                IntervalData(value: interval.value, name: interval.name)
            }
            novyCasovac.isLoop = vychoziCasovac.isLoop
            
            context.insert(novyCasovac)
            try context.save()
            
        } catch {
            print("Chyba při ukládání časovače: \(error)")
        }
        
        newTimerName = ""
    }
    
    
    /// Zobrazení dialogu pro smazání časovače
    func smazatDataCasovace(_ timer: TimerData) {
        // Zamezit smazání výchozího časovače (id: 0)
        guard timer.id != 0 else { return }
        
        timerToDelete = timer
        showDeleteAlert = true
    }
    
    /// Provedení smazání časovače
    func provesesSmazaniCasovace(context: ModelContext, vychoziCasovac: TimerData) {
        guard let casovacKeZruseni = timerToDelete else { return }
        
        do {
            // Smazat časovač z kontextu
            context.delete(casovacKeZruseni)
            try context.save()
            
            // Resetovat výchozí časovač pokud byl načten
            let intervalyShodne = casovacKeZruseni.intervals.count == vychoziCasovac.intervals.count &&
                                zip(casovacKeZruseni.intervals, vychoziCasovac.intervals).allSatisfy { ulozeny, aktualni in
                                    ulozeny.value == aktualni.value && ulozeny.name == aktualni.name
                                }
            
            if intervalyShodne {
                // Reset na výchozí stav
                vychoziCasovac.intervals = [
                    IntervalData(value: 30, name: "Práce"),
                    IntervalData(value: 15, name: "Odpočinek")
                ]
                vychoziCasovac.isLoop = true
                try context.save()
            }
            
        } catch {
            print("Chyba při mazání časovače: \(error)")
        }
        
        self.timerToDelete = nil
    }
    
    // MARK: - Správa intervalů časovače
    /// Přidání intervalu k časovači
    func pridatInterval(k timerData: TimerData) {
        guard timerData.intervals.count < 5 else { return }
        timerData.intervals.append(IntervalData(value: 5, name: "Kolo \(timerData.intervals.count + 1)"))
    }
    
    /// Odstranění intervalů podle indexu
    func odstranit(at offsets: IndexSet, z timerData: TimerData) {
        timerData.intervals.remove(atOffsets: offsets)
    }
    
    /// Přesun intervalu na novou pozici
    func presunoutInterval(z source: IndexSet, na destination: Int, v timerData: TimerData) {
        timerData.intervals.move(fromOffsets: source, toOffset: destination)
    }
    
    /// Aktualizace jména intervalu
    func aktualizovatJmenoIntervalu(_ name: String, pro intervalId: UUID, v timerData: TimerData) {
        if let index = timerData.intervals.firstIndex(where: { $0.id == intervalId }) {
            timerData.intervals[index].name = name
        }
    }
    
    /// Aktualizace hodnoty intervalu
    func aktualizovatHodnotuIntervalu(_ value: Int, pro intervalId: UUID, v timerData: TimerData) {
        if let index = timerData.intervals.firstIndex(where: { $0.id == intervalId }) {
            timerData.intervals[index].value = value
        }
    }
}

// MARK: - Kompatibilita se starými názvy metod (pro Views)
extension SettingsViewModel {
    /// Kompatibilita pro checkCurrentMonth
    func checkCurrentMonth() { zkontrolovatAktualniMesic() }
    
    /// Kompatibilita pro loadTimerData
    func loadTimerData(_ timer: TimerData) { nacistDataCasovace(timer) }
    
    /// Kompatibilita pro saveTimerData
    func saveTimerData() { ulozitDataCasovace() }
    
    /// Kompatibilita pro performSaveTimerData
    func performSaveTimerData(context: ModelContext, defaultTimer: TimerData) {
        provesesUlozeniCasovace(context: context, vychoziCasovac: defaultTimer)
    }
    
    /// Kompatibilita pro deleteTimerData
    func deleteTimerData(_ timer: TimerData) { smazatDataCasovace(timer) }
    
    /// Kompatibilita pro performDeleteTimerData
    func performDeleteTimerData(context: ModelContext, defaultTimer: TimerData) {
        provesesSmazaniCasovace(context: context, vychoziCasovac: defaultTimer)
    }
    
    /// Kompatibilita pro getChallengeText
    func getChallengeText() -> LocalizedStringKey { ziskatTextVyzvy() }
    
    /// Kompatibilita pro incrementMonthlyCounter
    func incrementMonthlyCounter() { zvysitPocitadloVyzvy() }
    
    /// Kompatibilita pro addInterval
    func addInterval(to timerData: TimerData) { pridatInterval(k: timerData) }
    
    /// Kompatibilita pro deleteInterval
    func deleteInterval(at offsets: IndexSet, from timerData: TimerData) {
        odstranit(at: offsets, z: timerData)
    }
    
    /// Kompatibilita pro moveInterval
    func moveInterval(from source: IndexSet, to destination: Int, in timerData: TimerData) {
        presunoutInterval(z: source, na: destination, v: timerData)
    }
    
    /// Kompatibilita pro updateIntervalName
    func updateIntervalName(_ name: String, for intervalId: UUID, in timerData: TimerData) {
        aktualizovatJmenoIntervalu(name, pro: intervalId, v: timerData)
    }
    
    /// Kompatibilita pro updateIntervalValue
    func updateIntervalValue(_ value: Int, for intervalId: UUID, in timerData: TimerData) {
        aktualizovatHodnotuIntervalu(value, pro: intervalId, v: timerData)
    }
}
