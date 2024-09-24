//
//  SoundView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 05.09.2024.
//

import SwiftUI

struct SoundSelectorView: View {
    
    var soundThemeArray = ["sound1", "sound2", "sound3", "sound4", "sound5"]
    @StateObject var viewModel = GustavViewModel.shared
    
    private let flexibleNarrowColumn = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
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
                                .stroke(style: .init(lineWidth: (!viewModel.isSoundOn) ? 4 : 0))
                                .fill(Color("StartColor"))
                                .animation(.easeInOut, value: viewModel.isSoundOn)
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
                        viewModel.isSoundOn = false
                    }
                ForEach(viewModel.soundThemeArray, id: \.self) { theme in
                    Image("\(theme)")
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        
                        .overlay {
                            ZStack {
                                LinearGradient(gradient: Gradient(colors: [.clear, .clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(style: .init(lineWidth: (viewModel.activeSoundTheme == theme && viewModel.isSoundOn) ? 4 : 0))
                                    .fill(Color("StartColor"))
                                    .animation(.easeInOut, value: viewModel.activeSoundTheme)
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
                            viewModel.isSoundOn = true
                            viewModel.activeSoundTheme = theme
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
