//
//  SettingsSheet.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 10.11.2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @StateObject private var appSettings = AppSettings()

    @Query(sort: \TimerData.id, order: .reverse) private var timerData: [TimerData]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.theme) private var theme
    
    @State private var editMode: EditMode = .inactive
    @State private var newTimerName = ""
    @State private var showSaveAlert = false
    @State private var showAlreadySavedAlert = false
    @State private var selectedSoundTitle: String? = nil
    
    private var currentTimerData: TimerData {
        getOrCreateTimerData()
    }
    
    var body: some View {
        NavigationStack {
            List {
                challenge
                intervalsView
                roundsView
                favourites
                appearance
                more
                about
            }
            .environment(\.editMode, $editMode)
            .saveTimerAlert(isPresented: $showSaveAlert, timerName: $newTimerName, onSave: saveTimer)
            .alreadySavedAlert(isPresented: $showAlreadySavedAlert)
            .toolbar { toolbar }
            .font(theme.fonts.body)
        }
        .tint(.navigationItems)
    }
    
    @ViewBuilder
    var challenge: some View {
        SettingsSection(label: "CHALLENGE") {
            Image(.wallsit)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .overlay(alignment: .bottomLeading) {
                    Image(.youtubeLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 18)
                        .padding()
                }
                .onTapGesture {
                    if let url = URL(string: AppConfig.youtubeChallengeURL) {
                        UIApplication.shared.open(url)
                    }
                }
        }
    }
    
    @ViewBuilder
    var intervalsView: some View {
        Section {
            ForEach(currentTimerData.intervals) { interval in
                IntervalRowView(intervalName: Binding(
                    get: { interval.name },
                    set: { newValue in
                        let limited = String(newValue.prefix(AppConfig.maxTimerName))
                        updateIntervalName(limited, for: interval.id, in: currentTimerData)
                    }
                ), intervalValue: Binding(
                    get: { interval.value },
                    set: { newValue in
                        let clampedValue = min(max(newValue, 1), AppConfig.maxTimerValue)
                        updateIntervalValue(clampedValue, for: interval.id, in: currentTimerData)
                    }
                ))
            }
            .onDelete { indexSet in
                if currentTimerData.intervals.count > 1 {
                    deleteInterval(at: indexSet, from: currentTimerData)
                }
            }
            .onMove { moveInterval(from: $0, to: $1, in: currentTimerData) }
        } header: {
            Text("INTERVALS_TAB").font(theme.fonts.sectionHeader)
        } footer: {
            if currentTimerData.intervals.count < AppConfig.maxTimerCount {
                HStack {
                    Image(systemName: "plus")
                    Text("ADD_INTERVAL")
                }
                .font(theme.fonts.sectionFooter)
                .onTapGesture {
                    addInterval(to: currentTimerData)
                }
            }
        }
    }
    
    var roundsView: some View {
        Section {
            NavigationLink {
                RoundsSettingsView(rounds: $appSettings.rounds)
            } label: {
                ListButton(name: "ROUNDS", value: "\(appSettings.rounds == -1 ? "LOOP" : String(appSettings.rounds))")
            }
        }
    }
    
    @ViewBuilder
    private var favourites: some View {
        SettingsSection(label: "FAVOURITES") {
            NavigationLink {
                FavouritesView()
            } label: {
                Text("FAVOURITES")
            }
        }
    }
    
    @ViewBuilder
    private var appearance: some View {
        SettingsSection(label: "APPEARANCE") {
            Toggle("HAPTICS", isOn: $appSettings.isVibrating)
                .tint(theme.colors.pink)
            
            NavigationLink {
                SoundSettingsView(selectedSound: .init(get: {
                    return currentTimerData.selectedSound ?? nil
                }, set: { sound in
                    let timer = currentTimerData
                    timer.selectedSound = sound
                    if let soundValue = sound {
                        selectedSoundTitle = NSLocalizedString("\(soundValue.title)", comment: "")
                    } else {
                        selectedSoundTitle = nil
                    }
                    context.insert(timer)
                    try? context.save()
                }))
            } label: {
                ListButton(name: "SOUND", value: currentTimerData.selectedSound?.title ?? "MUTE")
            }
            
            NavigationLink {
                BackgroundSelectorView()
            } label: {
                ListButton(name: "BACKGROUND")
            }
        }
    }
    
    @ViewBuilder
    private var more: some View {
        SettingsSection(label: "MORE") {
            ButtonLink(label: "RATE", URLString: AppConfig.reviewURL)
            
            ButtonLink(label: "TRY_WEIGHTS", URLString: AppConfig.weightsURL)
            
            ButtonLink(label: "FOLLOW_INSTAGRAM", URLString: AppConfig.instagramURL)
            
            ButtonLink(label: "WATCH_ON_YOUTUBE", URLString: AppConfig.youtubeURL)
        }
    }
    
    @ViewBuilder
    private var about: some View {
        NavigationLink {
            Text("About")
        } label: {
            Text("ABOUT_GUSTAV")
        }
    }
    
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        
        ToolbarItem(placement: .navigationBarLeading) {
            if #available(iOS 26.0, *) {
                Button(role: .close) {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            } else {
                // Fallback on earlier versions
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }

        ToolbarItem {
            Button {
                if !isTimerAlreadySaved() {
                    showSaveAlert = true
                } else {
                    showAlreadySavedAlert = true
                }
            } label: {
                Image(systemName: isTimerAlreadySaved() ? "star.fill" : "star")
            }
        }
        
        if #available(iOS 26.0, *) {
            ToolbarSpacer(.fixed)
        }
        
        if currentTimerData.intervals.count < AppConfig.maxTimerCount {
            ToolbarItem {
                Button {
                    addInterval(to: currentTimerData)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        
        ToolbarItem {
            Button {
                editMode = (editMode == .active ? .inactive : .active)
            } label: {
                Image(systemName: "slider.horizontal.3")
            }
        }
    }
    
    private func isTimerAlreadySaved() -> Bool {
        let savedTimers = timerData.filter { $0.order != 0 }
        if let mainTimer = timerData.first(where: { $0.order == 0 }) {
            return savedTimers.contains(mainTimer)
        }
        return false
    }
    
    private func getOrCreateTimerData() -> TimerData {
        if let existing = timerData.first(where: { $0.order == 0 }) {
            return existing
        } else {
            let newData = AppConfig.defaultTimer
            context.insert(newData)
            return newData
        }
    }
    
    private func saveTimer() {
        if let mainTimer = timerData.first(where: { $0.order == 0 }) {
            let newOrder = (timerData.map { $0.order }.max() ?? 0) + 1
            let newTimer = TimerData(order: newOrder, name: newTimerName, rounds: appSettings.rounds, isVibrating: appSettings.isVibrating)
            newTimer.intervals = mainTimer.intervals
            newTimer.selectedSound = mainTimer.selectedSound
            context.insert(newTimer)
        }
    }
    
    private func updateIntervalName(_ name: String, for intervalId: UUID, in timerData: TimerData) {
        if let index = timerData.intervals.firstIndex(where: { $0.id == intervalId }) {
            timerData.intervals[index].name = name
        }
    }
    
    private func updateIntervalValue(_ value: Int, for intervalId: UUID, in timerData: TimerData) {
        if let index = timerData.intervals.firstIndex(where: { $0.id == intervalId }) {
            timerData.intervals[index].value = value
        }
    }
    
    private func addInterval(to timerData: TimerData) {
        guard timerData.intervals.count < AppConfig.maxTimerCount else { return }
        withAnimation(.easeInOut) {
            timerData.intervals.append(IntervalData(value: 5, name: "Kolo \(timerData.intervals.count + 1)"))
        }
    }
    
    /// Odstranění intervalů podle indexu
    private func deleteInterval(at offsets: IndexSet, from timerData: TimerData) {
        withAnimation(.easeInOut) {
            timerData.intervals.remove(atOffsets: offsets)
        }
    }
    
    /// Přesun intervalu na novou pozici
    private func moveInterval(from source: IndexSet, to destination: Int, in timerData: TimerData) {
        withAnimation(.easeInOut) {
            timerData.intervals.move(fromOffsets: source, toOffset: destination)
        }
    }
}

private struct ButtonLink: View {
    let label: LocalizedStringKey
    let URLString: String
    
    var body: some View {
        Button(label) {
            if let url = URL(string: URLString) {
                UIApplication.shared.open(url)
            }
        }
        .foregroundStyle(.stop)
    }
}

#Preview("Light") {
    SettingsView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    SettingsView()
        .preferredColorScheme(.dark)
}
