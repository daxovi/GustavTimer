//
//  TimersListView.swift
//  GustavTimer
//
//  Created by AI Assistant on 10.08.2024.
//

import SwiftUI

struct TimersListView: View {
    @State private var timerViewModel: TimerViewModel
    @State private var timers: [TimerTemplate] = []
    @State private var showingDetailSheet = false
    @State private var selectedTimer: TimerTemplate?
    @Environment(\.dismiss) private var dismiss
    
    private var repository: TimersRepository {
        timerViewModel.repository
    }
    
    init(timerViewModel: TimerViewModel) {
        self._timerViewModel = State(initialValue: timerViewModel)
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Favorites Section
                let favorites = timers.filter { $0.isFavorite }
                if !favorites.isEmpty {
                    Section("Favorites") {
                        ForEach(favorites) { timer in
                            TimerRowView(timer: timer) {
                                selectTimer(timer)
                            } onStart: {
                                startTimer(timer)
                            } onDuplicate: {
                                duplicateTimer(timer)
                            } onEdit: {
                                editTimer(timer)
                            }
                        }
                        .onDelete { indexSet in
                            deleteTimers(favorites, at: indexSet)
                        }
                    }
                }
                
                // All Timers Section
                let nonFavorites = timers.filter { !$0.isFavorite }
                Section(favorites.isEmpty ? "All Timers" : "Other Timers") {
                    if nonFavorites.isEmpty && favorites.isEmpty {
                        Text("No timers created yet")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(nonFavorites) { timer in
                            TimerRowView(timer: timer) {
                                selectTimer(timer)
                            } onStart: {
                                startTimer(timer)
                            } onDuplicate: {
                                duplicateTimer(timer)
                            } onEdit: {
                                editTimer(timer)
                            }
                        }
                        .onDelete { indexSet in
                            deleteTimers(nonFavorites, at: indexSet)
                        }
                    }
                }
            }
            .navigationTitle("Timers")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Timer") {
                        createNewTimer()
                    }
                }
            }
            .onAppear {
                loadTimers()
            }
            .sheet(isPresented: $showingDetailSheet) {
                if let timer = selectedTimer {
                    TimerDetailView(timer: timer, repository: repository) {
                        loadTimers()
                    }
                } else {
                    TimerDetailView(repository: repository) {
                        loadTimers()
                    }
                }
            }
        }
    }
    
    private func loadTimers() {
        timers = repository.fetchAll()
    }
    
    private func selectTimer(_ timer: TimerTemplate) {
        timerViewModel.loadTimer(timer)
        dismiss()
    }
    
    private func startTimer(_ timer: TimerTemplate) {
        timerViewModel.loadTimer(timer)
        timerViewModel.start()
        dismiss()
    }
    
    private func createNewTimer() {
        selectedTimer = nil
        showingDetailSheet = true
    }
    
    private func editTimer(_ timer: TimerTemplate) {
        selectedTimer = timer
        showingDetailSheet = true
    }
    
    private func duplicateTimer(_ timer: TimerTemplate) {
        let _ = repository.duplicateTimer(timer)
        loadTimers()
    }
    
    private func deleteTimers(_ timerList: [TimerTemplate], at offsets: IndexSet) {
        for index in offsets {
            repository.deleteTimer(timerList[index])
        }
        loadTimers()
    }
}

struct TimerRowView: View {
    let timer: TimerTemplate
    let onSelect: () -> Void
    let onStart: () -> Void
    let onDuplicate: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(timer.name)
                        .font(.headline)
                    
                    if timer.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Text("\(timer.intervals.count) intervals")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Show first few intervals
                let intervalSummary = timer.intervals.prefix(3).map { interval in
                    let duration = formatDuration(interval.duration)
                    return "\(interval.title) (\(duration))"
                }.joined(separator: ", ")
                
                Text(intervalSummary + (timer.intervals.count > 3 ? "..." : ""))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            HStack(spacing: 10) {
                Menu {
                    Button("Select", action: onSelect)
                    Button("Edit", action: onEdit)
                    Button("Duplicate", action: onDuplicate)
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
                
                Button("Start", action: onStart)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
    
    private func formatDuration(_ duration: Duration) -> String {
        duration.shortDescription
    }
}