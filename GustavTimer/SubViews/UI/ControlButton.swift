//
//  ControlButton.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 14.09.2024.
//

import SwiftUI

struct ControlButton: View {
    var action: () -> ()
    var text: String
    var color: Color {
        switch text {
        case "START":
            Color("StartColor")
        case "STOP":
            Color("StopColor")
        default:
            Color("ResetColor")
        }
    }
    
    @StateObject var viewModel = GustavViewModel.shared
    
    var body: some View {
        Button(action: action, label: {
            color
                .overlay {
                    Text(text)
                        .foregroundStyle( color == Color("StartColor") ? Color("ResetColor") : Color("StartColor"))
                }
                .frame(height: 100)
        })
    }
}
