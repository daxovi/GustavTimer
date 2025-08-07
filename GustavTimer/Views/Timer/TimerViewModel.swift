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
import SwiftData

class TimerViewModel: ObservableObject {
    // MARK: - Configuration
    let maxTimers = AppConfig.maxTimerCount
    let maxCountdownValue = AppConfig.maxTimerValue
    
    var isTimerFull: Bool { timers.count >= maxTimers }
    
    // MARK: - Published Properties
    @Published var round: Int = 0
    @Published var count: Int = 0
    @Published var showingSheet = false
    @Published var showingWhatsNew: Bool = false
    @Published var timers: [IntervalData] = []
    @Published var isTimerRunning = false
    @Published var progress: Double = 0.0
    @Published var editMode = EditMode.inactive
    @Published var duration: Double = 1.0
    @Published var startedFromDeeplink: Bool = false
    
    // MARK: - Settings
    @AppStorage("isLooping") var isLooping: Bool = true
    @AppStorage("stopCounter") var stopCounter: Int = 0
    @AppStorage("whatsNewVersion") var whatsNewVersion: Int = 0
    @AppStorage("selectedSound") var selectedSound: String = "beep"
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    @AppStorage("isVibrating") var isVibrating: Bool = false
    
    // MARK: - Private Properties
    var activeTimerIndex: Int = 0  // Public for ProgressArrayView access
    private var timer: AnyCancellable?
    private var modelContext: ModelContext?
    
    // MARK: - Initialization
    init() {
        setupDefaultTimers()
    }
    
    private func setupDefaultTimers() {
        timers = [
            IntervalData(value: 60, name: "Work"),
            IntervalData(value: 30, name: "Rest")
        ]
        count = timers[0].value
    }
    
    func setModelContext(_ context: ModelContext) {
        modelContext = context
        loadTimers()
    }
    
    // MARK: - Timer Logic
    func startStopTimer() {
        isTimerRunning ? stopTimer() : startTimer()
    }
    
    private func startTimer() {
        if round == 0 { round = 1 }
        
        UIApplication.shared.isIdleTimerDisabled = true
        isTimerRunning = true
        
        // Immediately calculate initial progress and set animation duration
        duration = 1.0
        updateProgress()
        
        timer = Timer
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }
    
    private func stopTimer() {
        UIApplication.shared.isIdleTimerDisabled = false
        isTimerRunning = false
        timer = nil
        stopCounter += 1
    }
    
    private func updateTimer() {
        count -= 1
        playSound()
        updateProgress()
        
        if count <= 0 {
            switchToNextTimer()
        } else {
            duration = 1.0
        }
    }
    
    private func updateProgress() {
        let activeTimerCount = Double(timers[activeTimerIndex].value)
        let currentCount = Double(count)
        let countDifference = activeTimerCount - currentCount
        progress = (countDifference + 1) / activeTimerCount
    }
    
    private func switchToNextTimer() {
        
        activeTimerIndex += 1
        
        if activeTimerIndex >= timers.count {
            handleRoundCompletion()
        } else {
            vibrate()
            count = timers[activeTimerIndex].value
            progress = 0.0  // Reset progress immediately for new timer
            duration = 0.01  // Very quick transition to 0
            
            // After a brief moment, set up the animation for the new timer
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                self.duration = 1.0
                self.updateProgress()
            }
            
            if count <= 0 {
                switchToNextTimer() // Skip zero-duration timers
            }
        }
    }
    
    private func handleRoundCompletion() {
        duration = 0.0
        activeTimerIndex = 0
        progress = 0.0
        
        if isLooping {
            vibrateRound()
            round += 1
            count = timers[0].value
            
            // Set up immediate animation for the new round
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                self.duration = 1.0
                self.updateProgress()
            }
        } else {
            vibrateFinish()
            resetTimer()
        }
    }
    
    func resetTimer() {
        stopTimer()
        duration = 0.01
        round = 0
        timer = nil
        activeTimerIndex = 0
        progress = 0.0
        isTimerRunning = false
        count = timers[0].value
        startedFromDeeplink = false
        loadTimers()
    }
    
    func skipLap() {
        duration = 0.0
        progress = 1.0
        count = 0
    }
    
    // MARK: - Timer Management
    func addTimer() {
        guard !isTimerFull else { return }
        timers.append(IntervalData(value: 5, name: "Lap \(timers.count + 1)"))
        saveTimers()
    }
    
    func removeTimer(at offsets: IndexSet) {
        timers.remove(atOffsets: offsets)
        saveTimers()
    }
    
    func removeTimer(index: Int) {
        guard index < timers.count else { return }
        timers.remove(at: index)
        saveTimers()
    }
    
    // MARK: - Progress Bar
    func getProgressBarWidth(geometry: GeometryProxy, timerIndex: Int) -> Double {
        guard timerIndex < timers.count else { return 0.0 }
        
        let totalWidth = geometry.size.width - (CGFloat(timers.count - 1) * 5)
        let ratio = progressRatio(for: timerIndex)
        return totalWidth * ratio
    }
    
    private func progressRatio(for timerIndex: Int) -> Double {
        let totalTime = Double(timers.reduce(0) { $0 + $1.value })
        guard totalTime > 0, timerIndex < timers.count else { return 0 }
        return Double(timers[timerIndex].value) / totalTime
    }
    
    // MARK: - Utility
    func formattedTime(from totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return minutes > 0
            ? String(format: "%d:%02d", minutes, seconds)
            : String(format: "%d", seconds)
    }
    
    func toggleSheet() {
        showingSheet.toggle()
        resetTimer()
    }
    
    // MARK: - Feedback
    private func vibrate() {
        guard isVibrating && isTimerRunning else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func vibrateRound() {
        guard isVibrating && isTimerRunning else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func vibrateFinish() {
        guard isVibrating && isTimerRunning else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    private func playSound() {
        guard isSoundEnabled && isTimerRunning else { return }
        
        if count < 1 && timers[activeTimerIndex].value > 1 {
            SoundManager.instance.playSound(sound: .final, theme: selectedSound)
        } else if count < 4 && count > 0 && timers[activeTimerIndex].value > 9 {
            SoundManager.instance.playSound(sound: .countdown, theme: selectedSound)
        }
    }
    
    // MARK: - What's New
    func showWhatsNew() {
        if whatsNewVersion < AppConfig.version {
            showingWhatsNew = true
            whatsNewVersion = AppConfig.version
        }
    }
    
    // MARK: - Deep Links
    func handleDeepLink(url: URL) {
        guard url.scheme == "gustavtimerapp",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else { return }
        
        switch host {
        case "whatsnew":
            showingWhatsNew = true
            
        case "timer":
            handleTimerDeepLink(components: components)
            
        default:
            print("Unknown deeplink host: \(host)")
        }
    }
    
    private func handleTimerDeepLink(components: URLComponents) {
        let originalTimers = timers
        var newTimers: [IntervalData] = []
        
        if let queryItems = components.queryItems {
            for item in queryItems {
                if let value = item.value, let intValue = Int(value) {
                    newTimers.append(IntervalData(value: intValue, name: item.name))
                }
            }
        }
        
        if !newTimers.isEmpty {
            timers = newTimers
            startedFromDeeplink = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showingSheet = true
            }
        } else {
            timers = originalTimers
        }
    }
}

// MARK: - Data Management
extension TimerViewModel {
    private func loadTimers() {
        guard let context = modelContext else {
            setupDefaultTimers()
            return
        }
        
        do {
            let descriptor = FetchDescriptor<TimerData>()
            let timerDataArray = try context.fetch(descriptor)
            
            if let timerData = timerDataArray.first {
                timers = timerData.intervals
                if !timers.isEmpty {
                    count = timers[0].value
                }
            } else {
                createAndSaveDefaultTimers()
            }
        } catch {
            print("Error loading timers: \(error)")
            setupDefaultTimers()
        }
    }
    
    private func saveTimers() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<TimerData>()
            let timerDataArray = try context.fetch(descriptor)
            
            let timerData: TimerData
            if let existingData = timerDataArray.first {
                timerData = existingData
            } else {
                timerData = TimerData(id: 0)
                context.insert(timerData)
            }
            
            timerData.intervals = timers
            try context.save()
        } catch {
            print("Error saving timers: \(error)")
        }
    }
    
    private func createAndSaveDefaultTimers() {
        setupDefaultTimers()
        saveTimers()
    }
}
