//
//  SoundView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 05.09.2024.
//

import SwiftUI

struct SoundSelectorView: View {
    
    @AppStorage("isSoundEnabled") private var isSoundEnabled: Bool = true
    @AppStorage("selectedSound") private var selectedSound: String = "beep"
    
    @Environment(\.theme) private var theme
    
    private let flexibleNarrowColumn = [
        GridItem(.adaptive(minimum: 120))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: flexibleNarrowColumn, spacing: 15) {
                Image("mute")
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    .overlay {
                        ZStack {
                            LinearGradient(gradient: Gradient(colors: [.clear, .clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(style: .init(lineWidth: (!isSoundEnabled) ? 4 : 0))
                                .fill(theme.colors.volt)
                                .animation(.easeInOut, value: isSoundEnabled)
                            HStack {
                                VStack {
                                    Spacer()
                                    Text("MUTE")
                                        .font(theme.fonts.body)
                                        .foregroundStyle(Color.white)
                                }
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .onTapGesture {
                        isSoundEnabled = false
                    }
                ForEach(AppConfig.soundThemes, id: \.self) { soundTheme in
                    Image("\(soundTheme)")
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        
                        .overlay {
                            ZStack {
                                LinearGradient(gradient: Gradient(colors: [.clear, .clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(style: .init(lineWidth: (selectedSound == soundTheme && isSoundEnabled) ? 4 : 0))
                                    .fill(theme.colors.volt)
                                    .animation(.easeInOut, value: selectedSound)
                                HStack {
                                    VStack {
                                        Spacer()
                                        Text(soundTheme)
                                            .font(theme.fonts.body)
                                            .foregroundStyle(Color.white)
                                        
                                    }
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                        .onTapGesture {
                            isSoundEnabled = true
                            selectedSound = soundTheme
                            SoundManager.instance.playSound(sound: .final, theme: soundTheme)
                        }
                }
            }
            .padding()
        }
    }
}

#Preview {
    SoundSelectorView()
}
