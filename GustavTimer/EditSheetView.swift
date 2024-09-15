//
//  EditSheetView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 01.10.2023.
//

import SwiftUI
/*
 import PhotosUI
 import SwiftData
 */

struct EditSheetView: View {
    @StateObject var viewModel = GustavViewModel.shared
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationStack {
                List {
                    TabView {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue)
                            .overlay {
                                VStack {
                                    Text("Meditace")
                                    Spacer()
                                    Text("zvukový tón po 5 minutách")
                                    Spacer()
                                }
                                .padding()
                            }
                            .onTapGesture {
                                viewModel.setBG(index: 9)
                                viewModel.timers =  [TimerData(value: 300, name: "Meditace")]
                                viewModel.saveSettings()
                            }
                            .buttonStyle(PlainButtonStyle())
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.red)
                    }
                    .tabViewStyle(.page)
                 //   .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .frame(height: 200)
                    Section("INTERVALS", content: {
                        LapsView(viewModel: viewModel)
                        if !viewModel.isTimerFull {
                            Button(action: viewModel.addTimer, label: {
                                Text("ADD_INTERVAL")
                                    .foregroundStyle(Color("ResetColor"))
                            })
                        }
                    })
                    
                    Section("TIMER_SETTINGS") {
                        Toggle("LOOP", isOn: $viewModel.isLooping)
                            .tint(Color("StartColor"))
                        NavigationLink {
                            SoundSelectorView(viewModel: viewModel)
                        } label: {
                            HStack {
                                Text("Sound")
                                Spacer()
                                Text("\(viewModel.isSoundOn ? viewModel.activeSoundTheme : "none")")
                                    .foregroundStyle(Color(Color("ResetColor")))
                            }
                        }
                        NavigationLink {
                            BGSelectorView(viewModel: viewModel)
                        } label: {
                            Text("BACKGROUND")
                        }
                    }
                    
                    Section("ABOUT") {
                        rateButton
                    }
                }
                .navigationTitle("EDIT_TITLE")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarButtons }
            }
            .tint(Color("StopColor"))
            .font(Font.custom(AppConfig.appFontName, size: 15))
            
        }
    }
    
    var rateButton: some View {
        Button("RATE") {
            let url = AppConfig.reviewURL
            guard let writeReviewURL = URL(string: url)
            else { fatalError("Expected a valid URL") }
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: soundThemes
    var soundThemes: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.soundThemeArray, id: \.self) { theme in
                    Text(theme.uppercased())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(content: {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(viewModel.activeSoundTheme == theme ? Color("StartColor") : Color.gray.opacity(0.2))
                        })
                        .fixedSize(horizontal: true, vertical: false)
                        .onTapGesture {
                            viewModel.activeSoundTheme = theme
                            SoundManager.instance.playSound(sound: .final, theme: theme)
                        }
                }
            }
        }
    }
    
    var toolbarButtons: some View {
        Button(action: viewModel.saveSettings) {
            Text("SAVE")
        }
        .foregroundStyle(Color("StopColor"))
    }
}


