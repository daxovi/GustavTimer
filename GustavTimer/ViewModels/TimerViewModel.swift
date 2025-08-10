//
//  TimerViewModel.swift
//  GustavTimer
//
//  Created by AI Assistant on 10.08.2024.
//

import Foundation
import SwiftUI
import Observation

@Observable
final class TimerViewModel {
    // MARK: - Timer State
    enum TimerState {
        case stopped
        case running
        case paused
    }
    
    // MARK: - Properties
    var state: TimerState = .stopped
    var currentTimer: TimerTemplate?
    var currentIntervalIndex: Int = 0
    var remainingInCurrentInterval: Duration = .zero
    var currentCycle: Int = 1
    
    // MARK: - Background State
    private var referenceDate: Date?
    private var referenceDuration: Duration?
    private var backgroundState: BackgroundTimerState?
    
    // MARK: - Dependencies
    private let _repository: TimersRepository
    private let audioService: AudioService
    private let hapticsService: HapticsService
    private let clock = ContinuousClock()
    private var tickTask: Task<Void, Never>?
    
    // MARK: - Public Repository Access
    var repository: TimersRepository { _repository }
    
    // MARK: - Settings
    @AppStorage("loopEnabled") var loopEnabled: Bool = false
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
    @AppStorage("soundsEnabled") var soundsEnabled: Bool = true
    @AppStorage("timeFormat") var timeFormat: String = "mm:ss"
    
    init(repository: TimersRepository, audioService: AudioService, hapticsService: HapticsService) {
        self._repository = repository
        self.audioService = audioService
        self.hapticsService = hapticsService
    }
    
    // MARK: - Timer Controls
    func loadTimer(_ timer: TimerTemplate) {
        guard !timer.intervals.isEmpty else { return }
        
        stop()
        currentTimer = timer
        currentIntervalIndex = 0
        remainingInCurrentInterval = timer.intervals[0].duration
        currentCycle = 1
    }
    
    func start() {
        guard let timer = currentTimer,
              !timer.intervals.isEmpty,
              state != .running else { return }
        
        state = .running
        referenceDate = Date()
        referenceDuration = remainingInCurrentInterval
        
        startTicking()
    }
    
    func pause() {
        guard state == .running else { return }
        
        state = .paused
        tickTask?.cancel()
        tickTask = nil
    }
    
    func resume() {
        guard state == .paused else { return }
        
        state = .running
        referenceDate = Date()
        referenceDuration = remainingInCurrentInterval
        
        startTicking()
    }
    
    func stop() {
        state = .stopped
        tickTask?.cancel()
        tickTask = nil
        
        if let timer = currentTimer {
            currentIntervalIndex = 0
            remainingInCurrentInterval = timer.intervals.isEmpty ? .zero : timer.intervals[0].duration
            currentCycle = 1
        }
    }
    
    func reset() {
        stop()
    }
    
    func nextInterval() {
        guard let timer = currentTimer else { return }
        
        let nextIndex = currentIntervalIndex + 1
        
        if nextIndex < timer.intervals.count {
            // Move to next interval in current cycle
            currentIntervalIndex = nextIndex
            remainingInCurrentInterval = timer.intervals[nextIndex].duration
        } else if loopEnabled {
            // Start new cycle
            currentIntervalIndex = 0
            remainingInCurrentInterval = timer.intervals[0].duration
            currentCycle += 1
        } else {
            // Timer finished
            stop()
            return
        }
        
        // Update reference if running
        if state == .running {
            referenceDate = Date()
            referenceDuration = remainingInCurrentInterval
        }
    }
    
    func previousInterval() {
        guard let timer = currentTimer else { return }
        
        if currentIntervalIndex > 0 {
            // Move to previous interval in current cycle
            currentIntervalIndex -= 1
            remainingInCurrentInterval = timer.intervals[currentIntervalIndex].duration
        } else if loopEnabled && currentCycle > 1 {
            // Move to last interval of previous cycle
            currentIntervalIndex = timer.intervals.count - 1
            remainingInCurrentInterval = timer.intervals[currentIntervalIndex].duration
            currentCycle -= 1
        }
        
        // Update reference if running
        if state == .running {
            referenceDate = Date()
            referenceDuration = remainingInCurrentInterval
        }
    }
    
    func restartCurrentInterval() {
        guard let timer = currentTimer else { return }
        
        remainingInCurrentInterval = timer.intervals[currentIntervalIndex].duration
        
        // Update reference if running
        if state == .running {
            referenceDate = Date()
            referenceDuration = remainingInCurrentInterval
        }
    }
    
    // MARK: - Background Handling
    func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            saveBackgroundState()
        case .active:
            restoreFromBackground()
        default:
            break
        }
    }
    
    private func saveBackgroundState() {
        guard state == .running,
              let timer = currentTimer,
              let refDate = referenceDate,
              let refDuration = referenceDuration else { return }
        
        backgroundState = BackgroundTimerState(
            timerID: timer.id,
            intervalIndex: currentIntervalIndex,
            remainingDuration: remainingInCurrentInterval,
            cycle: currentCycle,
            referenceDate: refDate,
            referenceDuration: refDuration
        )
    }
    
    private func restoreFromBackground() {
        guard let bgState = backgroundState,
              let timer = currentTimer,
              timer.id == bgState.timerID else { return }
        
        let elapsed = Date().timeIntervalSince(bgState.referenceDate)
        let elapsedDuration = Duration.seconds(elapsed)
        
        let (newIndex, newRemaining, newCycle) = calculateTimerState(
            intervals: timer.intervals,
            startingIndex: bgState.intervalIndex,
            startingCycle: bgState.cycle,
            remainingInInterval: bgState.referenceDuration,
            elapsedTime: elapsedDuration,
            loopEnabled: loopEnabled
        )
        
        currentIntervalIndex = newIndex
        remainingInCurrentInterval = newRemaining
        currentCycle = newCycle
        
        // Clear background state
        backgroundState = nil
        
        // Check if timer should be stopped
        if newIndex == -1 { // Timer finished
            stop()
            hapticsService.cycleEnd()
            audioService.playCycleEnd()
        } else {
            // Update references and continue
            referenceDate = Date()
            referenceDuration = remainingInCurrentInterval
            
            if state == .running {
                startTicking()
            }
        }
    }
    
    // MARK: - Tick Logic
    private func startTicking() {
        tickTask = Task { @MainActor in
            for await _ in clock.timer(interval: .milliseconds(150)) {
                guard state == .running else { break }
                await tick()
            }
        }
    }
    
    @MainActor
    private func tick() async {
        guard let timer = currentTimer,
              let refDate = referenceDate,
              let refDuration = referenceDuration else { return }
        
        let elapsed = Date().timeIntervalSince(refDate)
        let elapsedDuration = Duration.seconds(elapsed)
        
        if elapsedDuration >= refDuration {
            // Interval finished
            await handleIntervalEnd()
        } else {
            // Update remaining time
            remainingInCurrentInterval = refDuration - elapsedDuration
        }
    }
    
    @MainActor
    private func handleIntervalEnd() async {
        guard let timer = currentTimer else { return }
        
        hapticsService.intervalEnd()
        audioService.playIntervalEnd()
        
        let nextIndex = currentIntervalIndex + 1
        
        if nextIndex < timer.intervals.count {
            // Move to next interval
            currentIntervalIndex = nextIndex
            remainingInCurrentInterval = timer.intervals[nextIndex].duration
            
            // Update reference
            referenceDate = Date()
            referenceDuration = remainingInCurrentInterval
        } else if loopEnabled {
            // Complete cycle, start new one
            hapticsService.cycleEnd()
            audioService.playCycleEnd()
            
            currentIntervalIndex = 0
            remainingInCurrentInterval = timer.intervals[0].duration
            currentCycle += 1
            
            // Update reference
            referenceDate = Date()
            referenceDuration = remainingInCurrentInterval
        } else {
            // Timer finished
            hapticsService.cycleEnd()
            audioService.playCycleEnd()
            stop()
        }
    }
    
    // MARK: - Computed Properties
    var currentInterval: IntervalItem? {
        guard let timer = currentTimer,
              currentIntervalIndex >= 0,
              currentIntervalIndex < timer.intervals.count else { return nil }
        return timer.intervals[currentIntervalIndex]
    }
    
    var formattedRemainingTime: String {
        remainingInCurrentInterval.formatted(timeFormat: timeFormat)
    }
    
    var progress: Double {
        guard let interval = currentInterval else { return 0 }
        let total = interval.duration.components.seconds
        let remaining = remainingInCurrentInterval.components.seconds
        return total > 0 ? max(0, Double(total - remaining) / Double(total)) : 0
    }
    
    var totalProgress: Double {
        guard let timer = currentTimer else { return 0 }
        
        let totalIntervals = timer.intervals.count
        let completedIntervals = currentIntervalIndex
        let currentIntervalProgress = progress
        
        return Double(completedIntervals + currentIntervalProgress) / Double(totalIntervals)
    }
    
    // MARK: - Helper Methods
    private func formatDuration(_ duration: Duration) -> String {
        duration.formatted(timeFormat: timeFormat)
    }
}

// MARK: - Background State
private struct BackgroundTimerState {
    let timerID: UUID
    let intervalIndex: Int
    let remainingDuration: Duration
    let cycle: Int
    let referenceDate: Date
    let referenceDuration: Duration
}

// MARK: - Timer Calculation Function
func calculateTimerState(
    intervals: [IntervalItem],
    startingIndex: Int,
    startingCycle: Int,
    remainingInInterval: Duration,
    elapsedTime: Duration,
    loopEnabled: Bool
) -> (index: Int, remaining: Duration, cycle: Int) {
    
    guard !intervals.isEmpty, startingIndex >= 0, startingIndex < intervals.count else {
        return (-1, .zero, 1)
    }
    
    var currentIndex = startingIndex
    var currentCycle = startingCycle
    var timeLeft = elapsedTime
    
    // First, consume the remaining time in the current interval
    if timeLeft >= remainingInInterval {
        timeLeft -= remainingInInterval
        currentIndex += 1
        
        // Process complete intervals
        while timeLeft > .zero {
            // Check if we've completed all intervals in current cycle
            if currentIndex >= intervals.count {
                if loopEnabled {
                    currentCycle += 1
                    currentIndex = 0
                } else {
                    // Timer finished
                    return (-1, .zero, currentCycle)
                }
            }
            
            let intervalDuration = intervals[currentIndex].duration
            
            if timeLeft >= intervalDuration {
                // Complete this interval
                timeLeft -= intervalDuration
                currentIndex += 1
            } else {
                // Partial interval
                let remaining = intervalDuration - timeLeft
                return (currentIndex, remaining, currentCycle)
            }
        }
        
        // If we exit the loop with timeLeft == 0, we're exactly at the start of the next interval
        if currentIndex >= intervals.count {
            if loopEnabled {
                currentCycle += 1
                currentIndex = 0
            } else {
                // Timer finished
                return (-1, .zero, currentCycle)
            }
        }
        
        return (currentIndex, intervals[currentIndex].duration, currentCycle)
    } else {
        // Still in the original interval
        let remaining = remainingInInterval - timeLeft
        return (currentIndex, remaining, currentCycle)
    }
}