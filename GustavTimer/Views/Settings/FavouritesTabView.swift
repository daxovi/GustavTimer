//
//  FavouritesTabView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 16.09.2025.
//

import SwiftUI
import SwiftData

struct FavouritesTabView: View {
    
    @Query(sort: \TimerData.id, order: .reverse) var timerData: [TimerData]
    @Environment(\.modelContext) var context
    @Environment(\.theme) var theme
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var appSettings = AppSettings()
    
    @State var showSaveAlert: Bool = false
    @State var newTimerName: String = ""
    @State var showDeleteAlert: Bool = false
    @State var timerToDelete: TimerData?
    @State var isEditing: Bool = false
    @State var showAlreadySavedAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                let savedTimers = timerData.filter { $0.id != 0 }
                Section {
                    if !savedTimers.isEmpty {
                        ForEach(savedTimers) { timer in
                            FavouriteRowView(timer: timer)
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
                        .onMove(perform: { indices, newOffset in
                                var s = timerData.sorted(by: { $0.id < $1.id })
                                s.move(fromOffsets: indices, toOffset: newOffset)
                                for (index, item) in s.enumerated() {
                                        item.id = index
                                }
                                try? self.context.save()
                         })
                    } else {
                        FavouritesEmptyView()
                    }
                }
                if let mainTimer = timerData.first(where: { $0.id == 0 }), !savedTimers.contains(mainTimer) {
                    VStack(alignment: .leading, spacing: 0) {
                        FavouriteRowView(timer: mainTimer)
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
            .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))
            .animation(.spring, value: isEditing)
            .navigationTitle("FAVOURITES_TAB")
            .toolbar {
                ToolbarItem {
                    Button {
                        let savedTimers = timerData.filter { $0.id != 0 }
                        if let mainTimer = timerData.first(where: { $0.id == 0 }), !savedTimers.contains(mainTimer) {
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
                        isEditing.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
                
                ToolbarSpacer(.fixed)
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .close) {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .alert("Save Timer", isPresented: $showSaveAlert) {
            TextField("Timer Name", text: $newTimerName)
            Button("Save") {
                saveTimer()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter a name for your timer configuration.")
        }
        .alert("Delete Timer", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteTimer()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            if let timer = timerToDelete {
                Text("Are you sure you want to delete '\(timer.name)'?")
            }
        }
        .alert("Already Saved", isPresented: $showAlreadySavedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This timer configuration is already saved in your favourites.")
        }
    }
    
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
    
    private func deleteTimer() {
        if let timerToDelete = timerToDelete {
            context.delete(timerToDelete)
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
    
    private func selectTimer(timer: TimerData) {
        if let mainTimer = timerData.first(where: { $0.id == 0 }) {
            mainTimer.name = timer.name
            mainTimer.intervals = timer.intervals
            appSettings.save(from: timer)
        }
    }
}
