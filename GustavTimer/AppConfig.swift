//
//  AppConfig.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 09.09.2024.
//

import SwiftUI

struct AppConfig {
    
    static let version = 140
    // Maximální hodnota timeru
    static let maxTimerValue: Int = 600
    static let maxTimerCount: Int = 5
    
    // Název fontu
    static let counterFontName: String = "MartianMono-Bold"
    static let appFontName: String = "MartianMonoSemiCondensed-Regular"
    
    // Odkazy
    static let reviewURL: String = "https://apps.apple.com/app/id6478176431?action=write-review"
    static let weightsURL: String = "https://apps.apple.com/us/app/gustav-weights/id6483001116"
    
    // Barvy
    static let primaryColor: Color = Color("PrimaryColor")
    static let secondaryColor: Color = Color("SecondaryColor")
    
    // Velikosti fontů
    static let largeFontSize: CGFloat = 30
    static let smallFontSize: CGFloat = 15
    
    // Maximální název intervalu
    static let maxTimerName: Int = 12
    
    // Rozměry
}
