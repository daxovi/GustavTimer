//
//  IntervalItem.swift
//  GustavTimer
//
//  Created by AI Assistant on 10.08.2024.
//

import Foundation
import SwiftData

@Model
struct IntervalItem {
    var id: UUID
    var title: String
    var duration: Duration
    var order: Int
    
    init(title: String, duration: Duration, order: Int) {
        self.id = UUID()
        self.title = title
        self.duration = duration
        self.order = order
    }
}