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
                                .fill(Color("StartColor"))
                                .animation(.easeInOut, value: isSoundEnabled)
                            HStack {
                                VStack {
                                    Spacer()
                                    Text("MUTE")
                                        .font(Font.custom(AppConfig.counterFontName, size: AppConfig.smallFontSize))
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
                ForEach(AppConfig.soundThemes, id: \.self) { theme in
                    Image("\(theme)")
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        
                        .overlay {
                            ZStack {
                                LinearGradient(gradient: Gradient(colors: [.clear, .clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(style: .init(lineWidth: (selectedSound == theme && isSoundEnabled) ? 4 : 0))
                                    .fill(Color("StartColor"))
                                    .animation(.easeInOut, value: selectedSound)
                                HStack {
                                    VStack {
                                        Spacer()
                                        Text(theme)
                                            .font(Font.custom(AppConfig.counterFontName, size: AppConfig.smallFontSize))
                                            .foregroundStyle(Color.white)
                                        
                                    }
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                        .onTapGesture {
                            isSoundEnabled = true
                            selectedSound = theme
                            SoundManager.instance.playSound(sound: .final, theme: theme)
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
