//
//  ControlButton.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 14.09.2024.
//

import SwiftUI

struct ControlButton: View {
    var action: () -> ()
    var text: LocalizedStringKey
    var color: Color
    
    var body: some View {
        Button(action: action, label: {
            color
                .overlay {
                    Text(text)
                        .foregroundStyle(color == .start ? .reset : .start)
                        .font(Font.custom("MartianMono-Regular", size: 16))
                        .textCase(.uppercase)

                }
                .frame(height: 100)
        })
    }
}
