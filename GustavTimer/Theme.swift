//
//  Theme.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 02.08.2025.
//

import SwiftUI

struct Theme {
    let colors = Colors()
    let fonts = Fonts()
    let layout = Layout()
    let icons = Icons()
    let animations = Animations()
    
    struct Colors {
        let volt = Color.start
        let pink = Color.stop
        let neutral = Color.reset
        let light = Color.light
    }
    
    struct Fonts {
        let body = Font.custom("SpaceGrotesk-Regular", size: 17, relativeTo: .body)
        let buttonLabel = Font.custom("SpaceGrotesk-SemiBold", size: 20, relativeTo: .title3)
        let buttonLabelSmall = Font.custom("SpaceGrotesk-SemiBold", size: 17, relativeTo: .body)
        let buttonDescription = Font.custom("SpaceGrotesk-Regular", size: 20, relativeTo: .title3)
        let timerCounter = Font.custom("SpaceMono-Bold", size: 800)
        let headUpDisplay = Font.custom("SpaceGrotesk-Bold", size: 17, relativeTo: .headline)
        let settingsButtonBold = Font.custom("SpaceGrotesk-Bold", size: 33, relativeTo: .largeTitle)
        let settingsCaption = Font.custom("SpaceGrotesk-Regular", size: 14, relativeTo: .caption2)
        let settingsLabelLarge = Font.custom("SpaceGrotesk-SemiBold", size: 24, relativeTo: .title2)
        
        let settingsLargeTitle = Font.custom("SpaceGrotesk-Bold", size: 33, relativeTo: .title3)
        
        let settingsIntervalValue = Font.custom("SpaceMono-Bold", size: 28, relativeTo: .title2)
        let settingsIntervalName = Font.custom("SpaceGrotesk-Regular", size: 28, relativeTo: .title2)
        
        let sectionHeader = Font.custom("SpaceGrotesk-Regular", size: 17, relativeTo: .body)
        let sectionFooter = Font.custom("SpaceGrotesk-Regular", size: 17, relativeTo: .body)
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
    }
    
    struct Animations {
        let reset = "reset"
        let skip = "skip"
        
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
