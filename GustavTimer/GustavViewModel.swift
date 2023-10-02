//
//  GustavViewModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 19.04.2023.
//

import Foundation
import Combine
import SwiftUI

class GustavViewModel: ObservableObject {
    @Published var count: Int = 0
    @Published var showingSheet = false
    @Published var timers: [Int] = [20, 5, 0]
    @Published var isTimerRunning = false
    @Published var progress: Double = 0.0

    var activeTimerIndex: Int = 0
    var timer: AnyCancellable?
    
    init() {
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
    
    func startStopTimer() {
        if timer == nil {
            isTimerRunning = true
            timer = Timer
                .publish(every: 1.0, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.switchTimer()
                    self?.count -= 1
                    self?.progress = (Double(self?.timers[self?.activeTimerIndex ?? 0] ?? 0) - Double(self?.count ?? 0)) / Double(self?.timers[self?.activeTimerIndex ?? 0] ?? 0)
                }
        } else {
            isTimerRunning = false
            timer = nil
        }
    }
    
    func switchTimer() {
        if self.count <= 0 {
            activeTimerIndex += 1
            if activeTimerIndex >= timers.count {
                activeTimerIndex = 0
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
        for index in 0..<timers.count {
            if timers[index] == 0 {
                timers.remove(at: index)
            }
        }
        timers.append(5)
        timers.append(0)
    }
    
    func removeTimer(index: Int) {
        if (index < timers.count) {
            timers.remove(at: index)
            if timers.last != 0 {
                timers.append(0)
            }
        }
    }
    
    func toggleSheet() {
        self.showingSheet.toggle()
    }
}
