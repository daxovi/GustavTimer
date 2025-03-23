//
//  GustavViewModel.swift
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

import BackgroundTasks

class GustavViewModel: ObservableObject {
    let maxTimers = AppConfig.maxTimerCount
    let maxCountdownValue = AppConfig.maxTimerValue
    
    var isTimerFull: Bool {return !(timers.count < maxTimers)}
    
    @Published var round: Int = 0
    @Published var count: Int = 0
    @Published var showingSheet = false
    @Published var showingWhatsNew: Bool = false
    @Published var liveActivity: Activity<TimerAtributes>? = nil
    
    @Published var timers: [TimerData] = [] {
        didSet {
            saveTimersToUserDefaults()
        }
    }
    
    @Published var isTimerRunning = false
    @Published var progress: Double = 0.0
    @AppStorage("isLooping") var isLooping: Bool = true
    @AppStorage("isSoundOn") var isSoundOn = true
    @Published var editMode = EditMode.inactive
    @Published var duration: Double = 1.0
    @AppStorage("bgIndex") var bgIndex = 0
    @AppStorage("stopCounter") var stopCounter: Int = 0
    @AppStorage("whatsNewVersion") var whatsNewVersion: Int = 0
    
    @Published var startedFromDeeplink: Bool = false
    
    var activeTimerIndex: Int = 0
    var timer: AnyCancellable?
    
    var audioPlayer: AVAudioPlayer?
    
    static let shared = GustavViewModel()
    
    init() {
        UIApplication.shared.isIdleTimerDisabled = false
        loadTimersFromUserDefaults()
        self.count = timers[0].value
        checkCurrentMonth()
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
        let validTimers = timers.map { timer -> TimerData in
            let validValue = min(timer.value, maxCountdownValue)
            return TimerData(value: validValue, name: timer.name)
        }
        
        if let encodedData = try? JSONEncoder().encode(validTimers) {
            UserDefaults.standard.setValue(encodedData, forKey: "timerData")
        }
    }
    
    // Načíst pole `TimerData` z UserDefaults
    private func loadTimersFromUserDefaults() {
        if let savedData = UserDefaults.standard.data(forKey: "timerData"),
           let decodedTimers = try? JSONDecoder().decode([TimerData].self, from: savedData) {
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
        
        stopSilentAudio()
        stopLiveActivity()
    }
    
    func startTimer() {
        if round == 0 {
            round = 1
        }
        
        playSilentAudio()
        startLiveActivity()
        
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
        
    func startStopTimer(requestReview: @escaping () -> ()) {
        if timer == nil {
            startTimer()
        } else {
            stopTimer()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            if self.stopCounter > 20 && !self.isTimerRunning {
                if !self.isTimerRunning {
                    self.stopCounter = 0
                    requestReview()
                }
            }
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
                    print("DEBUG: called updateLiveActivity from switch 1")
                }
            }
            self.count = timers[activeTimerIndex].value
            if self.count <= 0 {
                switchTimer()
                print("DEBUG: called updateLiveActivity from switch 2")
            }
            updateLiveActivity()
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
            timers.append(TimerData(value: 5, name: "Lap \(timers.count + 1)"))
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
    @Published var soundThemeArray = ["beep", "90s", "bell", "trumpet", "game"]
    @AppStorage("soundTheme") var activeSoundTheme = "beep"
    
    func playSound() {
        if isSoundOn && isTimerRunning {
            if self.count < 1 && timers[activeTimerIndex].value > 3 {
                SoundManager.instance.playSound(sound: .final, theme: activeSoundTheme)
            } else if self.count < 4 && self.count > 0 && timers[activeTimerIndex].value > 9 {
                SoundManager.instance.playSound(sound: .countdown, theme: activeSoundTheme)
            }
        }
    }
    
    func saveSettings() {
        // Resetujeme časovač
        resetTimer()
        
        // Zavřeme sheet
 //       self.showingSheet = false
    }
    
    
    //MARK: BG
    let bgImages: [BGImageModel] = [
        BGImageModel(image: "Benchpress", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Boxer", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Ground", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Lanes", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Poster", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Pullup", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Squat", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Wood", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Buddha", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Lotos", author: "", source: "www.unsplash.com")
    ]
    
    func setBG(index: Int) {
        self.bgIndex = index
    }
    
    func getImage() -> Image {
        if bgImages.indices.contains(bgIndex) {
            return bgImages[bgIndex].getImage()
        } else {
            return bgImages[0].getImage()
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
                self.timers.append(TimerData(value: timer, name: lapName))
            }
            // Vymaž uložené data pro klíč "timers"
            UserDefaults.standard.removeObject(forKey: "timers")
        } else {
            clearUserDefaults()
            self.timers = [TimerData(value: 60, name: "Work"), TimerData(value: 30, name: "Rest")]
        }
    }
    
    func showWhatsNew() {
        if whatsNewVersion < AppConfig.version {
            showingWhatsNew = true
            whatsNewVersion = AppConfig.version
        }
    }
    
    // MARK: Monthly challenge
    private var currentMonth: Int { return Calendar.current.component(.month, from: Date()) }
    @AppStorage("actualMonth") var actualMonth: Int = 1
    @AppStorage("monthlyCounter") var monthlyCounter: Int = 0
    
    func checkCurrentMonth() {
        print("DEBUG actualMonth: \(actualMonth)")
        print("DEBUG currentMonth: \(currentMonth)")
        
        let currentYear = Calendar.current.component(.year, from: Date())
            
        // Podmínka: pokud je aktuální rok 2024, ukončíme funkci
        if currentYear == 2024 {
            print("DEBUG checkCurrentMonth: Current year is 2024, skipping check")
            // TESTBUILD
            actualMonth = 1
            actualMonth = MonthlyConfig.testingMonth
            return
        }

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
                        let tempTimers: [TimerData] = timers
                        timers = []
                        var tempIntervals: [String: Int] = [:]
                        if let queryItems = components.queryItems {
                            for item in queryItems {
                                if let value = item.value, let intValue = Int(value) {
                                    tempIntervals[item.name] = intValue
                                    timers.append(TimerData(value: intValue, name: item.name))
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

// MARK: - Live Activity
import ActivityKit

extension GustavViewModel {
    func startLiveActivity() {
        print("DEBUG: startLiveActivity")
        let atributes = TimerAtributes(appName: "Gustav Timer App")
        let state = TimerAtributes.TimerStatus(timerName: timers[activeTimerIndex].name, endTime: Date().addingTimeInterval(TimeInterval(count)))
        
        liveActivity = try? Activity<TimerAtributes>.request(attributes: atributes, content: .init(state: state, staleDate: Date().addingTimeInterval(TimeInterval(count + 1))))
    }
    
    func stopLiveActivity() {
        let state = TimerAtributes.TimerStatus(timerName: "", endTime: Date().addingTimeInterval(1))
        print("DEBUG: stopLiveActivity start")
        
        Task {
            await liveActivity?.end(.init(state: state, staleDate: .now), dismissalPolicy: .immediate)
            
            print("DEBUG: stopLiveActivity")

        }
    }
    
    func updateLiveActivity() {
        let state = TimerAtributes.TimerStatus(timerName: timers[activeTimerIndex].name, endTime: Date().addingTimeInterval(TimeInterval(count)))
        print("DEBUG: updateLiveActivity start")

        Task {
            await liveActivity?.update(.init(state: state, staleDate: Date().addingTimeInterval(TimeInterval(count))))
            print("DEBUG: updateLiveActivity, count: \(count), timerName: \(timers[activeTimerIndex].name)")
        }
    }
}

// MARK: - Background task Hack
import AVFoundation

extension GustavViewModel {
    func playSilentAudio() {
        SoundManager.instance.playSilentAudio()
    }
    
    func stopSilentAudio() {
        SoundManager.instance.stopAudio()
    }
}
