//
//  IntervalData.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 09.09.2024.
//

import Foundation

struct IntervalData: Identifiable, Codable, Equatable {
    var id: UUID = UUID() // Unikátní identifikátor
    var value: Int // Zachováváme pro zpětnou kompatibilitu
    var name: String
    
    // Nová property pro práci s Duration
    var duration: Duration {
        get {
            return .seconds(Double(value))
        }
        set {
            value = Int(newValue.components.seconds)
        }
    }
    
    init(value: Int, name: String) {
        self.value = value
        self.name = name
    }
    
    // Nový initializer pro Duration
    init(duration: Duration, name: String) {
        self.value = Int(duration.components.seconds)
        self.name = name
    }
    
    static func == (lhs: IntervalData, rhs: IntervalData) -> Bool {
        return lhs.value == rhs.value && lhs.name == rhs.name
    }
}
