//
//  TimerRepository.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 10.08.2025.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

// Protokol pro možnost mocování repozitáře v testech
protocol TimerRepositoryProtocol {
    // SwiftData operace
    func getDefaultTimer() -> TimerData?
    func saveDefaultTimer(intervals: [IntervalData], isLoop: Bool)
    func createDefaultTimer()
    
    // UserDefaults operace
    var isLooping: Bool { get set }
    var isVibrating: Bool { get set }
    var selectedSound: String { get set }
    var isSoundEnabled: Bool { get set }
    var timeDisplayFormat: TimeDisplayFormat { get set }
    var stopCounter: Int { get set }
    var whatsNewVersion: Int { get set }
    var actualMonth: Int { get set }
    var monthlyCounter: Int { get set }
    
    // Notifikace pro aktualizace dat
    var timerUpdates: AnyPublisher<TimerData, Never> { get }
}

class TimerRepository: TimerRepositoryProtocol, ObservableObject {
    private let modelContext: ModelContext
    private let timerUpdatesSubject = PassthroughSubject<TimerData, Never>()
    
    // Publikovaný proud aktualizací časovače
    var timerUpdates: AnyPublisher<TimerData, Never> {
        timerUpdatesSubject.eraseToAnyPublisher()
    }
    
    // UserDefaults hodnoty
    @AppStorage("isLooping") var isLooping: Bool = true
    @AppStorage("isVibrating") var isVibrating: Bool = false
    @AppStorage("selectedSound") var selectedSound: String = "beep"
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    @AppStorage("timeDisplayFormat") var timeDisplayFormat: TimeDisplayFormat = .seconds
    @AppStorage("stopCounter") var stopCounter: Int = 0
    @AppStorage("whatsNewVersion") var whatsNewVersion: Int = 0
    @AppStorage("actualMonth") var actualMonth: Int = 1
    @AppStorage("monthlyCounter") var monthlyCounter: Int = 0
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // Registrace na notifikace
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLoadTimerData),
            name: .loadTimerData,
            object: nil
        )
    }
    
    // MARK: - SwiftData operace
    
    func getDefaultTimer() -> TimerData? {
        do {
            let descriptor = FetchDescriptor<TimerData>(
                predicate: #Predicate<TimerData> { $0.id == 0 }
            )
            let timerDataArray = try modelContext.fetch(descriptor)
            return timerDataArray.first
        } catch {
            print("Chyba při načítání výchozího časovače: \(error)")
            return nil
        }
    }
    
    func saveDefaultTimer(intervals: [IntervalData], isLoop: Bool) {
        do {
            let descriptor = FetchDescriptor<TimerData>(
                predicate: #Predicate<TimerData> { $0.id == 0 }
            )
            let timerDataArray = try modelContext.fetch(descriptor)
            
            let timerData: TimerData
            if let existingData = timerDataArray.first {
                timerData = existingData
            } else {
                timerData = TimerData(id: 0, name: "Výchozí časovač")
                modelContext.insert(timerData)
            }
            
            timerData.intervals = intervals
            timerData.isLoop = isLoop
            try modelContext.save()
            
            // Informuj všechny posluchače o změně
            timerUpdatesSubject.send(timerData)
        } catch {
            print("Chyba při ukládání časovače: \(error)")
        }
    }
    
    func createDefaultTimer() {
        let defaultIntervals = [
            IntervalData(value: 30, name: "Work"),
            IntervalData(value: 15, name: "Rest")
        ]
        
        saveDefaultTimer(intervals: defaultIntervals, isLoop: true)
    }
    
    // MARK: - Notifikační handlery
    
    @objc private func handleLoadTimerData(_ notification: Notification) {
        guard let timerData = notification.object as? TimerData else { return }
        
        // Aktualizuj výchozí časovač podle načteného
        do {
            let descriptor = FetchDescriptor<TimerData>(
                predicate: #Predicate<TimerData> { $0.id == 0 }
            )
            let defaultTimerArray = try modelContext.fetch(descriptor)
            
            if let defaultTimer = defaultTimerArray.first {
                defaultTimer.intervals = timerData.intervals.map { interval in
                    IntervalData(value: interval.value, name: interval.name)
                }
                defaultTimer.isLoop = timerData.isLoop
                try modelContext.save()
                
                // Informuj všechny posluchače o změně
                timerUpdatesSubject.send(defaultTimer)
            }
        } catch {
            print("Chyba při aktualizaci výchozího časovače: \(error)")
        }
    }
}
