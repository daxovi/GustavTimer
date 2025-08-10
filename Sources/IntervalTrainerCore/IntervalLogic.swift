import Foundation

public struct IntervalLogic {
    public static func state(for durations: [Duration], loopEnabled: Bool, elapsed: Duration) -> (index: Int, remaining: Duration, cycle: Int) {
        precondition(!durations.isEmpty, "At least one interval required")
        let cycleDuration = durations.reduce(.zero, +)
        var effectiveElapsed = elapsed
        var cycle = 1
        if loopEnabled && cycleDuration > .zero {
            while effectiveElapsed >= cycleDuration {
                effectiveElapsed -= cycleDuration
                cycle += 1
            }
        } else {
            effectiveElapsed = min(effectiveElapsed, cycleDuration)
        }

        var accumulated: Duration = .zero
        for (index, d) in durations.enumerated() {
            let nextAccum = accumulated + d
            if effectiveElapsed < nextAccum || index == durations.count - 1 {
                let remaining = nextAccum - effectiveElapsed
                return (index, remaining, cycle)
            }
            accumulated = nextAccum
        }
        return (durations.count - 1, .zero, cycle)
    }
}
