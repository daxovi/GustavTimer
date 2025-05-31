//
//  TimerViewModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 31.05.2025.
//

import SwiftUI
import Combine
import SwiftData

@MainActor
class TimerViewModel: ObservableObject {
    // MARK: - Výstup do View
    @Published var currentName: String = ""
    @Published var currentType: IntervalType = .custom
    @Published var currentColor: Color = .gray
    @Published var currentTimeRemaining: Int = 0

    @Published var nextName: String?
    @Published var nextDuration: Int?

    @Published var isLooping: Bool = false
    @Published var roundsRemaining: Int = 0
    @Published var timerModel: TimerModel?

    // MARK: - Interní stav
    private var fullIntervals: [IntervalModel] = []
    private var currentIntervalIndex: Int = 0
    private var currentRound: Int = 1

    private var timer: Timer?
    private var isRunning = false
    private var isPaused = false

    // MARK: - Načtení timeru
    func setTimer(_ timer: TimerModel) {
        self.timerModel = timer
        self.fullIntervals = timer.expandedIntervals
        self.isLooping = timer.isLooping
        self.roundsRemaining = timer.repeatCount
        self.currentRound = 1
        self.currentIntervalIndex = 0

        Self.saveLastUsedTimerID(timer.id)
        setupInterval(at: 0)
    }

    func loadLastUsedTimer(from context: ModelContext) {
        if let lastID = Self.loadLastUsedTimerID() {
            let descriptor = FetchDescriptor<TimerModel>(
                predicate: #Predicate { $0.id == lastID }
            )

            if let lastUsed = try? context.fetch(descriptor).first {
                setTimer(lastUsed)
                return
            }
        }

        // Pokud nic není → vytvoř výchozí timer
        let defaultTimer = TimerModel(
            name: "Default Timer",
            intervals: [
                IntervalModel(name: "Workout", duration: 60, color: .red, type: .work),
                IntervalModel(name: "Rest", duration: 30, color: .blue, type: .rest)
            ],
            repeatCount: 1,
            isLooping: false,
            isFavourite: false
        )

        context.insert(defaultTimer)
        try? context.save()
        setTimer(defaultTimer)
    }

    // MARK: - Řízení času
    func start() {
        guard !isRunning else { return }
        isRunning = true
        isPaused = false
        tick()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                    self.tick()
                }
        }
    }

    func pause() {
        timer?.invalidate()
        isRunning = false
        isPaused = true
    }

    func resume() {
        guard isPaused else { return }
        isRunning = true
        isPaused = false
        tick()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                    self.tick()
                }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
    }

    func skip() {
        advanceToNextInterval()
    }

    func reset() {
        stop()
        currentRound = 1
        currentIntervalIndex = 0
        fullIntervals = timerModel?.expandedIntervals ?? []
        roundsRemaining = timerModel?.repeatCount ?? 1
        isLooping = timerModel?.isLooping ?? false
        setupInterval(at: 0)
    }

    // MARK: - Vnitřní logika

    private func tick() {
        guard currentTimeRemaining > 0 else {
            advanceToNextInterval()
            return
        }
        currentTimeRemaining -= 1
    }

    private func advanceToNextInterval() {
        currentIntervalIndex += 1

        if currentIntervalIndex >= fullIntervals.count {
            if isLooping {
                currentIntervalIndex = 0
            } else if currentRound < (timerModel?.repeatCount ?? 1) {
                currentRound += 1
                roundsRemaining = (timerModel?.repeatCount ?? 1) - currentRound + 1
                currentIntervalIndex = 0
            } else {
                stop()
                return
            }
        }

        setupInterval(at: currentIntervalIndex)
    }

    private func setupInterval(at index: Int) {
        guard fullIntervals.indices.contains(index) else { return }

        let interval = fullIntervals[index]
        currentName = interval.name
        currentType = interval.type
        currentColor = interval.color
        currentTimeRemaining = interval.duration

        if fullIntervals.indices.contains(index + 1) {
            let next = fullIntervals[index + 1]
            nextName = next.name
            nextDuration = next.duration
        } else {
            nextName = nil
            nextDuration = nil
        }
    }

    // MARK: - Last used timer ID

    private static let userDefaultsKey = "LastUsedTimerID"

    static func saveLastUsedTimerID(_ id: UUID) {
        UserDefaults.standard.set(id.uuidString, forKey: userDefaultsKey)
    }

    static func loadLastUsedTimerID() -> UUID? {
        guard let string = UserDefaults.standard.string(forKey: userDefaultsKey) else { return nil }
        return UUID(uuidString: string)
    }
}
