//
//  LapDetail.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 04.08.2024.
//

import SwiftUI

struct LapDetailView: View {
    var timer: TimerData
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: GustavViewModel
    @State private var timerText: String = ""
    @FocusState private var keyboardFocused: Bool
    
    func deleteTimer() {
        if let index = viewModel.timers.firstIndex(where: { $0.id == timer.id }) {
            viewModel.timers.remove(at: index)
        }
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("INTERVAL_NAME:")
                        .opacity(0.6)
                        .textCase(.uppercase)
                    
                    if let index = viewModel.timers.firstIndex(where: { $0.id == timer.id }) {
                        TextField("", text: $viewModel.timers[index].name)
                    } else {
                        Text("Timer not found")
                            .foregroundColor(.red)
                    }
                }
            }
            Section {
                VStack(alignment: .center) {
                    Text("INTERVAL_TIME")
                        .textCase(.uppercase)
                    TextField("", text: $timerText)
                        .font(Font.custom(AppConfig.counterFontName, size: 100))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("StartColor"))
                        .keyboardType(.numberPad) // Nastavení na numerickou klávesnici
                        .onChange(of: timerText, { _, newValue in
                            setTimer(newValue: newValue)
                        })
                        .focused($keyboardFocused)
                        .onAppear {
                            // Načtení výchozí hodnoty z viewModelu
                            timerText = String(timer.value)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                keyboardFocused = true
                            }
                        }
                        .padding()
                    HStack {
                        HintButton(labelText: "1min", action: {setTimer(newValue: "60")})
                        Spacer()
                        HintButton(labelText: "1min30sec", action: {setTimer(newValue: "90")})
                        Spacer()
                        HintButton(labelText: "5min", action: {setTimer(newValue: "300")})
                    }
                }
            }
            .foregroundStyle(Color.white)
            .padding()
            .listRowBackground(
                BGImageView(image: viewModel.getImage()).blur(radius: 6)
                    .frame(width: 450)
                    .opacity(0.9)
            )
            .tint(Color("StartColor"))
            
            Section {
                if viewModel.timers.count > 1 {
                    Button("DELETE", action: {
                        deleteTimer()
                        dismiss()
                    })
                }
            }
        }
        .navigationTitle("\(timer.name)")
    }
    
    func setTimer(newValue: String) {
        if let value = Int(newValue), value > 0 {
            // Kontrola, zda hodnota nepřekračuje maximální hodnotu z AppConfig
            let clampedValue = min(value, AppConfig.maxTimerValue)
            
            timerText = String(clampedValue)
            if let index = viewModel.timers.firstIndex(where: { $0.id == timer.id }) {
                viewModel.timers[index].value = clampedValue
            }
        } else if newValue.isEmpty {
            if let index = viewModel.timers.firstIndex(where: { $0.id == timer.id }) {
                viewModel.timers[index].value = 1 // výchozí hodnota
            }
        } else {
            if let index = viewModel.timers.firstIndex(where: { $0.id == timer.id }) {
                timerText = String(viewModel.timers[index].value)
            }
        }
    }
}
