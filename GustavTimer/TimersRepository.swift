import Foundation

protocol TimersRepository {
    func fetchAll() -> [TimerTemplate]
    func fetchFavorites() -> [TimerTemplate]
    func createTimer(name: String, intervals: [IntervalItem], isFavorite: Bool) -> TimerTemplate
    func updateTimer(_ timer: TimerTemplate)
    func deleteTimer(_ timer: TimerTemplate)
    func duplicateTimer(_ timer: TimerTemplate) -> TimerTemplate
}
