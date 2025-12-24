//
//  ControlButton.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 14.09.2024.
//

import SwiftUI
import RiveRuntime
import Lottie

struct ControlButton: View {
    let action: () -> ()
    var label: LocalizedStringKey? = nil
    var riveAnimation: String?
    var description: LocalizedStringKey? = nil
    let color: Color
    @StateObject private var riveViewModel: RiveViewModel
    @State var lottieAnimation = LottiePlaybackMode.paused(at: .frame(0))
    @Binding var buttonType: ButtonType

    @Environment(\.theme) var theme
    
    init(action: @escaping () -> (), label: LocalizedStringKey? = nil, riveAnimation: String? = nil, description: LocalizedStringKey? = nil, color: Color = .start, buttonType: Binding<ButtonType>) {
        self.action = action
        self.label = label
        self.riveAnimation = riveAnimation
        self.description = description
        self.color = color
        self._riveViewModel = StateObject(wrappedValue: RiveViewModel(fileName: riveAnimation ?? "reset"))
        self._buttonType = buttonType
    }

    var body: some View {
        Button(action: {
            playLottieAnimation()
            action()
        }, label: {
                if riveAnimation != nil {
                    if #available(iOS 26.0, *) {
                        Color.clear
                            .frame(height: theme.layout.controlHeight)
                            .glassEffect(.regular.tint(color).interactive())
                            .overlay(
                                theme.lottie.resetSkip
                                    .playbackMode(lottieAnimation)
                                    .animationDidFinish { _ in
                                        lottieAnimation = .paused
                                    }
                                    .padding(24)
                            )
                            .contentShape(Rectangle())
                            .onAppear {
                                lottieAnimation = .playing(.fromFrame(240, toFrame: 299, loopMode: .playOnce))
                            }
                    } else {
                        // Fallback on earlier versions
                        Color.clear
                            .frame(height: theme.layout.controlHeight)
                            .background(color)
                            .overlay(
                                theme.lottie.resetSkip
                                    .playbackMode(lottieAnimation)
                                    .animationDidFinish { _ in
                                        lottieAnimation = .paused
                                    }
                                    .padding(24)
                            )
                            .contentShape(Rectangle())
                            .onAppear {
                                lottieAnimation = .playing(.fromFrame(240, toFrame: 299, loopMode: .playOnce))
                            }
                            .clipShape(Capsule())
                            .contentShape(Rectangle())
                    }
                } else {
                    if #available(iOS 26.0, *) {
                        HStack {
                            Text(label ?? "")
                                .font(theme.fonts.buttonLabel)
                                .foregroundStyle(color == .start ? .reset : .start)
                            Text(description ?? "")
                                .font(theme.fonts.buttonDescription)
                                .foregroundStyle(color == .start ? .reset : .white)
                                .textCase(.uppercase)
                                .opacity(0.5)
                        }
                        .frame(height: theme.layout.controlHeight)
                        .frame(maxWidth: .infinity)
                        .glassEffect(.regular.tint(color).interactive())
                        .contentShape(Rectangle())
                    } else {
                        // Fallback on earlier versions
                        HStack {
                            Text(label ?? "")
                                .font(theme.fonts.buttonLabel)
                                .foregroundStyle(color == .start ? .reset : .start)
                            Text(description ?? "")
                                .font(theme.fonts.buttonDescription)
                                .foregroundStyle(color == .start ? .reset : .white)
                                .textCase(.uppercase)
                                .opacity(0.5)
                        }
                        .frame(height: theme.layout.controlHeight)
                        .frame(maxWidth: .infinity)
                        .background(color)
                        .clipShape(Capsule())
                        .contentShape(Rectangle())
                    }
                }
        })
        .buttonStyle(.plain)
        .onChange(of: buttonType) {
            buttonTypeChanged()
        }
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
    
    private func playLottieAnimation() {
        lottieAnimation = .paused
        switch buttonType {
        case .text:
            return
        case .skip:
            lottieAnimation = .playing(.fromFrame(120, toFrame: 180, loopMode: .playOnce))
        case .reset:
            lottieAnimation = .playing(.fromFrame(0, toFrame: 60, loopMode: .playOnce))
        }
    }
    
    private func buttonTypeChanged() {
        lottieAnimation = .paused
        switch buttonType {
        case .text:
            return
        case .skip:
            lottieAnimation = .playing(.fromFrame(60, toFrame: 120, loopMode: .playOnce))
        case .reset:
            lottieAnimation = .playing(.fromFrame(180, toFrame: 239, loopMode: .playOnce))
        }
    }
    
    enum ButtonType {
        case text, skip, reset
    }
}

//#Preview {
//    VStack {
//        Spacer()
//        ControlButton(action: {}, label: "start", description: "30 s", color: .stop)
//            .padding()
//        ControlButton(action: {}, label: "start", riveAnimation: "reset", color: .reset)
//            .padding()
//
//        Spacer()
//    }
//    .background(.gray)
//}
