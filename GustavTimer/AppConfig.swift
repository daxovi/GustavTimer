//
//  AppConfig.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 09.09.2024.
//

import SwiftUI

struct AppConfig {
    // Maximální hodnota timeru
    static let maxTimerValue: Int = 600
    static let maxTimerCount: Int = 5
    
    // Název fontu
    static let counterFontName: String = "MartianMono-Bold"
    static let appFontName: String = "MartianMonoSemiCondensed-Regular"
    
    // Odkazy
    static let reviewURL: String = "https://apps.apple.com/app/id6478176431?action=write-review"
    
    // Barvy
    static let primaryColor: Color = Color("PrimaryColor")
    static let secondaryColor: Color = Color("SecondaryColor")
    
    // Velikosti fontů
    static let largeFontSize: CGFloat = 30
    static let smallFontSize: CGFloat = 15
}
