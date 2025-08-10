import Foundation
import Observation
import SwiftUI
import IntervalTrainerCore

@Observable
final class TimerViewModel {
    enum Status { case running, paused, stopped }

    private let repository: TimersRepository
    private let audio: AudioService
    private let haptics: HapticsService
    private let clock = ContinuousClock()
    private var clockTask: Task<Void, Never>?

    @AppStorage("loopEnabled") var loopEnabled = false
    @AppStorage("timeFormat") var timeFormat = "mm:ss"

    var status: Status = .stopped
    var template: TimerTemplate?
    var currentIntervalIndex: Int = 0
    var currentCycle: Int = 1
    var remaining: Duration = .zero
    private var referenceDate: Date?

    init(repository: TimersRepository, audio: AudioService, haptics: HapticsService) {
        self.repository = repository
        self.audio = audio
        self.haptics = haptics
    }

    // MARK: - Timer control
    func start(with template: TimerTemplate) {
        self.template = template
        currentIntervalIndex = 0
        currentCycle = 1
        remaining = template.intervals[0].duration
        status = .running
        referenceDate = .now
        runClock()
    }

    private func runClock() {
        clockTask?.cancel()
        clockTask = Task { [weak self] in
            guard let self else { return }
            for await _ in clock.timer(interval: .milliseconds(100)) {
                await MainActor.run { self.tick() }
            }
        }
    }

    private func tick() {
        guard status == .running, let ref = referenceDate, let template else { return }
        let elapsed = Duration.seconds(Date.now.timeIntervalSince(ref))
        updateState(after: elapsed)
    }

    private func updateState(after elapsed: Duration) {
        guard let template else { return }
        let durations = template.intervals.map { $0.duration }
        let state = IntervalLogic.state(for: durations, loopEnabled: loopEnabled, elapsed: durations[0] - remaining + elapsed)
        if state.cycle > currentCycle { audio.playCycleEnd(); haptics.cycleEnd() }
        if state.index != currentIntervalIndex { audio.playIntervalEnd(); haptics.intervalEnd() }
        currentCycle = state.cycle
        currentIntervalIndex = state.index
        remaining = state.remaining
        if !loopEnabled && currentCycle == 1 && currentIntervalIndex == durations.count - 1 && remaining == .zero {
            status = .stopped
            clockTask?.cancel()
        }
    }

    func pause() {
        guard status == .running else { return }
        tick()
        status = .paused
        clockTask?.cancel()
    }

    func resume() {
        guard status == .paused else { return }
        status = .running
        referenceDate = .now
        runClock()
    }

    func reset() {
        clockTask?.cancel()
        status = .stopped
        currentIntervalIndex = 0
        currentCycle = 1
        if let template { remaining = template.intervals[0].duration } else { remaining = .zero }
    }

    func next() {
        guard let template else { return }
        audio.playIntervalEnd(); haptics.intervalEnd()
        if currentIntervalIndex + 1 < template.intervals.count {
            currentIntervalIndex += 1
        } else {
            audio.playCycleEnd(); haptics.cycleEnd()
            if loopEnabled {
                currentCycle += 1
                currentIntervalIndex = 0
            } else {
                status = .stopped
                clockTask?.cancel()
            }
        }
        remaining = template.intervals[currentIntervalIndex].duration
        referenceDate = .now
    }

    func prev() {
        guard let template else { return }
        if currentIntervalIndex > 0 {
            currentIntervalIndex -= 1
        } else if loopEnabled && currentCycle > 1 {
            currentCycle -= 1
            currentIntervalIndex = template.intervals.count - 1
        }
        remaining = template.intervals[currentIntervalIndex].duration
        referenceDate = .now
    }

    func restartInterval() {
        guard let template else { return }
        remaining = template.intervals[currentIntervalIndex].duration
        referenceDate = .now
    }

    // MARK: - ScenePhase
    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .background: saveState()
        case .active: restoreState()
        default: break
        }
    }

    private struct Persisted: Codable {
        var date: Date
        var interval: Int
        var remaining: Double
        var cycle: Int
        var status: Status
    }

    private func saveState() {
        guard status == .running, let ref = referenceDate else { return }
        let toSave = Persisted(date: ref, interval: currentIntervalIndex, remaining: remaining.timeInterval, cycle: currentCycle, status: status)
        if let data = try? JSONEncoder().encode(toSave) {
            UserDefaults.standard.set(data, forKey: "timerState")
        }
    }

    private func restoreState() {
        guard let data = UserDefaults.standard.data(forKey: "timerState"), let persisted = try? JSONDecoder().decode(Persisted.self, from: data), let template else { return }
        UserDefaults.standard.removeObject(forKey: "timerState")
        let elapsed = Duration.seconds(Date.now.timeIntervalSince(persisted.date))
        currentIntervalIndex = persisted.interval
        currentCycle = persisted.cycle
        remaining = Duration.seconds(persisted.remaining)
        updateState(after: elapsed)
        if status == .running { referenceDate = .now } else { status = persisted.status }
    }
}

private extension Duration {
    var timeInterval: Double {
        Double(components.seconds) + Double(components.attoseconds) / 1_000_000_000_000_000_000
    }
}
