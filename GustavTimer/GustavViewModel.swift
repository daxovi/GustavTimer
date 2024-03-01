//
//  GustavViewModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 19.04.2023.
//

import Foundation
import Combine
import SwiftUI
import AVFoundation

class GustavViewModel: ObservableObject {
    let maxTimers = 5
    let progressBarHeight = 5
    let buttonHeight = 80.0
    let bgImages: [BGImageModel] = [
        BGImageModel(image: "Benchpress", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Boxer", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Ground", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Lanes", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Poster", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Pullup", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Rope", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Squat", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Stone", author: "", source: "www.unsplash.com"),
        BGImageModel(image: "Weights", author: "", source: "www.unsplash.com")
    ]
    var isTimerFull: Bool {return !(timers.count < maxTimers)}
    
    @Published var count: Int = 0
    @Published var showingSheet = false
    @Published var timers: [Int] { didSet {
        UserDefaults.standard.setValue(timers, forKey: "timers")
    }}
    @Published var recentTimers: [[Int]] { didSet {
        UserDefaults.standard.setValue(recentTimers, forKey: "recent-timers")
    }}
    @Published var isTimerRunning = false
    @Published var progress: Double = 0.0
    @AppStorage("isLooping") var isLooping: Bool = true
    @AppStorage("isSoundOn") var isSoundOn = true
    @Published var editMode = EditMode.inactive
    @AppStorage("bgIndex") var bgIndex = 0

    var activeTimerIndex: Int = 0
    var timer: AnyCancellable?
    
    static let shared = GustavViewModel()
    
    init() {
        UIApplication.shared.isIdleTimerDisabled = false
        let savedTimers = UserDefaults.standard.array(forKey: "timers") as? [Int]
        self.timers = savedTimers ?? [20, 5]
        
        let savedRecentTimers = UserDefaults.standard.array(forKey: "recent-timers") as? [[Int]]
        self.recentTimers = savedRecentTimers ?? [[30, 5], [60], [60, 5, 30, 5], [300, 10], [60, 30]]
        self.count = timers[0]
    }
    
    private func countProgressRatio(timerIndex: Int) -> Double {
        let sum = Double(timers.reduce(0, +))
        if timers.count > timerIndex {
            return Double(timers[timerIndex])/sum
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
    }
    
    func startTimer() {
        UIApplication.shared.isIdleTimerDisabled = true
        isTimerRunning = true
        timer = Timer
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.count -= 1
                self?.switchTimer()
                self?.progress = (Double(self?.timers[self?.activeTimerIndex ?? 0] ?? 0) - Double(self?.count ?? 0)) / Double(self?.timers[self?.activeTimerIndex ?? 0] ?? 0)
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
        if self.count <= 0 && isTimerRunning {
            playSound()
            activeTimerIndex += 1
            if activeTimerIndex >= timers.count {
                activeTimerIndex = 0
                if !isLooping {
                    stopTimer()
                }
            }
            self.count = timers[activeTimerIndex]
            if self.count <= 0 {
                switchTimer()
            }
        }
    }
    
    func resetTimer() {
        timer = nil
        self.activeTimerIndex = 0
        self.progress = 0.0
        self.isTimerRunning = false
        self.count = timers[0]
    }
    
    func setCount(count newCount: String) {
        if let number = Int(newCount) {
            if self.timers[0] != number {
                self.timers[0] = number
                self.count = self.timers[0]
            }
        } else {
            print("DEBUG: \(newCount) není číslo")
        }
    }
    
    func addTimer() {
        if !isTimerFull {
            timers.append(5)
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
    }
    
    func skipLap() {
        self.count = 0
    }
    
    func setBG(index: Int) {
        self.bgIndex = index
    }
    
    func playSound() {
        if isSoundOn {
            let systemSoundID: SystemSoundID = 1304 // 1016
            AudioServicesPlaySystemSound(systemSoundID)
        }
    }
    
    func saveSettings() {
        if let index = recentTimers.firstIndex(where: { $0 == timers }) {
            recentTimers.remove(at: index)
        } else {
            recentTimers.remove(at: recentTimers.count - 1)
        }
        recentTimers.insert(timers, at: 0)
        resetTimer()
        toggleSheet()
    }
    
    func getImage() -> Image {
            if bgImages.indices.contains(bgIndex) {
                return bgImages[bgIndex].getImage()
            } else {
                return bgImages[0].getImage()
            }
        }
}
