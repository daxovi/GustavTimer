//
//  FavouritesView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 10.11.2025.
//

import SwiftUI
import SwiftData

struct FavouritesView: View {
    
    @Query(sort: \TimerData.order, order: .reverse) var timerData: [TimerData]
    @Environment(\.modelContext) var context
    @Environment(\.theme) var theme
    
    @ObservedObject var appSettings = AppSettings()
    
    @State var showSaveAlert: Bool = false
    @State var newTimerName: String = ""
    @State var showDeleteAlert: Bool = false
    @State var timerToDelete: TimerData?
    @State var showAlreadySavedAlert: Bool = false
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        List {
            savedTimers
            preloadedTimers
//            mainTimer
        }
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar { toolbar }
        .environment(\.editMode, $editMode)
        .saveTimerAlert(isPresented: $showSaveAlert, timerName: $newTimerName, onSave: saveTimer)
        .alreadySavedAlert(isPresented: $showAlreadySavedAlert)
    }
    
    @ViewBuilder
    private var savedTimers: some View {
        Section {
            let savedTimers = timerData.filter { $0.order != 0 }
            if !savedTimers.isEmpty {
                ForEach(savedTimers) { timer in
                    FavouriteRowView(timer: timer, selected: isTimerSelected(timer: timer))
                        .onTapGesture {
                            selectTimer(timer: timer)
                        }
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        timerToDelete = savedTimers[index]
                        deleteTimer()
                    }
                }
                .onMove(perform: moveTimer)
            } else {
                FavouritesEmptyView()
            }
        } header: {
            Text("SAVED_TIMERS").font(theme.fonts.sectionHeader)
        }
        .animation(.spring, value: editMode)
    }
    
    @ViewBuilder
    private var preloadedTimers: some View {
        Section {
            let preloadedTimers = AppConfig.predefinedTimers
                ForEach(preloadedTimers) { timer in
                    FavouriteRowView(timer: timer, selected: isTimerSelected(timer: timer))
                        .onTapGesture {
                            selectTimer(timer: timer)
                        }
                }
        } header: {
            Text("PRELOADED_TIMERS").font(theme.fonts.sectionHeader)
        }
        .animation(.spring, value: editMode)
    }
    
    @ViewBuilder
    private var mainTimer: some View {
        let savedTimers = timerData.filter { $0.order != 0 }
        if let mainTimer = timerData.first(where: { $0.order == 0 }), !savedTimers.contains(mainTimer) {
            VStack(alignment: .center, spacing: 16) {
                
                var timersText: String {
                    var text = ""
                    for (index, interval) in mainTimer.intervals.enumerated() {
                        if index != 0 {
                            text += ", "
                        }
                        text += "\(interval.name): \(interval.value)"
                    }
                    return text
                }
                
                Text(timersText)
                    .font(theme.fonts.settingsCaption)
                    .foregroundStyle(theme.colors.neutral)
                addFavouriteButton
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    private var addFavouriteButton: some View {
        if #available(iOS 26.0, *) {
            Button("SAVE_YOUR_FIRST_TIMER") {
                showSaveAlert.toggle()
            }
            .font(theme.fonts.settingsCaption)
            .foregroundStyle(.white)
            .padding(4)
            .padding(.horizontal, 10)
            .glassEffect(.regular.tint(theme.colors.pink).interactive())
        } else {
            // Fallback on earlier versions
            Button("SAVE_YOUR_FIRST_TIMER") {
                showSaveAlert.toggle()
            }
            .font(theme.fonts.settingsCaption)
            .foregroundStyle(.white)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        if #available(iOS 26, *){
            ToolbarItem(placement: .title) {
                HStack {
                    Text("FAVOURITES_TAB")
                        .font(theme.fonts.settingsNavbarTitle)
                }
                .padding(.vertical)
            }
        } else {
            // Fallback to earlier versions
            ToolbarItem(placement: .title) {
                HStack {
                    Text("FAVOURITES_TAB")
                        .font(theme.fonts.settingsNavbarTitle)
                }
                .padding(.vertical)
            }
        }
        
        ToolbarItem {
            Button {
                let savedTimers = timerData.filter { $0.order != 0 }
                if let mainTimer = timerData.first(where: { $0.order == 0 }), !savedTimers.contains(mainTimer) {
                    showSaveAlert.toggle()
                } else {
                    showAlreadySavedAlert.toggle()
                }
            } label: {
                Image(systemName: "plus")
            }
        }
        
        ToolbarItem {
            if timerData.count > 2 {
                Button {
                    editMode = (editMode == .active ? .inactive : .active)
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
    }
    
    private func moveTimer(from indices: IndexSet, to newOffset: Int) {
        // Získáme pouze uložené časovače (bez hlavního časovače)
        let savedTimers = timerData.filter { $0.order != 0 }
        
        // Vytvoříme kopii časovačů, se kterou můžeme pracovat
        var movedTimers = savedTimers
        
        // Provedeme přesun v naší kopii
        movedTimers.move(fromOffsets: indices, toOffset: newOffset)
        
        // Přiřadíme nová ID pro zachování pořadí
        // Začínáme od 1, protože 0 je rezervováno pro hlavní časovač
        for i in 0..<movedTimers.count {
            let timer = movedTimers[i]
            // Nastavíme nové ID, které určuje pořadí (vyšší ID = novější časovač)
            timer.order = movedTimers.count - i
        }
        
        // Uložíme změny do databáze
        try? context.save()
    }
    
    private func deleteTimer() {
        if let timerToDelete = timerToDelete {
            context.delete(timerToDelete)
        }
    }
    
    private func saveTimer() {
        if let mainTimer = timerData.first(where: { $0.order == 0 }) {
            let newId = (timerData.map { $0.order }.max() ?? 0) + 1
            let newTimer = TimerData(order: newId, name: newTimerName, rounds: appSettings.rounds, isVibrating: appSettings.isVibrating)
            newTimer.intervals = mainTimer.intervals
            newTimer.selectedSound = mainTimer.selectedSound
            context.insert(newTimer)
        }
    }
    
    private func selectTimer(timer: TimerData) {
        if let mainTimer = timerData.first(where: { $0.order == 0 }) {
            mainTimer.name = timer.name
            mainTimer.intervals = timer.intervals
            mainTimer.selectedSound = timer.selectedSound
            mainTimer.isVibrating = timer.isVibrating
            appSettings.save(from: timer)
        }
    }
    
    private func isTimerSelected(timer: TimerData) -> Bool {
        if let mainTimer = timerData.first(where: { $0.order == 0 }) {
            return mainTimer == timer
        }
        return false
    }
}

#Preview {
    List {
        FavouritesEmptyView()
        FavouriteRowView(timer: {
            let timer = AppConfig.defaultTimer
            timer.order = 11
            timer.intervals = [
                IntervalData(value: 30, name: "Work"),
                IntervalData(value: 15, name: "Rest")
            ]
            return timer
        }(), selected: false)
    }
}
