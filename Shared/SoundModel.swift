//
//  SoundModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 12.11.2025.
//
//  Výčet dostupných zvuků pro zpětnou vazbu při přechodu mezi intervaly.
//  Obsahuje pouze Foundation logiku – žádné SwiftUI, UIKit ani AVFoundation.
//
//  Každý case odpovídá MP3 souboru v bundle aplikace:
//      .beep     → "beep.mp3"
//      .whistle  → "whistle.mp3"
//      .gong     → "gong.mp3"
//      atd.
//
//  Přehrávání zvuku je platformově specifické:
//      - iPhone:  SoundManager.instance.playSound(soundModel: .whistle)
//      - Watch:   WKInterfaceDevice.current().play(.notification)  (systémové zvuky)
//
//  Příklady použití:
//
//      // Uložení do TimerData (SwiftData persistence)
//      timerData.selectedSound = .gong
//
//      // Přenos na Watch přes WatchConnectivity (Codable)
//      let data = try JSONEncoder().encode(SoundModel.whistle)
//
//      // Iterace přes všechny zvuky (pro picker v nastavení)
//      for sound in SoundModel.allCases {
//          print(sound.fileName)  // "beep", "squeeze", ...
//      }
//
//  SwiftUI rozšíření (lokalizovaný název pro UI) je v:
//      GustavTimer/Models/SoundModel+Title.swift
//
//      sound.title  // LocalizedStringKey("WHISTLE") – jen v iOS targetu
//

import Foundation

/// Výčet zvuků pro zpětnou vazbu timeru.
/// RawValue je String odpovídající názvu MP3 souboru bez přípony.
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

    /// Název souboru zvuku bez přípony – odpovídá rawValue.
    /// Používá se v SoundManager pro načtení z Bundle:
    ///
    ///     Bundle.main.url(forResource: sound.fileName, withExtension: ".mp3")
    var fileName: String {
        return self.rawValue
    }

    /// Identifikátor pro SwiftUI ForEach – shodný s fileName.
    var id: String {
        return fileName
    }
}
