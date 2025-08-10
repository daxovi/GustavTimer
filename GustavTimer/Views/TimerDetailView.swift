//
//  TimerDetailView.swift
//  GustavTimer
//
//  Created by AI Assistant on 10.08.2024.
//

import SwiftUI

struct TimerDetailView: View {
    @State private var timerName: String
    @State private var intervals: [IntervalEditItem] = []
    @State private var isFavorite: Bool
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    
    private let repository: TimersRepository
    private let onSave: () -> Void
    private let existingTimer: TimerTemplate?
    
    @Environment(\.dismiss) private var dismiss
    
    init(timer: TimerTemplate? = nil, repository: TimersRepository, onSave: @escaping () -> Void) {
        self.existingTimer = timer
        self.repository = repository
        self.onSave = onSave
        
        if let timer = timer {
            self._timerName = State(initialValue: timer.name)
            self._isFavorite = State(initialValue: timer.isFavorite)
            self._intervals = State(initialValue: timer.intervals.map { interval in
                IntervalEditItem(
                    id: interval.id,
                    title: interval.title,
                    duration: interval.duration,
                    order: interval.order
                )
            })
        } else {
            self._timerName = State(initialValue: "")
            self._isFavorite = State(initialValue: false)
            self._intervals = State(initialValue: [
                IntervalEditItem(title: "Interval 1", duration: Duration.seconds(30), order: 0)
            ])
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Timer Details") {
                    TextField("Timer Name", text: $timerName)
                        .textFieldStyle(.roundedBorder)
                    
                    Toggle("Favorite", isOn: $isFavorite)
                }
                
                Section {
                    List {
                        ForEach(intervals.indices, id: \.self) { index in
                            IntervalEditRow(
                                interval: $intervals[index],
                                onDelete: {
                                    if intervals.count > 1 {
                                        intervals.remove(at: index)
                                        updateIntervalOrders()
                                    }
                                }
                            )
                        }
                        .onMove(perform: moveIntervals)
                        .onDelete(perform: deleteIntervals)
                    }
                    
                    if intervals.count < 6 {
                        Button("Add Interval") {
                            addInterval()
                        }
                    } else {
                        Text("Maximum 6 intervals allowed")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                } header: {
                    Text("Intervals (\(intervals.count)/6)")
                }
            }
            .navigationTitle(existingTimer == nil ? "New Timer" : "Edit Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTimer()
                    }
                    .disabled(!isValid)
                }
            }
            .alert("Validation Error", isPresented: $showingValidationError) {
                Button("OK") { }
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    private var isValid: Bool {
        let intervalItems = intervals.map { editItem in
            IntervalItem(
                title: editItem.title.trimmingCharacters(in: .whitespaces),
                duration: editItem.duration,
                order: editItem.order
            )
        }
        
        let validation = TimerValidation.validateTimer(
            name: timerName.trimmingCharacters(in: .whitespaces),
            intervals: intervalItems
        )
        
        return validation.isValid
    }
    
    private func addInterval() {
        guard intervals.count < 6 else { return }
        
        let newInterval = IntervalEditItem(
            title: "Interval \(intervals.count + 1)",
            duration: Duration.seconds(30),
            order: intervals.count
        )
        intervals.append(newInterval)
    }
    
    private func moveIntervals(from source: IndexSet, to destination: Int) {
        intervals.move(fromOffsets: source, toOffset: destination)
        updateIntervalOrders()
    }
    
    private func deleteIntervals(at offsets: IndexSet) {
        if intervals.count > 1 {
            intervals.remove(atOffsets: offsets)
            updateIntervalOrders()
        }
    }
    
    private func updateIntervalOrders() {
        for (index, _) in intervals.enumerated() {
            intervals[index].order = index
        }
    }
    
    private func saveTimer() {
        guard isValid else {
            showValidationError()
            return
        }
        
        let intervalItems = intervals.map { editItem in
            IntervalItem(
                title: editItem.title.trimmingCharacters(in: .whitespaces),
                duration: editItem.duration,
                order: editItem.order
            )
        }
        
        if let existingTimer = existingTimer {
            // Update existing timer
            existingTimer.name = timerName.trimmingCharacters(in: .whitespaces)
            existingTimer.intervals = intervalItems
            existingTimer.isFavorite = isFavorite
            repository.updateTimer(existingTimer)
        } else {
            // Create new timer
            let _ = repository.createTimer(
                name: timerName.trimmingCharacters(in: .whitespaces),
                intervals: intervalItems,
                isFavorite: isFavorite
            )
        }
        
        onSave()
        dismiss()
    }
    
    private func showValidationError() {
        let intervalItems = intervals.map { editItem in
            IntervalItem(
                title: editItem.title.trimmingCharacters(in: .whitespaces),
                duration: editItem.duration,
                order: editItem.order
            )
        }
        
        let validation = TimerValidation.validateTimer(
            name: timerName.trimmingCharacters(in: .whitespaces),
            intervals: intervalItems
        )
        
        validationMessage = validation.errorMessage ?? "Please check your input"
        showingValidationError = true
    }
}

struct IntervalEditRow: View {
    @Binding var interval: IntervalEditItem
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("Interval Name", text: $interval.title)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            
            DurationPicker(duration: $interval.duration)
        }
    }
}

struct DurationPicker: View {
    @Binding var duration: Duration
    
    private var minutes: Int {
        Int(duration.components.seconds) / 60
    }
    
    private var seconds: Int {
        Int(duration.components.seconds) % 60
    }
    
    var body: some View {
        HStack {
            Text("Duration:")
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Minutes picker
            Picker("Minutes", selection: Binding(
                get: { minutes },
                set: { newMinutes in
                    let totalSeconds = newMinutes * 60 + seconds
                    duration = Duration.seconds(totalSeconds)
                }
            )) {
                ForEach(0...10, id: \.self) { minute in
                    Text("\(minute)m")
                        .tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80, height: 60)
            .clipped()
            
            // Seconds picker
            Picker("Seconds", selection: Binding(
                get: { seconds },
                set: { newSeconds in
                    let totalSeconds = minutes * 60 + newSeconds
                    duration = Duration.seconds(totalSeconds)
                }
            )) {
                ForEach(0...59, id: \.self) { second in
                    Text("\(second)s")
                        .tag(second)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80, height: 60)
            .clipped()
        }
    }
}

struct IntervalEditItem {
    let id: UUID
    var title: String
    var duration: Duration
    var order: Int
    
    init(id: UUID = UUID(), title: String, duration: Duration, order: Int) {
        self.id = id
        self.title = title
        self.duration = duration
        self.order = order
    }
}