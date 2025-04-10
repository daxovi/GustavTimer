//
//  EditSheetView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 01.10.2023.
//

import SwiftUI
import AVFoundation
import _AVKit_SwiftUI
/*
 import PhotosUI
 import SwiftData
 */

struct EditSheetView: View {
    @StateObject var viewModel = GustavViewModel.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var scrollPosition: CGFloat = 500.0
    @State private var showVideo = false
    
    // Monthly
    var monthlyVideoName: String {
        if viewModel.actualMonth - 1 < MonthlyConfig.videoName.count {
            return MonthlyConfig.videoName[viewModel.actualMonth - 1]
        } else {
            return MonthlyConfig.videoName[0]
        }
    }
    
    var monthlyBannerName: ImageResource {
        if viewModel.actualMonth - 1 < MonthlyConfig.bannerImageResource.count {
            return MonthlyConfig.bannerImageResource[viewModel.actualMonth - 1]
        } else {
            return MonthlyConfig.bannerImageResource[0]
        }
    }
    
    
    var body: some View {
        ZStack {
            if showVideo {
                VideoPlayerFullscreen(videoURL: Bundle.main.url(forResource: monthlyVideoName, withExtension: "mp4")!, onHalfway: {
                    print("Video reached halfway!")
                    viewModel.incrementMonthlyCounter()
                })
                .onDisappear {showVideo = false}
            }
            VStack(spacing: 0) {
                NavigationStack {
                    List {
                        //  quickTimers
                        MonthlyMenuItem(showVideo: $showVideo, monthlyActionText: viewModel.getChallengeText(), monthlyCounter: $viewModel.monthlyCounter)
                            .background(
                                GeometryReader(content: { geometry in
                                    Color.clear
                                        .onChange(
                                            of: geometry.frame(in: .global).minY
                                        ) { oldValue, newValue in
                                            scrollPosition = newValue
                                            print("scrollposition: \(scrollPosition)")
                                        }
                                })
                            )
                        
                        Section("INTERVALS") {
                            LapsView()
                            if !viewModel.isTimerFull {
                                Button(action: viewModel.addTimer, label: {
                                    Text("ADD_INTERVAL")
                                        .foregroundStyle(Color("ResetColor"))
                                })
                            }
                        }
                        
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
                            instagramButton
                            whatsNewButton
                            weightsButton
                        }
                    }
                    .navigationTitle("EDIT_TITLE")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar { toolbarButtons }
                    .background(
                        ZStack {
                            colorScheme == .light ? Color(.secondarySystemBackground) : Color(.systemBackground)
                            
                            VStack {
                                Image(monthlyBannerName)
                                    .resizable()
                                    .padding(.horizontal, -20)
                                    .scaledToFit()
                                    .blur(radius: (380 - scrollPosition) * 0.1)
                                Spacer()
                            }
                        }
                            .ignoresSafeArea()
                    )
                    .scrollContentBackground(.hidden)
                    
                }
                .tint(Color("StopColor"))
                .font(Font.custom(AppConfig.appFontName, size: 15))
            }
        }
    }
    
    var scrollQuickTimers: some View {
        ScrollView(.horizontal) {
            HStack {
                QuickTimerBanner(action: {
                    viewModel.setBG(index: 6)
                    viewModel.timers =  [TimerData(value: 20, name: "tabata"), TimerData(value: 10, name: "rest")]
                    viewModel.saveSettings()
                }, titleLabel: "Tabata", buttonLabel: "20/10sec", image: Image("img-tabata"))
                QuickTimerBanner(action: {
                    viewModel.setBG(index: 0)
                    viewModel.timers =  [TimerData(value: 30, name: "work"), TimerData(value: 30, name: "rest")]
                    viewModel.saveSettings()
                }, titleLabel: "Work-Rest", buttonLabel: "30/30sec", image: Image("img-workrest"))
                QuickTimerBanner(action: {
                    viewModel.setBG(index: 3)
                    viewModel.timers =  [TimerData(value: 60, name: "work"), TimerData(value: 5, name: "ready")]
                    viewModel.saveSettings()
                }, titleLabel: "Fast switch", buttonLabel: "60/5sec", image: Image("img-fastswitch"))
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
            .scrollTargetLayout()
        }
        .aspectRatio(1.9, contentMode: .fill)
        .scrollTargetBehavior(.viewAligned)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
    
    var quickTimers: some View {
        TabView {
            QuickTimerBanner(action: {
                viewModel.setBG(index: 6)
                viewModel.timers =  [TimerData(value: 20, name: "tabata"), TimerData(value: 10, name: "rest")]
                viewModel.saveSettings()
            }, titleLabel: "Tabata", buttonLabel: "20/10sec", image: Image("img-tabata"))
            QuickTimerBanner(action: {
                viewModel.setBG(index: 0)
                viewModel.timers =  [TimerData(value: 30, name: "work"), TimerData(value: 30, name: "rest")]
                viewModel.saveSettings()
            }, titleLabel: "Work-Rest", buttonLabel: "30/30sec", image: Image("img-workrest"))
            QuickTimerBanner(action: {
                viewModel.setBG(index: 3)
                viewModel.timers =  [TimerData(value: 60, name: "work"), TimerData(value: 5, name: "ready")]
                viewModel.saveSettings()
            }, titleLabel: "Fast switch", buttonLabel: "60/5sec", image: Image("img-fastswitch"))
            QuickTimerBanner(action: {
                viewModel.setBG(index: 2)
                viewModel.timers =  [TimerData(value: 60, name: "rest")]
                viewModel.saveSettings()
            }, titleLabel: "Rest", buttonLabel: "60sec", image: Image("img-rest"))
            QuickTimerBanner(action: {
                viewModel.setBG(index: 9)
                viewModel.timers =  [TimerData(value: 300, name: "meditate")]
                viewModel.saveSettings()
            }, titleLabel: "Meditate", buttonLabel: "300sec", image: Image("img-meditate"))
        }
        .tabViewStyle(.page)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .aspectRatio(1.8, contentMode: .fill)
    }
    
    var rateButton: some View {
        Button("RATE") {
            let url = AppConfig.reviewURL
            guard let writeReviewURL = URL(string: url)
            else { fatalError("Expected a valid URL") }
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
    }
    var weightsButton: some View {
        Button("Try Gustav Weights") {
            let url = AppConfig.weightsURL
            guard let weightsURL = URL(string: url)
            else { fatalError("Expected a valid URL") }
            UIApplication.shared.open(weightsURL, options: [:], completionHandler: nil)
        }
    }
    
    var instagramButton: some View {
        Button("Follow Gustav on Instagram") {
            if let url = URL(string: "https://www.instagram.com/gustavtraining") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    var whatsNewButton: some View {
        Button("What's New") {
            viewModel.showingSheet = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewModel.showingWhatsNew = true
            }
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
