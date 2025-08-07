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
    
    // MARK: - Computed Properties
    private var currentTimerData: TimerData {
        getOrCreateTimerData()
    }
    
    private var monthlyVideoName: String {
        let index = max(0, min(viewModel.actualMonth - 1, MonthlyConfig.videoName.count - 1))
        return MonthlyConfig.videoName[index]
    }
    
    private var monthlyBannerName: ImageResource {
        let index = max(0, min(viewModel.actualMonth - 1, MonthlyConfig.bannerImageResource.count - 1))
        return MonthlyConfig.bannerImageResource[index]
    }
    
    var body: some View {
        ZStack {
            if showVideo {
                VideoPlayerFullscreen(
                    videoURL: Bundle.main.url(forResource: monthlyVideoName, withExtension: "mp4")!,
                    onHalfway: viewModel.incrementMonthlyCounter
                )
                .onDisappear { showVideo = false }
            }
            
            NavigationStack {
                List {
                    monthlySection
                    intervalsSection
                    savedTimersSection
                    timerSettingsSection
                    aboutSection
                }
                .navigationTitle("EDIT_TITLE")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { saveButton }
                .background(backgroundView)
                .scrollContentBackground(.hidden)
            }
            .tint(Color("StopColor"))
            .font(theme.fonts.body)
            .alert("Save Timer", isPresented: $viewModel.showSaveAlert) {
                TextField("Timer Name", text: $viewModel.newTimerName)
                Button("Save") {
                    viewModel.performSaveTimerData(context: context, defaultTimer: currentTimerData)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter a name for your timer configuration")
            }
            .alert("Delete Timer", isPresented: $viewModel.showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    viewModel.performDeleteTimerData(context: context, defaultTimer: currentTimerData)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                if let timer = viewModel.timerToDelete {
                    Text("Are you sure you want to delete '\(timer.name)'?")
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .loadTimerData)) { notification in
                if let timerToLoad = notification.object as? TimerData {
                    loadTimerDataToDefault(timerToLoad)
                }
            }
        }
    }
    
    // MARK: - Sections
    private var monthlySection: some View {
        MonthlyMenuItem(
            showVideo: $showVideo,
            monthlyActionText: viewModel.getChallengeText(),
            monthlyCounter: $viewModel.monthlyCounter
        )
        .background(scrollPositionReader)
    }
    
    @ViewBuilder
    private var intervalsSection: some View {
        Section {
            ForEach(currentTimerData.intervals) { interval in
                intervalRow(for: interval)
            }
            .onDelete { viewModel.deleteInterval(at: $0, from: currentTimerData) }
            .onMove { viewModel.moveInterval(from: $0, to: $1, in: currentTimerData) }

            if currentTimerData.intervals.count < 5 {
                addIntervalButton
            }
            
        } header: {
            HStack {
                Text("INTERVALS")
                Spacer()
                EditButton()
            }
        }
        
        Button(action: viewModel.saveTimerData) {
            Text("SAVE_TIMER")
        }
        .foregroundStyle(.white)
        .listRowBackground(Color.red)
    }
    
    @ViewBuilder
    private var savedTimersSection: some View {
        let savedTimers = timerData.filter { $0.id != 0 }
        if !savedTimers.isEmpty {
            Section("SAVED_INTERVALS") {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(savedTimers) { timer in
                            VStack {
                                Text(timer.name)
                                
                                ForEach(timer.intervals) { interval in
                                    Text("\(interval.name): \(interval.value) s")
                                }
                                
                                Button(action: { viewModel.deleteTimerData(timer) }) {
                                    Image(systemName: "trash")
                                }
                            }
                            .frame(width: 150, height: 100)
                            .onTapGesture {
                                viewModel.loadTimerData(timer)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var timerSettingsSection: some View {
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
    }
    
    private var aboutSection: some View {
        Section("ABOUT") {
            Button("RATE") {
                if let url = URL(string: AppConfig.reviewURL) {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("Try Gustav Weights") {
                if let url = URL(string: AppConfig.weightsURL) {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("Follow Gustav on Instagram") {
                if let url = URL(string: "https://www.instagram.com/gustavtraining") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    // MARK: - Helper Views
    private var addIntervalButton: some View {
        Button("ADD_INTERVAL") {
            viewModel.addInterval(to: currentTimerData)
        }
        .foregroundStyle(Color("ResetColor"))
    }
    
    private func intervalRow(for interval: IntervalData) -> some View {
        HStack {
            TextField("Name", text: Binding(
                get: { interval.name },
                set: { viewModel.updateIntervalName($0, for: interval.id, in: currentTimerData) }
            ))
            
            Spacer()
            
            TextField("Interval", value: Binding(
                get: { interval.value },
                set: { viewModel.updateIntervalValue($0, for: interval.id, in: currentTimerData) }
            ), format: .number)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
        }
    }
    
    private var scrollPositionReader: some View {
        GeometryReader { geometry in
            Color.clear
                .onChange(of: geometry.frame(in: .global).minY) { _, newValue in
                    scrollPosition = newValue
                }
        }
    }
    
    private var backgroundView: some View {
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
    }
    
    private var saveButton: some View {
        Button("SAVE") {
            dismiss()
        }
        .foregroundStyle(Color("StopColor"))
    }
    
    // MARK: - Helper Methods
    private func getOrCreateTimerData() -> TimerData {
        if let existing = timerData.first(where: { $0.id == 0 }) {
            return existing
        } else {
            let newData = TimerData(id: 0, name: "Default Timer")
            context.insert(newData)
            return newData
        }
    }
    
    private func loadTimerDataToDefault(_ timerToLoad: TimerData) {
        let defaultTimer = currentTimerData
        
        // Copy intervals from the selected timer to default timer
        defaultTimer.intervals = timerToLoad.intervals.map { interval in
            IntervalData(value: interval.value, name: interval.name)
        }
        defaultTimer.isLoop = timerToLoad.isLoop
        
        do {
            try context.save()
        } catch {
            print("Error loading timer data: \(error)")
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [CustomImageModel.self, TimerData.self])
}
