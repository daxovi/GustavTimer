//
//  IntervalsTabView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 16.09.2025.
//

import SwiftUI
import SwiftData

struct IntervalsTabView: View {
    @ObservedObject var appSettings = AppSettings()

    @Query(sort: \TimerData.id, order: .reverse) var timerData: [TimerData]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    @Environment(\.theme) var theme
    @Environment(\.editMode) private var editMode
    
    @State var isEditing = false
    @State var newTimerName = ""
    @State var showSaveAlert = false
    
    private var currentTimerData: TimerData {
        getOrCreateTimerData()
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(currentTimerData.intervals) { interval in
                        IntervalRowView(intervalName: Binding(
                            get: { interval.name },
                            set: { newValue in
                                let limited = String(newValue.prefix(8))
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
                }
                
                Section {
                    NavigationLink {
                        RoundsSettingsView(rounds: $appSettings.rounds)
                    } label: {
                        ListButton(name: "ROUNDS", value: "\(appSettings.rounds == -1 ? "∞" : String(appSettings.rounds))")
                    }
                }
            }
            .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))
            .animation(.spring, value: isEditing)
            .navigationTitle("INTERVALS_TAB")
            .animation(.easeInOut, value: currentTimerData.intervals.count)
            .alert("Save Timer", isPresented: $showSaveAlert) {
                TextField("Timer Name", text: $newTimerName)
                Button("Save") {
                    saveTimer()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter a name for your timer configuration.")
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        if !isTimerAlreadySaved() {
                            showSaveAlert = true
                        }
                    } label: {
                        Image(systemName: isTimerAlreadySaved() ? "star.fill" : "star")
                    }
                }
                
                ToolbarSpacer(.fixed)
                
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
                        isEditing.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
                
                ToolbarSpacer(.fixed)
                ToolbarItem {
                    Button(role: .close) {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
    
    private func isTimerAlreadySaved() -> Bool {
        let savedTimers = timerData.filter { $0.id != 0 }
        if let mainTimer = timerData.first(where: { $0.id == 0 }) {
            return savedTimers.contains(mainTimer)
        }
        return false
    }
    
    private func getOrCreateTimerData() -> TimerData {
        if let existing = timerData.first(where: { $0.id == 0 }) {
            return existing
        } else {
            let newData = AppConfig.defaultTimer
            context.insert(newData)
            return newData
        }
    }
    
    private func saveTimer() {
        if let mainTimer = timerData.first(where: { $0.id == 0 }) {
            let newId = (timerData.map { $0.id }.max() ?? 0) + 1
            let newTimer = TimerData(id: newId, name: newTimerName, rounds: appSettings.rounds, selectedSound: appSettings.isSoundEnabled ? appSettings.selectedSound : nil, isVibrating: appSettings.isVibrating)
            newTimer.intervals = mainTimer.intervals
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
        timerData.intervals.append(IntervalData(value: 5, name: "Kolo \(timerData.intervals.count + 1)"))
    }
    
    /// Odstranění intervalů podle indexu
    private func deleteInterval(at offsets: IndexSet, from timerData: TimerData) {
        timerData.intervals.remove(atOffsets: offsets)
    }
    
    /// Přesun intervalu na novou pozici
    private func moveInterval(from source: IndexSet, to destination: Int, in timerData: TimerData) {
        timerData.intervals.move(fromOffsets: source, toOffset: destination)
    }
}
