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
                    quickTimers
                    Section("INTERVALS", content: {
                        LapsView()
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
                            ListButton(name: "Sound", value: "\(viewModel.isSoundOn ? viewModel.activeSoundTheme : "MUTE")")
                        }
                        NavigationLink {
                            BGSelectorView(viewModel: viewModel)
                        } label: {
                            ListButton(name: "BACKGROUND")
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
    
    
        
    
    var quickTimers: some View {
        TabView {
            QuickTimerBanner(action: {
                viewModel.setBG(index: 6)
                viewModel.timers =  [TimerData(value: 20, name: "tabata"), TimerData(value: 10, name: "rest")]
                viewModel.saveSettings()
            }, titleLabel: "Tabata", buttonLabel: "20/10sec", image: Image("img-tabata"))
            QuickTimerBanner(action: {
                viewModel.setBG(index: 2)
                viewModel.timers =  [TimerData(value: 60, name: "rest")]
                viewModel.saveSettings()
            }, titleLabel: "Rest", buttonLabel: "60sec", image: Image("img-rest"))
            QuickTimerBanner(action: {
                viewModel.setBG(index: 9)
                viewModel.timers =  [TimerData(value: 300, name: "meditate")]
                viewModel.saveSettings()
            }, titleLabel: "Meditate", buttonLabel: "5min", image: Image("img-meditate"))
        }
        .tabViewStyle(.page)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .frame(height: 200)
    }
    
    var rateButton: some View {
        Button("RATE") {
            let url = AppConfig.reviewURL
            guard let writeReviewURL = URL(string: url)
            else { fatalError("Expected a valid URL") }
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
    }
    
    var toolbarButtons: some View {
        Button(action: {
            viewModel.saveSettings()
            viewModel.showingSheet = false
        }) {
            Text("SAVE")
        }
        .foregroundStyle(Color("StopColor"))
    }
}


struct EditSheetView_Previews: PreviewProvider {
    static var previews: some View {
        EditSheetView()
    }
}
