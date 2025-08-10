import SwiftUI
import SwiftData

@main
struct GustavTimerApp: App {
    let container: ModelContainer = {
        let schema = Schema([TimerTemplate.self, IntervalItem.self])
        return try! ModelContainer(for: schema)
    }()

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: TimerViewModel(repository: TimersRepositorySwiftData(context: container.mainContext), audio: AudioServiceProd(), haptics: HapticsServiceProd()))
                .environment(\.modelContext, container.mainContext)
        }
    }
}
