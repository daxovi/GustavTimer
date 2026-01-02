//
//  Theme.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 02.08.2025.
//

import SwiftUI
import Lottie

struct Theme {
//    let colors = Colors()
    let fonts = Fonts()
    let layout = Layout()
    let icons = Icons()
    let animations = Animations()
    let lottie = Lottie()
    
//    struct Colors {
//        let volt = Color.start
//        let pink = Color.stop
//        let neutral = Color.reset
//        let light = Color.light
//        let white = Color.snow
//    }
    
    struct Fonts {
        private static let bodySize = CGFloat(15)
        private static let captionSize = CGFloat(13)
        private static let timerButtonsSize: CGFloat = 20
        
        // Timer
        let buttonLabel = Font.custom("MartianGrotesk-StdMd", size: timerButtonsSize, relativeTo: .title3)
        let buttonDescription = Font.custom("MartianGrotesk-CnRg", size: timerButtonsSize, relativeTo: .title3)
        
        let timerCounter = Font.custom("MartianMono-Bold", size: 800)
        
        let headUpDisplay = Font.custom("MartianGrotesk-StdRg", size: bodySize, relativeTo: .headline)

        // Settings
        let body = Font.custom("MartianGrotesk-StdLt", size: bodySize, relativeTo: .body)
        let bodyNumber = Font.custom("MartianMono-Regular", size: bodySize, relativeTo: .body)
        
        let sectionHeader = Font.custom("MartianGrotesk-StdRg", size: captionSize, relativeTo: .body)
        let sectionFooter = Font.custom("MartianGrotesk-StdRg", size: captionSize, relativeTo: .body)
        
        let settingsNavbarTitle = Font.custom("MartianGrotesk-StdMd", size: 18, relativeTo: .body)

        // Settings: Intervals
        let settingsIntervalValue = Font.custom("MartianMono-Regular", size: 28, relativeTo: .title2)
        let settingsIntervalName = Font.custom("MartianGrotesk-StdRg", size: 28, relativeTo: .title2)
        let settingsCaption = Font.custom("MartianGrotesk-CnLt", size: captionSize, relativeTo: .caption2)

        // Favourites: Empty view
        let emptyLabel = Font.custom("MartianGrotesk-StdMd", size: 17, relativeTo: .body)
        let emptySubtitle = Font.custom("MartianGrotesk-StdRg", size: captionSize, relativeTo: .body)
        
        // Favourites: Saved Row
        let savedRowIntervalName = Font.custom("MartianGrotesk-CnLt", size: captionSize, relativeTo: .caption2)
        let savedRowTimerName = Font.custom("MartianGrotesk-StdRg", size: 24, relativeTo: .title2)
        
        // Onboarding
        let onboardingTitle = Font.custom("MartianGrotesk-StdBd", size: 24, relativeTo: .title2)
        let onboardingButtonLabel = Font.custom("MartianGrotesk-StdBd", size: bodySize, relativeTo: .body)
    }
    
    struct Layout {
        let buttonRadius = 40.0
        let controlHeight = 100.0
    }
    
    struct Icons {
        let reset = Image(.ngIconReset)
            .renderingMode(.template)
            .resizable()
        let skip = Image(.ngIconSkip)
            .renderingMode(.template)
            .resizable()
        let loop = Image(.ngIconLoop)
            .renderingMode(.template)
            .resizable()
        let vibration = Image(.ngIconVibration)
            .renderingMode(.template)
            .resizable()
        let sound = Image(.ngIconSound)
            .renderingMode(.template)
            .resizable()
    }
    
    struct Animations {
        // Rive files
        let reset = "reset"
        let skip = "skip"
    }
    
    struct Lottie {
        let loop = LottieView(animation: .named("ng-icon-loop"))
        let vibration = LottieView(animation: .named("ng-icon-vibration"))
        let sound = LottieView(animation: .named("ng-icon-sound"))
        let resetSkip = LottieView(animation: .named("ng-icon-reset-skip"))
    }
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = Theme()
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
