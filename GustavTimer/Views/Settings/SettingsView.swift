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
    @Query(sort: \TimerData.id, order: .reverse) var timerData: [TimerData]
    @StateObject var viewModel = SettingsViewModel()
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    @Environment(\.theme) var theme
    
    // MARK: - Computed Properties
    private var currentTimerData: TimerData {
        getOrCreateTimerData()
    }
    
    var body: some View {
        ZStack {
            
            NavigationStack {
                List {
                    intervalsSection
                    timerSettingsSection
                    favouritesSection
                    aboutSection
                }
                .listSectionSpacing(.compact)
                .navigationTitle("EDIT_TITLE")
                .navigationBarTitleDisplayMode(.inline)
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
    
    @ViewBuilder
    private var intervalsSection: some View {
        Section {
            ForEach(currentTimerData.intervals) { interval in
                intervalRow(for: interval)
            }
            .onDelete { indexSet in
                if currentTimerData.intervals.count > 1 {
                    viewModel.deleteInterval(at: indexSet, from: currentTimerData)
                }
            }
            .onMove { viewModel.moveInterval(from: $0, to: $1, in: currentTimerData) }
        } header: {
                Text("INTERVALS")
                    .font(theme.fonts.body)
        }
        
        if currentTimerData.intervals.count < 5 {
            addIntervalButton
        }
    }
    
    @ViewBuilder
    private var favouritesSection: some View {
        let savedTimers = timerData.filter { $0.id != 0 }
        Section("FAVOURITE_INTERVALS") {
            Button(action: viewModel.saveTimerData) {
                Text("ADD_TIMER_TO_FAVOURITES")
                    .frame(maxWidth: .infinity)
                    .font(theme.fonts.buttonLabelSmall)
                    .foregroundStyle(theme.colors.neutral)
            }
            .listRowBackground(theme.colors.volt)
        }
        if !savedTimers.isEmpty {
            ForEach(savedTimers) { timer in
                FavouritesItemView(timer: timer, isSelected: .init(get: {
                    viewModel.areTimersEqual(timer, currentTimerData)
                }, set: { _ in
                    // No action needed on set
                }), onDelete: {
                    viewModel.deleteTimerData(timer)
                }, onSelect: {
                    viewModel.loadTimerData(timer)
                })
            }
        } else {
            FavouritesEmptyView()
        }
        
    }
    
    private var timerSettingsSection: some View {
        Section {
            Toggle("LOOP", isOn: $viewModel.isLooping)
                .tint(Color("StartColor"))
            
            Toggle("HAPTICS", isOn: $viewModel.isVibrating)
                .tint(Color("StartColor"))
            
            NavigationLink {
                SoundSelectorView(isSoundEnabled: $viewModel.isSoundEnabled, selectedSound: $viewModel.selectedSound)
            } label: {
                ListButton(name: "Sound", value: "\(viewModel.isSoundEnabled ? viewModel.selectedSound : "MUTE")")
            }
            
            //            NavigationLink {
            //                TimeDisplayFormatView()
            //            } label: {
            //                ListButton(name: "Time Format", value: viewModel.timeDisplayFormat.displayName)
            //            }
            //
            //            NavigationLink {
            //                BackgroundSelectorView()
            //            } label: {
            //                ListButton(name: "BACKGROUND")
            //            }
        } header: {
            Text("TIMER_SETTINGS")
                .font(theme.fonts.body)
        } footer: { Color.clear }
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
        Button {
            viewModel.addInterval(to: currentTimerData)
        } label: {
            Text("ADD_INTERVAL")
                .font(theme.fonts.buttonLabelSmall)
                .frame(maxWidth: .infinity, minHeight: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .inset(by: 1)
                        .stroke(theme.colors.light, style: StrokeStyle(lineWidth: 2, dash: [8, 8]))
                    
                )
        }
        .foregroundStyle(theme.colors.light)
        .padding(.bottom, 18)
        .listRowBackground(Color.clear)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
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
            let newData = TimerData(id: 0, name: "Default Timer", isLooping: true, selectedSound: nil, isVibrating: false)
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
        
        viewModel.isLooping = timerToLoad.isLooping
        
        viewModel.isVibrating = timerToLoad.isVibrating
        
        if let selectedSound = timerToLoad.selectedSound {
            viewModel.selectedSound = selectedSound
            viewModel.isSoundEnabled = true
        } else {
            viewModel.isSoundEnabled = false
        }
                    
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

//#Preview {
//    @Previewable @Environment(\.theme) var theme
//    List {
//        Section("FAVOURITE_INTERVALS") {
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: -16) {
//                    ForEach(0..<4) { index in
//                        VStack(alignment: .leading) {
//                            Text("timer.name")
//                                .padding(.bottom, 2)
//
//                            ForEach(0..<6) { index in
//                                Text("Rest: 30 s")
//                                    .font(theme.fonts.settingsCaption)
//                            }
//
//
//                        }
//                        .frame(width: 150, height: 100, alignment: .topLeading)
//                        .padding(8)
//                        .background(Color.white)
//                        .overlay(alignment: .bottomLeading) {
//                            LinearGradient(colors: [.white.opacity(0), .white.opacity(0.8), .white], startPoint: .center, endPoint: .bottom)
//                        }
//                        .overlay(alignment: .bottomTrailing) {
//                            Button(action: { }) {
//                                Image(systemName: "trash")
//                                    .padding(4)
//                                    .background(Color.red)
//                                    .clipShape(RoundedRectangle(cornerRadius: 5))
//                                    .padding(8)
//
//                            }
//                        }
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
//                        .padding()
//                    }
//                }
//                .padding(.leading, 8)
//            }
//            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
//        }
//    }
//}
