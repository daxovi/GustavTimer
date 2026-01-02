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
//    let fonts = Fonts()
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
