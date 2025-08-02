//
//  ControlButton.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 14.09.2024.
//

import SwiftUI
import RiveRuntime

struct ControlButton: View {
    let action: () -> ()
    var label: LocalizedStringKey? = nil
    var riveAnimation: String?
    var description: LocalizedStringKey? = nil
    let color: Color
    @StateObject private var riveViewModel: RiveViewModel

    @Environment(\.theme) var theme
    
    init(action: @escaping () -> (), label: LocalizedStringKey? = nil, riveAnimation: String? = nil, description: LocalizedStringKey? = nil, color: Color = .start) {
        self.action = action
        self.label = label
        self.riveAnimation = riveAnimation
        self.description = description
        self.color = color
        self._riveViewModel = StateObject(wrappedValue: RiveViewModel(fileName: riveAnimation ?? "reset"))
    }

    var body: some View {
        Button(action: {
            riveViewModel.play(loop: .oneShot)
            riveViewModel.reset()
            action()
        }, label: {
            color
                .overlay( (riveAnimation != nil) ? AnyView(animationView) : AnyView(labelView) )
                .overlay( buttonBorder )
                .frame(height: theme.layout.controlHeight)
                .clipShape(RoundedRectangle(cornerRadius: theme.layout.buttonRadius))
        })
        .buttonStyle(.plain)
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
    private var animationView: some View {
        if (riveAnimation != nil) {
            riveViewModel.view()
                .padding(30)
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
        ControlButton(action: {}, label: "start", riveAnimation: "reset", color: .reset)
            .padding()

        Spacer()
    }
    .background(.gray)
}
