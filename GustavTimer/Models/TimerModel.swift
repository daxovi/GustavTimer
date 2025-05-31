//
//  TimerModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 31.05.2025.
//

import SwiftUI
import SwiftData

@Model
class TimerModel {
    var id: UUID
    var name: String
    var intervals: [IntervalModel]
    var repeatCount: Int
    var isLooping: Bool
    var isFavourite: Bool

    init(id: UUID = UUID(), name: String, intervals: [IntervalModel], repeatCount: Int, isLooping: Bool, isFavourite: Bool) {
        self.id = id
        self.name = name
        self.intervals = intervals
        self.repeatCount = repeatCount
        self.isLooping = isLooping
        self.isFavourite = isFavourite
    }

    var totalDuration: Int {
        guard !isLooping else { return .max }
        return repeatCount * intervals.reduce(0) { $0 + $1.duration }
    }

    var expandedIntervals: [IntervalModel] {
        guard !isLooping else { return intervals }
        return (0..<repeatCount).flatMap { _ in intervals }
    }
}
