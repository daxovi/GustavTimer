//
//  ControlButton.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 14.09.2024.
//

import SwiftUI

struct ControlButton: View {
    let action: () -> ()
    let label: LocalizedStringKey
    var description: LocalizedStringKey? = nil
    let color: Color
    
    var body: some View {
        Button(action: action, label: {
            color
                .overlay {
                    HStack{
                        Text(label)
                            .foregroundStyle(color == .start ? .reset : .start)
                            .font(Font.custom("SpaceGrotesk-SemiBold", size: 20))
                            .textCase(.uppercase)
                        if let description {
                            Text(description)
                                .foregroundStyle(color == .start ? .reset : .white)
                                .font(Font.custom("SpaceGrotesk-Regular", size: 20))
                                .textCase(.uppercase)
                                .opacity(0.5)
                        }
                    }

                }
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .inset(by: 1)
                        .stroke(
                            LinearGradient(colors: [.white.opacity(1), .white.opacity(0), .white.opacity(1)], startPoint: .top, endPoint: .bottom),
                            lineWidth: 3)
                        .opacity(0.15)
                )
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 40))

        })
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
