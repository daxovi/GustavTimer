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
    @State private var scrollPosition: CGFloat = 500.0
    @State private var showVideo = false
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    @Environment(\.theme) var theme
    
    private var intervals: [IntervalData] {
        timerData.first(where: { $0.id == 0 })?.intervals ?? []
    }
    
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
                        
                        Section {
                            ForEach(intervals) { interval in
                                intervalRow(for: interval)
                            }
                            .onDelete(perform: deleteInterval)
                            .onMove(perform: moveInterval)

                            if intervals.count < 5 {
                                buttonAddInterval
                            }
                        } header: {
                            HStack {
                                Text("INTERVALS")
                                Spacer()
                                EditButton()
                            }
                        }
                        
                        Section("TIMER_SETTINGS") {
                            Toggle("LOOP", isOn: $viewModel.isLooping)
                                .tint(Color("StartColor"))
                            
                            Toggle("HAPTICS", isOn: $viewModel.isVibrating)
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
                .font(theme.fonts.body)
            }
        }
        .onAppear {
            viewModel.setModelContext(context)
        }
    }
    
    private func deleteInterval(at offsets: IndexSet) {
        let timerData = getOrCreateTimerData()
        
        for index in offsets {
            let intervalToDelete = intervals[index]
            timerData.intervals.removeAll { $0.id == intervalToDelete.id }
        }
    }
    
    private func moveInterval(from source: IndexSet, to destination: Int) {
        let timerData = getOrCreateTimerData()
        var mutableIntervals = timerData.intervals
        mutableIntervals.move(fromOffsets: source, toOffset: destination)
        timerData.intervals = mutableIntervals
    }
    
    var buttonAddInterval: some View {
        Button(action: addInterval, label: {
            Text("ADD_INTERVAL")
                .foregroundStyle(Color("ResetColor"))
        })
    }
    
    private func intervalRow(for interval: IntervalData) -> some View {
        HStack {
            TextField("Name", text: Binding(
                get: { interval.name },
                set: { newValue in
                    let timerData = getOrCreateTimerData()
                    if let index = timerData.intervals.firstIndex(where: { $0.id == interval.id }) {
                        timerData.intervals[index].name = newValue
                    }
                }
            ))
            
            Spacer()
            
            TextField("Interval", value: Binding(
                get: { interval.value },
                set: { newValue in
                    let timerData = getOrCreateTimerData()
                    if let index = timerData.intervals.firstIndex(where: { $0.id == interval.id }) {
                        timerData.intervals[index].value = newValue
                    }
                }
            ), format: .number)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
        }
    }
    
    private func addInterval() {
        let timerData = getOrCreateTimerData()
        timerData.intervals.append(IntervalData(value: 5, name: "Lap \(intervals.count + 1)"))
    }
        
    private func getOrCreateTimerData() -> TimerData {
        if let existing = timerData.first(where: { $0.id == 0 }) {
            return existing
        } else {
            let newData = TimerData(id: 0)
            context.insert(newData)
            return newData
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
            .modelContainer(for: [CustomImageModel.self, TimerData.self])
    }
}
