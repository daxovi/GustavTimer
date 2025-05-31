//
//  IntervalModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 31.05.2025.
//

import SwiftUI

struct IntervalModel: Identifiable, Hashable, Equatable, Codable {
    var id: UUID
    var name: String
    var duration: Int
    var colorHex: String
    var type: IntervalType

    var color: Color {
        get { Color(hex: colorHex) }
        set { colorHex = newValue.toHex() }
    }

    init(id: UUID = UUID(), name: String, duration: Int, color: Color, type: IntervalType) {
        self.id = id
        self.name = name
        self.duration = duration
        self.colorHex = color.toHex()
        self.type = type
    }
}

enum IntervalType: String, Codable, CaseIterable {
    case warmup, work, rest, cooldown, custom
}
