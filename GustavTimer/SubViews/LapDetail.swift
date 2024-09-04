//
//  LapDetail.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 04.08.2024.
//

import SwiftUI

struct LapDetail: View {
    let index: Int
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: GustavViewModel
    @State private var selectedMinutes: Int = 0
    @State private var selectedSeconds: Int = 0
    @State private var timerText: String = ""
    
    private func delete(at offsets: IndexSet) {
        if viewModel.timers.count > 1 {
            viewModel.timers.remove(atOffsets: offsets)
        }
    }
    
    private func updateTimerValue() {
        viewModel.timers[index].value = (selectedMinutes * 60) + selectedSeconds
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("INTERVAL_NAME:")
                    TextField("", text: $viewModel.timers[index].name)
                }
            }
            
            Section {
                VStack {
                    Text("INTERVAL_TIME")
                    
                    HStack {
                        Picker("Minutes", selection: $selectedMinutes) {
                            ForEach(0..<60) { minute in
                                Text("\(minute) min").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .onChange(of: selectedMinutes, { _, _ in
                            updateTimerValue()
                        })
                        
                        Picker("Seconds", selection: $selectedSeconds) {
                            ForEach(0..<60) { second in
                                Text("\(second) sec").tag(second)
                            }
                        }
                        .pickerStyle(.wheel)
                        .onChange(of: selectedSeconds) { _, _ in
                            updateTimerValue()
                        }
                    }
                    
                    Text("Total: \(viewModel.timers[index].value) seconds")
                }
            }
            Section {
                            
                            VStack(alignment: .center) {
                                Text("INTERVAL_TIME")
                                TextField("", text: $timerText)
                                    .font(.system(size: 100))
                                    .multilineTextAlignment(.center)
                                    .keyboardType(.numberPad) // Nastavení na numerickou klávesnici
                                    .onChange(of: timerText, { oldValue, newValue in
                                        // Validace a převod textu na číslo
                                        if let value = Int(newValue), value > 0 {
                                            viewModel.timers[index].value = value
                                        } else if newValue.isEmpty {
                                            viewModel.timers[index].value = 1 // nebo jiná výchozí hodnota
                                        } else {
                                            timerText = String(viewModel.timers[index].value)
                                        }
                                    })
                                    .onAppear {
                                        // Načtení výchozí hodnoty z viewModelu
                                        timerText = String(viewModel.timers[index].value)
                                    }
                                Text("SECONDS")
                            }
                        }
            
            Section {
                if viewModel.timers.count > 1 {
                    Button("DELETE", action: {
                        delete(at: [index])
                        dismiss()
                    })
                }
            }
        }
        .onAppear {
            // Initialize the selected minutes and seconds from the viewModel
            selectedMinutes = viewModel.timers[index].value / 60
            selectedSeconds = viewModel.timers[index].value % 60
        }
        .navigationTitle("\(viewModel.timers[index].name)")
    }
}
