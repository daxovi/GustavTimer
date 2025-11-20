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
                challenge
                savedTimers
                mainTimer
            }
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar { toolbar }
            .environment(\.editMode, $editMode)
        .saveTimerAlert(isPresented: $showSaveAlert, timerName: $newTimerName, onSave: saveTimer)
        .alreadySavedAlert(isPresented: $showAlreadySavedAlert)
    }
    
    @ViewBuilder
    var challenge: some View {
        Image(.wallsit)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .listRowInsets(.all, 0)
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
        }
        .animation(.spring, value: editMode)
    }
    
    @ViewBuilder
    private var mainTimer: some View {
        let savedTimers = timerData.filter { $0.order != 0 }
        if let mainTimer = timerData.first(where: { $0.order == 0 }), !savedTimers.contains(mainTimer) {
            VStack(alignment: .leading, spacing: 0) {
                FavouriteRowView(timer: mainTimer, selected: false)
                Button("ADD_TO_FAVOURITES") {
                    showSaveAlert.toggle()
                }
                .font(theme.fonts.settingsCaption)
                .foregroundStyle(.white)
                .padding(4)
                .padding(.horizontal, 10)
                .glassEffect(.regular.tint(theme.colors.pink).interactive())
                .padding(.bottom)
                .padding(.horizontal)
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .largeTitle) {
            HStack {
                Text("FAVOURITES_TAB")
                    .font(theme.fonts.settingsLargeTitle)
                Spacer()
            }
            .padding(.vertical)
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
            Button {
                editMode = (editMode == .active ? .inactive : .active)
            } label: {
                Image(systemName: "slider.horizontal.3")
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

