//
//  TimersRepository.swift
//  GustavTimer
//
//  Created by AI Assistant on 10.08.2024.
//

import Foundation

protocol TimersRepository {
    func fetchAll() -> [TimerTemplate]
    func fetchFavorites() -> [TimerTemplate]
    func createTimer(name: String, intervals: [IntervalItem], isFavorite: Bool) -> TimerTemplate
    func updateTimer(_ timer: TimerTemplate) -> Void
    func deleteTimer(_ timer: TimerTemplate) -> Void
    func duplicateTimer(_ timer: TimerTemplate) -> TimerTemplate
}