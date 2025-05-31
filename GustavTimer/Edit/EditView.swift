//
//  EditView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 31.05.2025.
//

import SwiftUI
import SwiftData

struct EditView: View {
    @Environment(\.modelContext) private var context
    @StateObject var viewModel = EditViewModel()
    @State private var selectedIntervalIndex: Int?

    var body: some View {
        NavigationStack {
            Form {
                Section("Základní info") {
                    TextField("Název", text: $viewModel.name)
                    Stepper("Počet opakování: \(viewModel.repeatCount)", value: $viewModel.repeatCount, in: 1...99)
                    Toggle("Nekonečné opakování (loop)", isOn: $viewModel.isLooping)
                }

                Section("Intervaly") {
                    ForEach(Array(viewModel.intervals.enumerated()), id: \.element.id) { index, interval in
                        NavigationLink(destination: IntervalEditView(interval: Binding(
                            get: {
                                return interval
                            },
                            set: { updated in
                                    viewModel.intervals[index] = updated
                            }
                        ))) {
                            VStack(alignment: .leading) {
                                Text(interval.name)
                                    .bold()
                                Text("⏱ \(interval.duration) s, \(interval.type.rawValue)")
                            }
                            .foregroundColor(.primary)
                        }
//                        Button {
//                            selectedIntervalIndex = index
//                            
//                        } label: {
//                            VStack(alignment: .leading) {
//                                Text(interval.name)
//                                    .bold()
//                                Text("⏱ \(interval.duration) s, \(interval.type.rawValue)")
//                            }
//                            .foregroundColor(.primary)
//                        }
                    }
                    
                }

                Section("Uložené timery") {
                    if viewModel.savedTimers.isEmpty {
                        Text("Žádné uložené tréninky")
                    } else {
                        ForEach(viewModel.savedTimers) { timer in
                            Button(timer.name) {
                                viewModel.loadTimer(timer)
                            }
                        }
                    }
                }

                Section {
                    Button("💾 Uložit trénink") {
                        viewModel.attemptToSaveTimer(in: context)
                        viewModel.loadSavedTimers(from: context)
                    }

                    Button("🧹 Vymazat vše") {
                        viewModel.reset()
                    }
                }
            }
            .navigationTitle("Upravit trénink")
            .onAppear {
                viewModel.loadSavedTimers(from: context)
            }
            .onDisappear {
                viewModel.forceToSaveNewTimer(in: context)
            }
            .alert("Název již existuje", isPresented: $viewModel.showOverwriteConfirmation) {
                Button("Přepsat", role: .destructive) {
                    viewModel.overwriteExistingTimer(in: context)
                    viewModel.loadSavedTimers(from: context)
                }
                Button("Zrušit", role: .cancel) {}
            } message: {
                Text("Trénink se stejným názvem už existuje. Chceš ho přepsat?")
            }
        }
    }
}
