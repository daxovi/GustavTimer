//
//  SettingsViewModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 26.07.2025.
//

import SwiftUI
import SwiftData

extension Notification.Name {
    static let loadTimerData = Notification.Name("loadTimerData")
}

/// ViewModel pro správu nastavení - zjednodušená verze s českými komentáři
class SettingsViewModel: ObservableObject {
    
    // MARK: - Inicializace
    init() {
        //
    }

    
    // MARK: - Správa časovačů
    /// Načtení dat časovače (pomocí notifikace)
//    func loadTimerData(_ timer: TimerData) {
//        DispatchQueue.main.async {
//            // Skutečné načtení bude zpracováno view s přístupem k ModelContext
//            NotificationCenter.default.post(name: .loadTimerData, object: timer)
//        }
//    }
}
