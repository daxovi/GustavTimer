//
//  TimerRunningView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 31.05.2025.
//

import SwiftUI
import SwiftData

struct TimerRunningView: View {
    @Environment(\.modelContext) private var context
    @StateObject var viewModel = TimerViewModel()
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Název tréninku
                if let model = viewModel.timerModel {
                    Text(model.name)
                        .font(.title)
                        .bold()
                }

                // Aktuální interval
                Text(viewModel.currentName)
                    .font(.largeTitle)
                    .foregroundColor(viewModel.currentColor)

                Text("⏱ \(viewModel.currentTimeRemaining)s")
                    .font(.system(size: 48, weight: .semibold, design: .rounded))

                // Následující interval
                if let nextName = viewModel.nextName,
                   let nextTime = viewModel.nextDuration {
                    VStack(spacing: 4) {
                        Text("Další: \(nextName)")
                            .font(.subheadline)
                        Text("\(nextTime)s")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Informace o kolech / loop
                if viewModel.isLooping {
                    Text("🔁 Nekonečný režim")
                        .font(.subheadline)
                } else {
                    Text("📦 \(viewModel.roundsRemaining) kol zbývá")
                        .font(.subheadline)
                }

                // Ovládání
                HStack(spacing: 16) {
                    Button("▶️ Start") { viewModel.start() }
                    Button("⏸ Pauza") { viewModel.pause() }
                    Button("⏭ Skip") { viewModel.skip() }
                }

                HStack(spacing: 16) {
                    Button("🔁 Reset") { viewModel.reset() }
                    Button("⏹ Stop") { viewModel.stop() }
                    Button("▶️ Resume") { viewModel.resume() }
                }
                .font(.callout)
                .foregroundColor(.gray)

                Spacer()
            }
            .padding()
            .navigationTitle("Trénink")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("✏️ Upravit") {
                        isEditing = true
                    }
                }
            }
            .navigationDestination(isPresented: $isEditing) {
                if let currentTimer = viewModel.timerModel {
                    EditView(viewModel: {
                        let vm = EditViewModel()
                        vm.loadTimer(currentTimer)
                        return vm
                    }())
                }
            }
            .onChange(of: isEditing) { wasOpen in
                if wasOpen == false {
                    viewModel.loadLastUsedTimer(from: context)
                }
            }
            .onAppear {
                viewModel.loadLastUsedTimer(from: context)
            }
        }
    }
}
