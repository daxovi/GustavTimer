//
//  EditViewModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 31.05.2025.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class EditViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var repeatCount: Int = 1
    @Published var isLooping: Bool = false
    @Published var intervals: [IntervalModel] = []
    
    @Published var existingTimerWithSameName: TimerModel?
    @Published var showOverwriteConfirmation = false

    @Published var savedTimers: [TimerModel] = []

    func addInterval() {
        intervals.append(IntervalModel(name: "New", duration: 30, color: .blue, type: .custom))
    }

    func removeInterval(at offsets: IndexSet) {
        intervals.remove(atOffsets: offsets)
    }

    func moveInterval(from: IndexSet, to: Int) {
        intervals.move(fromOffsets: from, toOffset: to)
    }

    func loadSavedTimers(from context: ModelContext) {
        let descriptor = FetchDescriptor<TimerModel>()
        if let timers = try? context.fetch(descriptor) {
            self.savedTimers = timers
        }
    }

    func loadTimer(_ timer: TimerModel) {
        self.name = timer.name
        self.repeatCount = timer.repeatCount
        self.isLooping = timer.isLooping
        self.intervals = timer.intervals
    }
    
    func attemptToSaveTimer(in context: ModelContext) {
        let nameToCheck = name

        let predicate = #Predicate<TimerModel> { timer in
            timer.name == nameToCheck
        }

        let descriptor = FetchDescriptor<TimerModel>(predicate: predicate)

        if let existing = try? context.fetch(descriptor).first {
            self.existingTimerWithSameName = existing
            self.showOverwriteConfirmation = true
        } else {
            saveNewTimer(to: context)
        }
    }
    
    func forceToSaveNewTimer(in context: ModelContext) {
        let nameToCheck = name

        let predicate = #Predicate<TimerModel> { timer in
            timer.name == nameToCheck
        }

        let descriptor = FetchDescriptor<TimerModel>(predicate: predicate)

        if let existing = try? context.fetch(descriptor).first {
            self.existingTimerWithSameName = existing
            overwriteExistingTimer(in: context)
        } else {
            saveNewTimer(to: context)
        }
    }
    
    private func saveNewTimer(to context: ModelContext) {
        let timer = TimerModel(
            name: name,
            intervals: intervals,
            repeatCount: repeatCount,
            isLooping: isLooping,
            isFavourite: false
        )
        context.insert(timer)
        try? context.save()
        TimerViewModel.saveLastUsedTimerID(timer.id)
    }

    func overwriteExistingTimer(in context: ModelContext) {
        guard let timer = existingTimerWithSameName else { return }
        timer.name = name
        timer.intervals = intervals
        timer.repeatCount = repeatCount
        timer.isLooping = isLooping
        timer.isFavourite = false
        try? context.save()
        TimerViewModel.saveLastUsedTimerID(timer.id)
    }

    func saveTimer(to context: ModelContext) {
        let newTimer = TimerModel(
            name: name,
            intervals: intervals,
            repeatCount: repeatCount,
            isLooping: isLooping,
            isFavourite: false
        )
        context.insert(newTimer)
        try? context.save()

        // uložíme jako aktivní
        TimerViewModel.saveLastUsedTimerID(newTimer.id)
    }

    func reset() {
        name = ""
        repeatCount = 1
        isLooping = false
        intervals = []
    }
}
