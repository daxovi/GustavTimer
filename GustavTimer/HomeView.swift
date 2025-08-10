import SwiftUI

struct HomeView: View {
    @State var viewModel: TimerViewModel
    @State private var selectedTemplate: TimerTemplate?
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let template = selectedTemplate {
                    Text(template.name).font(.headline)
                    if let interval = template.intervals[safe: viewModel.currentIntervalIndex] {
                        Text(interval.title).font(.title3)
                    }
                    Text(formatted(viewModel.remaining))
                        .font(.system(size: 48).monospacedDigit())
                    if viewModel.loopEnabled {
                        Text("Cycle \(viewModel.currentCycle)")
                    }
                } else {
                    Text("No timer selected")
                }

                HStack {
                    Button(action: { toggleTimer() }) {
                        Text(buttonTitle)
                    }
                    Button("Reset") { viewModel.reset() }
                }
                HStack {
                    Button("Prev") { viewModel.prev() }
                    Button("Restart") { viewModel.restartInterval() }
                    Button("Next") { viewModel.next() }
                }

                NavigationLink("Select Timer") {
                    TimersListView(selected: $selectedTemplate, viewModel: viewModel)
                }
                NavigationLink("Settings") { SettingsView() }
            }
            .padding()
            .onChange(of: scenePhase) { viewModel.handleScenePhase($0) }
            .onChange(of: selectedTemplate) { new in
                if let t = new { viewModel.start(with: t) }
            }
        }
    }

    private var buttonTitle: String {
        switch viewModel.status {
        case .running: return "Pause"
        case .paused: return "Resume"
        case .stopped: return "Start"
        }
    }

    private func toggleTimer() {
        switch viewModel.status {
        case .running: viewModel.pause()
        case .paused: viewModel.resume()
        case .stopped:
            if let template = selectedTemplate { viewModel.start(with: template) }
        }
    }

    private func formatted(_ duration: Duration) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        if viewModel.timeFormat == "ss" {
            formatter.allowedUnits = [.second]
        } else {
            formatter.allowedUnits = [.minute, .second]
        }
        formatter.unitsStyle = .positional
        return formatter.string(from: duration) ?? "0"
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
