import Foundation
import SwiftData

final class TimersRepositorySwiftData: TimersRepository {
    private let context: ModelContext
    init(context: ModelContext) { self.context = context }

    func fetchAll() -> [TimerTemplate] {
        let descriptor = FetchDescriptor<TimerTemplate>(sortBy: [SortDescriptor(\.createdAt)])
        return (try? context.fetch(descriptor)) ?? []
    }

    func fetchFavorites() -> [TimerTemplate] {
        var descriptor = FetchDescriptor<TimerTemplate>(predicate: #Predicate { $0.isFavorite })
        descriptor.sortBy = [SortDescriptor(\.createdAt)]
        return (try? context.fetch(descriptor)) ?? []
    }

    func createTimer(name: String, intervals: [IntervalItem], isFavorite: Bool) -> TimerTemplate {
        let timer = TimerTemplate(name: name, intervals: intervals, isFavorite: isFavorite)
        context.insert(timer)
        try? context.save()
        return timer
    }

    func updateTimer(_ timer: TimerTemplate) {
        timer.updatedAt = .now
        try? context.save()
    }

    func deleteTimer(_ timer: TimerTemplate) {
        context.delete(timer)
        try? context.save()
    }

    func duplicateTimer(_ timer: TimerTemplate) -> TimerTemplate {
        let copyIntervals = timer.intervals.map { IntervalItem(title: $0.title, duration: $0.duration, order: $0.order) }
        let newTimer = TimerTemplate(name: timer.name + " copy", intervals: copyIntervals, isFavorite: timer.isFavorite)
        context.insert(newTimer)
        try? context.save()
        return newTimer
    }
}
