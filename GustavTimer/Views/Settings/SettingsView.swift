//
//  SettingsView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 01.10.2023.
//

import SwiftUI
import AVFoundation
import _AVKit_SwiftUI
import SwiftData

struct SettingsView: View {
    @Query var timerData: [TimerData]
    @StateObject var viewModel = SettingsViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var scrollPosition: CGFloat = 500.0
    @State private var showVideo = false
    @Environment(\.dismiss) private var dismiss
    
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
                            // TODO: přidat omezení na 5 timerů, další nepřidávat
                            if !timerData.isEmpty {
                                ForEach(timerData[0].intervals) { interval in
                                    HStack {
                                        Text(interval.name)
                                        Spacer()
                                        Text("\(interval.value)")
                                    }
                                }
                            }
                                Button(action: viewModel.addInterval, label: {
                                    Text("ADD_INTERVAL")
                                        .foregroundStyle(Color("ResetColor"))
                                })
                        }
                        
                        Section("TIMER_SETTINGS") {
                            Toggle("LOOP", isOn: $viewModel.isLooping)
                                .tint(Color("StartColor"))
                            
                            NavigationLink {
                                SoundSelectorView()
                            } label: {
                                ListButton(name: "Sound", value: "\(viewModel.isSoundEnabled ? viewModel.selectedSound : "MUTE")")
                            }
                            
                            NavigationLink {
                                BackgroundSelectorView()
                            } label: {
                                ListButton(name: "BACKGROUND")
                            }
                        }
                        
                        Section("ABOUT") {
                            rateButton
                            instagramButton
//                            whatsNewButton
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
    
    // TODO: implementovat WhatsNewView
//    var whatsNewButton: some View {
//        Button("What's New") {
//            viewModel.showingSheet = false
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                viewModel.showingWhatsNew = true
//            }
//        }
//    }
    
    var toolbarButtons: some View {
            Button(action: {
                // TODO: resetovat timer
                dismiss()
            }) {
                Text("SAVE")
            }
            .foregroundStyle(Color("StopColor"))
    }
}


struct EditSheetView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
