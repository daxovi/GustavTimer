//
//  TimerRow.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 13.07.2024.
//

import SwiftUI

struct TimerRow: View {
    @Binding var timer: Int
    let index: Int
    let maxCountdownValue: Int
    @State private var timerText: String
    @State private var wrongValue = 0
    @State private var showError = false
    
    init(timer: Binding<Int>, index: Int, maxCountdownValue: Int) {
        self._timer = timer
        self.index = index
        self._timerText = State(initialValue: String(timer.wrappedValue))
        self.maxCountdownValue = maxCountdownValue
    }
    
    var body: some View {
        HStack {
            Stepper(value: $timer, in: 1...maxCountdownValue, step: 1) {
                HStack(spacing: 0) {
                    Text(String(format: NSLocalizedString("LAP", comment: ""), "\(index + 1)"))
                    TextField("", text: $timerText)
                        .keyboardType(.numberPad)
                        .onChange(of: timerText, { _, newValue in
                            if let intValue = Int(newValue) {
                                if intValue < maxCountdownValue + 1 {
                                    timer = intValue
                                } else {
                                    timer = maxCountdownValue
                                    timerText = String(timer)
                                    wrongValuError()
                                }
                                if intValue > 0 {
                                    timer = intValue
                                } else {
                                    timerText = "1"
                                    timer = 1
                                    wrongValuError()
                                }
                            }
                        })
                        .onChange(of: timer, { oldValue, newValue in
                            timerText = String(timer)
                        })
                        .onAppear {
                            timerText = String(timer)
                        }
                        .foregroundColor(showError ? .red : .primary) // Barva textu na základě chyby
                }
                .onTapGesture {
                    self.hideKeyboard()
                }
                .sensoryFeedback(.error, trigger: wrongValue)
                
            }
        }
        .padding(2)
    }
    
    func wrongValuError() {
        wrongValue += 1
        print("debug. wrongvalue")
        showError = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showError = false
        }
    }
}

