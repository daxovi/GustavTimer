//
//  SoundModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 12.11.2025.
//

import Foundation
import SwiftUI

enum SoundModel: String, Codable, CaseIterable, Equatable {
    case beep
    case squeeze
    case whistle
    case hey
    case game
    case retro
    case bicycle
    case gong
    case bell
    case bubble
    
    var fileName: String {
            return self.rawValue
    }
    
    var title: LocalizedStringKey {
        switch self {
        case .beep:
            return "BEEP"
        case .squeeze:
            return "RUBBER_DUCK"
        case .whistle:
            return "WHISTLE"
        case .hey:
            return "HEY"
        case .game:
            return "GAME"
        case .retro:
            return "RETRO"
        case .bicycle:
            return "BICYCLE"
        case .gong:
            return "GONG"
        case .bell:
            return "BELL"
        case .bubble:
            return "BUBBLE"
        }
    }
    
    var id: String {
        return fileName
    }
}
