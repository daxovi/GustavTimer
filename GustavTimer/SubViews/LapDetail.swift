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
                        .font(Font.custom("MartianMono-Bold", size: 15))
                        .foregroundColor(Color("StopColor"))
                }
            }
            Section {
                            VStack(alignment: .center) {
                                Text("INTERVAL_TIME")
                                    .textCase(.uppercase)
                                    .font(Font.custom("MartianMonoSemiCondensed-Bold", size: 15))
                                TextField("", text: $timerText)
                                    .font(Font.custom("MartianMono-Bold", size: 100))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color("StartColor"))
                                    .keyboardType(.numberPad) // Nastavení na numerickou klávesnici
                                    .onChange(of: timerText, { _, newValue in
                                        setTimer(newValue: newValue)
                                    })
                                    .onAppear {
                                        // Načtení výchozí hodnoty z viewModelu
                                        timerText = String(viewModel.timers[index].value)
                                    }
                                    .padding()
                                Text("SECONDS")
                                    .font(Font.custom("MartianMonoSemiCondensed-Bold", size: 15))
                                    .textCase(.uppercase)
                                HStack {
                                    HintButton(labelText: "1min", action: {setTimer(newValue: "60")})
                                    Spacer()
                                    HintButton(labelText: "1min30sec", action: {setTimer(newValue: "90")})
                                    Spacer()
                                    HintButton(labelText: "5min", action: {setTimer(newValue: "300")})
                                }
                                .padding(.top)
                                .padding(.top)
                            }
                        }
            .foregroundStyle(Color.white)
            .padding()
            .listRowBackground(
                    BGImageView(image: viewModel.getImage()).blur(radius: 6)
                        .frame(width: 450)
            )
            .tint(Color("StartColor"))
            
            Section {
                if viewModel.timers.count > 1 {
                    Button("DELETE", action: {
                        dismiss()
                        delete(at: [index])
                    })
                }
            }
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .navigationTitle("\(viewModel.timers[index].name)")
    }
    
    func setTimer(newValue: String) {
        if let value = Int(newValue), value > 0 {
            timerText = newValue
            viewModel.timers[index].value = value
        } else if newValue.isEmpty {
            viewModel.timers[index].value = 1 // nebo jiná výchozí hodnota
        } else {
            timerText = String(viewModel.timers[index].value)
        }
    }
}
