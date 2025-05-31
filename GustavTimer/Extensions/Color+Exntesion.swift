//
//  Color+Exntesion.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 31.05.2025.
//
import SwiftUI

extension Color {
    func toHex() -> String {
        UIColor(self).toHex() ?? "#FFFFFF"
    }

    init(hex: String) {
        self = Color(UIColor(hex: hex) ?? .gray)
    }
}

