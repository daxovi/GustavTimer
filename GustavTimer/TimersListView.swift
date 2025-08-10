import SwiftUI

struct TimersListView: View {
    @Binding var selected: TimerTemplate?
    @State private var timers: [TimerTemplate] = []
    @Environment(\.modelContext) private var context
    var viewModel: TimerViewModel
    private var repository: TimersRepository { TimersRepositorySwiftData(context: context) }

    var body: some View {
        List {
            if !favorites.isEmpty {
                Section("Favorites") {
                    ForEach(favorites) { timerRow($0) }
                }
            }
            Section("All") {
                ForEach(timers) { timerRow($0) }
                    .onDelete { indexSet in
                        for index in indexSet { repository.deleteTimer(timers[index]) }
                        load()
                    }
            }
        }
        .navigationTitle("Timers")
        .toolbar { Button("Add") { addTimer() } }
        .onAppear(perform: load)
    }

    private func timerRow(_ timer: TimerTemplate) -> some View {
        HStack {
            Text(timer.name)
            Spacer()
            Button("Start") { selected = timer }
        }
    }

    private var favorites: [TimerTemplate] { timers.filter { $0.isFavorite } }

    private func load() { timers = repository.fetchAll() }

    private func addTimer() {
        let interval = IntervalItem(title: "Interval", duration: .seconds(30), order: 0)
        _ = repository.createTimer(name: "New Timer", intervals: [interval], isFavorite: false)
        load()
    }
}
