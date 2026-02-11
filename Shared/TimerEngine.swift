//
//  TimerEngine.swift
//  GustavTimer
//
//  Sdílená logika časovače pro iPhone i Apple Watch.
//  Neobsahuje žádné platform-specific importy (UIKit, WatchKit).
//

import Foundation
import Combine

/// Typ zpětné vazby, kterou si platforma řeší po svém
enum TimerFeedback {
    case intervalTransition  // přechod mezi intervaly (lehká vibrace)
    case roundComplete       // dokončení kola (success vibrace)
    case timerEnd            // konec celého timeru (silná vibrace)
}

/// Jádro odpočítávání – čistá logika bez UI a platform-specific API
class TimerEngine: ObservableObject {

    // MARK: - Konfigurace
    let maxTimers: Int
    let maxCountdownValue: Int

    var isTimerFull: Bool { intervals.count >= maxTimers }

    // MARK: - Publikovaný stav
    @Published private(set) var isRunning = false
    @Published private(set) var activeTimerIndex: Int = 0
    @Published private(set) var finishedRounds: Int = 0
    @Published private(set) var remainingTime: Duration = .seconds(0)
    @Published var intervals: [IntervalData] = []

    // MARK: - Nastavení
    var rounds: Int = -1 // -1 = nekonečno

    // MARK: - Callbacky pro platformu
    /// Volá se při potřebě haptické/zvukové zpětné vazby
    var onFeedback: ((TimerFeedback) -> Void)?

    /// Volá se při spuštění timeru (platforma může např. zakázat idle timer)
    var onStart: (() -> Void)?

    /// Volá se při zastavení timeru
    var onStop: (() -> Void)?

    // MARK: - Privátní
    private var timerTask: Task<Void, Never>?

    // MARK: - Vypočítané vlastnosti

    /// Aktuální zbývající čas v celých sekundách (oříznutý na délku intervalu)
    var count: Int {
        guard activeTimerIndex < intervals.count else { return 0 }
        return min(
            Int(remainingTime.components.seconds),
            Int(intervals[activeTimerIndex].duration.components.seconds)
        )
    }

    /// Pokrok aktivního intervalu (0.0 – 1.0)
    var progress: Double {
        guard activeTimerIndex < intervals.count else { return 0.0 }
        let totalDuration = intervals[activeTimerIndex].duration
        guard totalDuration > .zero else { return 0.0 }

        let totalMs = Double(totalDuration.components.seconds) * 1000 +
                      Double(totalDuration.components.attoseconds) / 1e15
        let remainingMs = Double(remainingTime.components.seconds) * 1000 +
                          Double(remainingTime.components.attoseconds) / 1e15

        guard totalMs > 0 else { return 0.0 }

        let elapsedMs = totalMs - remainingMs
        return max(0.0, min(1.0, elapsedMs / totalMs))
    }

    // MARK: - Inicializace

    init(maxTimers: Int = 10,
         maxCountdownValue: Int = 600) {
        self.maxTimers = maxTimers
        self.maxCountdownValue = maxCountdownValue
        setupDefaultIntervals()
    }

    private func setupDefaultIntervals() {
        intervals = [
            IntervalData(value: 60, name: "Work"),
            IntervalData(value: 30, name: "Rest")
        ]
        remainingTime = intervals[0].duration
    }

    // MARK: - Ovládání timeru

    func startStop() {
        isRunning ? stop() : start()
    }

    func start() {
        if finishedRounds == 0 { finishedRounds = 1 }

        if remainingTime <= .zero {
            remainingTime = intervals[activeTimerIndex].duration
        }

        isRunning = true
        onStart?()

        timerTask?.cancel()
        timerTask = Task { [weak self] in
            guard let self else { return }

            let tickInterval: Duration = .milliseconds(10)
            let clock = ContinuousClock()

            while !Task.isCancelled && self.isRunning {
                let start = clock.now

                await MainActor.run {
                    self.tick(tickInterval)
                }

                let elapsed = clock.now - start
                let sleepTime = tickInterval - elapsed
                if sleepTime > .zero {
                    try? await Task.sleep(for: sleepTime)
                }
            }
        }
    }

    func stop() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
        onStop?()
    }

    func reset() {
        stop()
        finishedRounds = 0
        activeTimerIndex = 0
        if !intervals.isEmpty {
            remainingTime = intervals[0].duration
        }
    }

    func skipCurrentInterval() {
        remainingTime = .zero
    }

    // MARK: - Správa intervalů

    func addInterval(_ interval: IntervalData? = nil) {
        guard !isTimerFull else { return }
        let newInterval = interval ?? IntervalData(
            value: 5,
            name: "Kolo \(intervals.count + 1)"
        )
        intervals.append(newInterval)
    }

    func removeInterval(at offsets: IndexSet) {
        intervals.remove(atOffsets: offsets)
    }

    func removeInterval(at index: Int) {
        guard index < intervals.count else { return }
        intervals.remove(at: index)
    }

    /// Nahraje intervaly (např. z persistence) a resetuje stav
    func loadIntervals(_ newIntervals: [IntervalData], resetState: Bool = true) {
        intervals = newIntervals
        if resetState {
            reset()
        }
    }

    // MARK: - Formátování času

    func formattedTime(from duration: Duration) -> String {
        let totalSeconds = Int(duration.components.seconds)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return minutes > 0
            ? String(format: "%d:%02d", minutes, seconds)
            : String(format: "%d", seconds)
    }

    func formattedCurrentTime(format: TimeDisplayFormat) -> String {
        switch format {
        case .seconds:
            return "\(count)"
        case .minutesSecondsHundredths:
            let components = remainingTime.components
            let minutes = Int(components.seconds) / 60
            let seconds = Int(components.seconds) % 60
            let tenths = Int(components.attoseconds / 10_000_000_000_000_000)

            if minutes > 0 {
                return String(format: "%d:%02d.%02d", minutes, seconds, tenths)
            } else {
                return String(format: "%d.%02d", seconds, tenths)
            }
        }
    }

    // MARK: - Výpočet poměrů pro progress bary

    /// Poměr délky intervalu vůči celkové délce kola (0.0 – 1.0)
    func timeRatio(for index: Int) -> Double {
        let totalDuration = intervals.reduce(0.0) {
            $0 + Double(truncating: $1.duration.components.seconds as NSNumber)
        }
        guard totalDuration > 0, index < intervals.count else { return 0 }

        let intervalDuration = Double(
            truncating: intervals[index].duration.components.seconds as NSNumber
        )
        return intervalDuration / totalDuration
    }

    // MARK: - Privátní logika

    private func tick(_ interval: Duration) {
        remainingTime -= interval

        if remainingTime <= .zero {
            switchToNextInterval()
        }
    }

    private func switchToNextInterval() {
        activeTimerIndex += 1

        if activeTimerIndex >= intervals.count {
            handleRoundCompletion()
        } else {
            onFeedback?(.intervalTransition)
            remainingTime = intervals[activeTimerIndex].duration

            // Přeskočit nulové intervaly
            if intervals[activeTimerIndex].duration <= .zero {
                switchToNextInterval()
            }
        }
    }

    private func handleRoundCompletion() {
        activeTimerIndex = 0

        if rounds == -1 || finishedRounds < rounds {
            onFeedback?(.roundComplete)
            finishedRounds += 1
            remainingTime = intervals[0].duration
        } else {
            onFeedback?(.timerEnd)
            reset()
        }
    }
}
