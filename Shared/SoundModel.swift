//
//  SoundModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 12.11.2025.
//
//  Sdílený model zvuků – obsahuje pouze Foundation logiku.
//  Platform-specific rozšíření (např. LocalizedStringKey) jsou v hlavním targetu.
//

import Foundation

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

    var id: String {
        return fileName
    }
}
