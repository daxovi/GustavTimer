//
//  SoundModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 12.11.2025.
//

import Foundation

enum SoundModel: String, Codable, CaseIterable, Equatable {
    case beep
    case nineties
    case squeeze
    
    var fileName: String {
        switch self {
        case .beep:
            return "beep"
        case .nineties:
            return "90s"
        case .squeeze:
            return "squeeze"
        }
    }
    
    var title: String {
        switch self {
        case .beep:
            return "Beep"
        case .nineties:
            return "Nineties"
        case .squeeze:
            return "RUBBER_DUCK"
        }
    }
    
    var id: String {
        return title + fileName
    }
}
