//
//  SoundModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 12.11.2025.
//
//  Platform-specific rozšíření SoundModelu pro SwiftUI.
//  Základní definice enum je ve Shared/SoundModel.swift.
//

import SwiftUI

extension SoundModel {
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
}
