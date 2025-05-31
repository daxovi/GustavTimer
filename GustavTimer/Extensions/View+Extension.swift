//
//  View+Extension.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 31.05.2025.
//
import SwiftUI

struct TextStyling: ViewModifier {
    let style: TextStyle

    func body(content: Content) -> some View {
        content
            .font(.custom(style.fontWeight.value, size: style.fontSize.value))
            .foregroundColor(style.textColor.value)
    }
}

extension View {
    func textStyle(_ style: TextStyle) -> some View {
        self.modifier(TextStyling(style: style))
    }
}
