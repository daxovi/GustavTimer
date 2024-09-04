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
    @State private var timerText: String = ""
    @State private var timerValue: Int = 0
    
    private func delete(at offsets: IndexSet) {
        if viewModel.timers.count > 1 {
            viewModel.timers.remove(atOffsets: offsets)
        }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Text("INTERVAL_NAME:")
                    TextField("", text: $viewModel.timers[index].name)
                }
            }
            Picker("picker", selection: $viewModel.timers[index].value) {
                ForEach(1..<601) { number in
                    Text("\(number)")
                        .tag(number)
                }
            }
            .pickerStyle(.wheel)
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
        .navigationTitle("\(viewModel.timers[index].name)")
    }
}
