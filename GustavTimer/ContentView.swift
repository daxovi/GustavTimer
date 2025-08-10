//
//  ContentView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 19.04.2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var timerViewModel: TimerViewModel?
    
    var body: some View {
        Group {
            if let viewModel = timerViewModel {
                HomeView(timerViewModel: viewModel)
            } else {
                ProgressView("Setting up...")
            }
        }
        .onAppear {
            setupDependencies()
        }
    }
    
    private func setupDependencies() {
        // Setup repository
        let repository = TimersRepositorySwiftData(modelContext: modelContext)
        
        // Seed sample data if empty (for development/demo purposes)
        SampleDataSeeder.seedSampleData(repository: repository)
        
        // Setup services
        let audioService = AudioServiceImpl()
        let hapticsService = HapticsServiceImpl()
        
        // Create timer view model
        timerViewModel = TimerViewModel(
            repository: repository,
            audioService: audioService,
            hapticsService: hapticsService
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TimerTemplate.self, inMemory: true)
}
