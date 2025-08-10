import SwiftUI

struct TimerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State var timer: TimerTemplate
    let repository: TimersRepository
    var onSave: (TimerTemplate) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Timer name", text: $timer.name)
                }
                Section("Intervals") {
                    ForEach($timer.intervals) { $interval in
                        HStack {
                            TextField("Title", text: $interval.title)
                            Stepper(value: Binding(
                                get: { Int(interval.duration.components.seconds) },
                                set: { interval.duration = .seconds($0) }
                            ), in: 1...600) {
                                Text(format(interval.duration))
                            }
                        }
                    }
                    .onMove { indices, newOffset in
                        timer.intervals.move(fromOffsets: indices, toOffset: newOffset)
                        for i in timer.intervals.indices { timer.intervals[i].order = i }
                    }
                    .onDelete { timer.intervals.remove(atOffsets: $0) }
                    Button("Add Interval") { addInterval() }
                        .disabled(timer.intervals.count >= 6)
                }
            }
            .navigationTitle("Timer")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.disabled(!isValid) }
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }

    private func addInterval() {
        let order = timer.intervals.count
        timer.intervals.append(IntervalItem(title: "Interval", duration: .seconds(30), order: order))
    }

    private func save() {
        timer.updatedAt = .now
        repository.updateTimer(timer)
        onSave(timer)
        dismiss()
    }

    private var isValid: Bool {
        !timer.name.trimmingCharacters(in: .whitespaces).isEmpty && timer.intervals.count >= 1 && timer.intervals.count <= 6 && timer.intervals.allSatisfy { !$0.title.isEmpty && $0.duration >= .seconds(1) && $0.duration <= .seconds(600) }
    }

    private func format(_ duration: Duration) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = duration >= .seconds(60) ? [.minute, .second] : [.second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? "0"
    }
}
