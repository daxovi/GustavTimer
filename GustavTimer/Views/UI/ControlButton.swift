//
//  ControlButton.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 14.09.2024.
//

import SwiftUI

struct ControlButton: View {
    let action: () -> ()
    var label: LocalizedStringKey? = nil
    var icon: Image? = nil
    var description: LocalizedStringKey? = nil
    let color: Color
    
    @Environment(\.theme) var theme
    
    var body: some View {
        Button(action: action, label: {
            color
                .overlay( (icon != nil) ? AnyView(iconView) : AnyView(labelView) )
                .overlay( buttonBorder )
                .frame(height: theme.layout.controlHeight)
                .clipShape(RoundedRectangle(cornerRadius: theme.layout.buttonRadius))
        })
    }
    
    @ViewBuilder
    private var labelView: some View {
        if let label {
            HStack{
                Text(label)
                    .foregroundStyle(color == .start ? .reset : .start)
                    .font(theme.fonts.buttonLabel)
                    .textCase(.uppercase)
                if let description {
                    Text(description)
                        .foregroundStyle(color == .start ? .reset : .white)
                        .font(theme.fonts.buttonDescription)
                        .textCase(.uppercase)
                        .opacity(0.5)
                }
            }
        }
    }
    
    @ViewBuilder
    private var iconView: some View {
        if let icon {
            icon
                .scaledToFit()
                .frame(height: 40)
                .foregroundStyle(color == .start ? .reset : .start)
        }
    }
    
    private var buttonBorder: some View {
        RoundedRectangle(cornerRadius: theme.layout.buttonRadius)
            .inset(by: 1)
            .stroke(
                LinearGradient(colors: [.white.opacity(1), .white.opacity(0), .white.opacity(1)], startPoint: .top, endPoint: .bottom),
                lineWidth: 3)
            .opacity(0.15)
    }
}

#Preview {
    VStack {
        Spacer()
        ControlButton(action: {}, label: "start", description: "30 s", color: .stop)
            .padding()
    ControlButton(action: {}, label: "start", color: .start)
            .padding()

        Spacer()
    }
    .background(.gray)
}
