//
//  TimerData.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 09.09.2024.
//

import Foundation

struct TimerData: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID() // Unikátní identifikátor
    var value: Int
    var name: String
}
