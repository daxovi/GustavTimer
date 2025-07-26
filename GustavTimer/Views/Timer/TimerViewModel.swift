//
//  TimerViewModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 19.04.2023.
//

import Foundation
import Combine
import SwiftUI
import AVKit
import AVFoundation
import PhotosUI

class TimerViewModel: ObservableObject {
    let maxTimers = AppConfig.maxTimerCount
    let maxCountdownValue = AppConfig.maxTimerValue
    
    var isTimerFull: Bool {return !(timers.count < maxTimers)}
    
    @Published var round: Int = 0
    @Published var count: Int = 0
    @Published var showingSheet = false
    @Published var showingWhatsNew: Bool = false
    
    @Environment(\.requestReview) var requestReview
    
    @Published var timers: [IntervalData] = [] {
        didSet {
            saveTimersToUserDefaults()
        }
    }
    
    @Published var isTimerRunning = false
    @Published var progress: Double = 0.0
    @AppStorage("isLooping") var isLooping: Bool = true
    @Published var editMode = EditMode.inactive
    @Published var duration: Double = 1.0
    @AppStorage("stopCounter") var stopCounter: Int = 0
    @AppStorage("whatsNewVersion") var whatsNewVersion: Int = 0
    
    @AppStorage("selectedSound") var selectedSound: String = "beep"
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    
    @Published var startedFromDeeplink: Bool = false
    
    var activeTimerIndex: Int = 0
    var timer: AnyCancellable?
        
    init() {
        UIApplication.shared.isIdleTimerDisabled = false
        loadTimersFromUserDefaults()
        self.count = timers[0].value
    }
    
    private func clearUserDefaults() {
        let userDefaults = UserDefaults.standard
        let dictionary = userDefaults.dictionaryRepresentation()
        for (key, _) in dictionary {
            userDefaults.removeObject(forKey: key)
        }
    }
    
    // Uložit pole `TimerData` do UserDefaults
    private func saveTimersToUserDefaults() {
        // Validace hodnoty `Int` a vytvoření nové instance `TimerData`
        let validTimers = timers.map { timer -> IntervalData in
            let validValue = min(timer.value, maxCountdownValue)
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
        } else {
            migrateTimersFrom122To130()
        }
    }
    
    private func countProgressRatio(timerIndex: Int) -> Double {
        let sum = Double(timers.reduce(0) { $0 + $1.value })
        if timers.count > timerIndex {
            return Double(timers[timerIndex].value)/sum
        } else {
            return 0
        }
    }
    
    func getProgressBarWidth(geometry: GeometryProxy, timerIndex: Int) -> Double {
        let width = geometry.size.width - ((CGFloat(timers.count) - 1) * 5)
        if timerIndex < timers.count {
            return width * countProgressRatio(timerIndex: timerIndex)
        } else {
            return 0.0
        }
    }
    
    func stopTimer() {
        UIApplication.shared.isIdleTimerDisabled = false
        isTimerRunning = false
        timer = nil
        stopCounter += 1
    }
    
    func startTimer() {
        if round == 0 {
            round = 1
        }
        UIApplication.shared.isIdleTimerDisabled = true
        isTimerRunning = true
        timer = Timer
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.count -= 1
                self?.switchTimer()
                
                let activeTimerCount = Double(self?.timers[self?.activeTimerIndex ?? 0].value ?? 0)
                let count = Double(self?.count ?? 0)
                let countDifference = activeTimerCount - count
                self?.progress = (countDifference + 1) / activeTimerCount
            }
    }
    
    func startStopTimer() {
        if timer == nil {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    func switchTimer() {
        playSound()
        if self.count <= 0 && isTimerRunning {
            activeTimerIndex += 1
            if activeTimerIndex >= timers.count {
                duration = 0.0
                activeTimerIndex = 0
                progress = 0.0
                if !isLooping {
                    stopTimer()
                } else {
                    round += 1
                }
            }
            self.count = timers[activeTimerIndex].value
            if self.count <= 0 {
                switchTimer()
            }
        } else {
            duration = 1.0
        }
    }
    
    func resetTimer() {
        duration = 0.01
        round = 0
        timer = nil
        self.activeTimerIndex = 0
        self.progress = 0.0
        self.isTimerRunning = false
        self.count = timers[0].value
        startedFromDeeplink = false
    }
    
    func setCount(count newCount: String) {
        if let number = Int(newCount) {
            if self.timers[0].value != number {
                self.timers[0].value = number
                self.count = self.timers[0].value
            }
        } else {
            print("DEBUG: \(newCount) není číslo")
        }
    }
    
    func addTimer() {
        if !isTimerFull {
            timers.append(IntervalData(value: 5, name: "Lap \(timers.count + 1)"))
        }
    }
    
    func removeTimer(at offsets: IndexSet) {
        timers.remove(atOffsets: offsets)
    }
    
    func removeTimer(index: Int) {
        if index < timers.count {
            timers.remove(at: index)
        }
    }
    
    func toggleSheet() {
        self.showingSheet.toggle()
        resetTimer()
    }
    
    func skipLap() {
        duration = 0.0
        progress = 1.0
        self.count = 0
    }
    
    //MARK: SOUND
    func playSound() {
        if isSoundEnabled && isTimerRunning {
            if self.count < 1 && timers[activeTimerIndex].value > 3 {
                SoundManager.instance.playSound(sound: .final, theme: selectedSound)
            } else if self.count < 4 && self.count > 0 && timers[activeTimerIndex].value > 9 {
                SoundManager.instance.playSound(sound: .countdown, theme: selectedSound)
            }
        }
    }
    
    // Funkce na formátování času
    func formattedTime(from totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds) // Minuty a vteřiny (např. 2:05)
        } else {
            return String(format: "%d", seconds) // Pouze vteřiny (např. 45)
        }
    }
    
    // MARK: 1.2.2 - > 1.3
    private func migrateTimersFrom122To130() {
        if let savedTimers = UserDefaults.standard.array(forKey: "timers") as? [Int] {
            self.timers = []
            for (index, timer) in savedTimers.enumerated() {
                let lapName = "Lap \(index + 1)"
                self.timers.append(IntervalData(value: timer, name: lapName))
            }
            // Vymaž uložené data pro klíč "timers"
            UserDefaults.standard.removeObject(forKey: "timers")
        } else {
            clearUserDefaults()
            self.timers = [IntervalData(value: 60, name: "Work"), IntervalData(value: 30, name: "Rest")]
        }
    }
    
    func showWhatsNew() {
        if whatsNewVersion < AppConfig.version {
            showingWhatsNew = true
            whatsNewVersion = AppConfig.version
        }
    }
        
    // MARK: Deeplinks
    // fungují deeplinks s nastavením timeru gustavtimerapp://timer?warmup=10&run=50&cooldown=20
    // i deeplinks pro whatsnew gustavtimerapp://whatsnew
    func handleDeepLink(url: URL) {
            guard url.scheme == "gustavtimerapp" else {
                print("Invalid scheme")
                return
            }

            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                print("Invalid URL")
                return
            }

        // Zpracování podle host (cesty za schematem)
                if let host = components.host {
                    switch host {
                    case "whatsnew":
                        // Aktivace obrazovky "What's New"
                        showingWhatsNew = true
                        print("Navigating to What's New page")
                        
                    case "timer":
                        // Zpracování intervalů z query parametrů
                        let tempTimers: [IntervalData] = timers
                        timers = []
                        var tempIntervals: [String: Int] = [:]
                        if let queryItems = components.queryItems {
                            for item in queryItems {
                                if let value = item.value, let intValue = Int(value) {
                                    tempIntervals[item.name] = intValue
                                    timers.append(IntervalData(value: intValue, name: item.name))
                                }
                            }
                        }
                        // pokud výsledkem nebude nově nastavený timer tak se vrátí zpět původní timer
                        if timers.isEmpty {
                            timers = tempTimers
                        } else {
                            startedFromDeeplink = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.showingSheet = true
                            }
                        }
                    default:
                        print("Unknown host: \(host)")
                    }
                } else {
                    print("No host found")
                }
        }
}
