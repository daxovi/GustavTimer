//
//  TextStyle.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 31.05.2025.
//
import SwiftUI

enum TextStyle {
    case titlePrimary
    case subtitleSecondary
    case bodyPrimary
    case boldDanger

    var fontSize: FontSize {
        switch self {
        case .titlePrimary: return .title
        case .subtitleSecondary: return .subtitle
        case .bodyPrimary, .boldDanger: return .body
        }
    }

    var fontWeight: FontWeight {
        switch self {
        case .titlePrimary: return .semibold
        case .subtitleSecondary: return .medium
        case .bodyPrimary: return .regular
        case .boldDanger: return .bold
        }
    }

    var textColor: TextColor {
        switch self {
        case .titlePrimary, .bodyPrimary: return .primary
        case .subtitleSecondary: return .secondary
        case .boldDanger: return .danger
        }
    }
}

enum FontSize {
    case largeTitle, title, subtitle, body, caption

    var value: CGFloat {
        switch self {
        case .largeTitle: return 32
        case .title: return 24
        case .subtitle: return 18
        case .body: return 16
        case .caption: return 13
        }
    }
}

enum FontWeight {
    case light, regular, medium, semibold, bold, monoRegular, monoBold

    var value: String {
        switch self {
        case .light: return "SpaceGrotesk-Light"
        case .regular: return "SpaceGrotesk-Regular"
        case .medium: return "SpaceGrotesk-Medium"
        case .semibold: return "SpaceGrotesk-SemiBold"
        case .bold: return "SpaceGrotesk-Bold"
        case .monoBold: return "SpaceMono-Bold"
        case .monoRegular: return "SpaceMono-Regular"
        }
    }
}

enum TextColor {
    case primary, secondary, danger

    var value: Color {
        switch self {
        case .primary: return .start
        case .secondary: return .reset
        case .danger: return .stop
        }
    }
}
