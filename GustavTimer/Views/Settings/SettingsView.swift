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
    
    @State private var searchText: String = ""
    
    // MARK: - Computed Properties
    private var currentTimerData: TimerData {
        getOrCreateTimerData()
    }
    
    var body: some View {
        TabView {
            Tab("INTERVALS_TAB", systemImage: "timer") {
                intervalsTab
            }
            Tab("FAVOURITES_TAB", systemImage: "star.fill") {
                FavouritesTabView()
            }
            Tab("SETTINGS_TAB", systemImage: "gearshape") {
                settingsSection
            }
            Tab("ABOUT_TAB", systemImage: "iphone.app.switcher") {
                aboutSection
            }
            Tab(role: .search) {
                NavigationStack {
                    Text("Search")
                    Text(searchText)
                }
                .searchable(text: $searchText)
            }
        }
        .tint(theme.colors.pink)
        .font(theme.fonts.body)
        .onReceive(NotificationCenter.default.publisher(for: .loadTimerData)) { notification in
            if let timerToLoad = notification.object as? TimerData {
                loadTimerDataToDefault(timerToLoad)
            }
        }
    }
    
    // MARK: - Tabs
    @ViewBuilder
    private var intervalsTab: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(currentTimerData.intervals) { interval in
                        if let index = currentTimerData.intervals.firstIndex(where: { $0.id == interval.id }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("INTERVAL")
                                        .font(theme.fonts.settingsCaption)
                                        .foregroundStyle(theme.colors.light)
                                    TextField("Name", text: Binding(
                                        get: { interval.name },
                                        set: { newValue in
                                            let limited = String(newValue.prefix(8))
                                            viewModel.updateIntervalName(limited, for: interval.id, in: currentTimerData)
                                        }
                                    ))
                                    .font(theme.fonts.settingsIntervalName)
                                }
                                
                                Spacer(minLength: 50)
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("INTERVAL_VALUE")
                                        .font(theme.fonts.settingsCaption)
                                        .foregroundStyle(theme.colors.light)
                                    TextField("1-\(AppConfig.maxTimerValue)", value: Binding(
                                        get: { interval.value },
                                        set: { newValue in
                                            let clampedValue = min(max(newValue, 1), AppConfig.maxTimerValue)
                                            viewModel.updateIntervalValue(clampedValue, for: interval.id, in: currentTimerData)
                                        }
                                    ), format: .number)
                                    .keyboardType(.numberPad)
                                    .font(theme.fonts.settingsIntervalValue)
                                    .multilineTextAlignment(.trailing)
                                }
                                .frame(maxWidth: 100)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        if currentTimerData.intervals.count > 1 {
                            viewModel.deleteInterval(at: indexSet, from: currentTimerData)
                        }
                    }
                    .onMove { viewModel.moveInterval(from: $0, to: $1, in: currentTimerData) }
                }
                
                if currentTimerData.intervals.count < AppConfig.maxTimerCount {
                    Button("ADD_INTERVAL") {
                        viewModel.addInterval(to: currentTimerData)
                    }
                }
            }
            .navigationTitle("INTERVALS_TAB")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .confirm) {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    private var settingsSection: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        RoundsSettingsView(rounds: $viewModel.rounds)
                    } label: {
                        ListButton(name: "ROUNDS", value: "\(viewModel.rounds == -1 ? "∞" : String(viewModel.rounds))")
                    }
                    
                    Toggle("HAPTICS", isOn: $viewModel.isVibrating)
                        .tint(theme.colors.pink)
                    
                    NavigationLink {
                        SoundSettingsView(isSoundEnabled: $viewModel.isSoundEnabled, selectedSound: $viewModel.selectedSound)
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
                }
            }
            .navigationTitle("SETTINGS_TAB")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .confirm) {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    
                }
            }
        }
    }
    
    private var aboutSection: some View {
        NavigationStack {
            List {
                Section() {
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
            .navigationTitle("ABOUT_TAB")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .confirm) {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    
                }
            }
        }
    }
    
    // MARK: - Helper Views
    private func addButton(label: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(label)
                .font(theme.fonts.body)
                .underline()
        }
        .foregroundStyle(theme.colors.pink)
        .padding(.horizontal)
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
            let newData = AppConfig.defaultTimer
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
        
        viewModel.rounds = timerToLoad.rounds
        
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

