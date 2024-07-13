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
    @State private var timerText: String

    init(timer: Binding<Int>, index: Int) {
        self._timer = timer
        self.index = index
        self._timerText = State(initialValue: String(timer.wrappedValue))
    }

    var body: some View {
        HStack {
            Stepper(value: $timer, in: 1...300, step: 1) {
                HStack(spacing: 0) {
                    Text(String(format: NSLocalizedString("LAP", comment: ""), "\(index + 1)"))
                    TextField("", text: $timerText)
                        .keyboardType(.numberPad)
                        .onChange(of: timerText, { _, newValue in
                            if let intValue = Int(newValue) {
                                if intValue < 301 {
                                    timer = intValue
                                } else {
                                        timerText = "300"
                                    timer = 300
                                }
                                
                                if intValue > 0 {
                                    timer = intValue
                                } else {
                                    timerText = "1"
                                    timer = 1
                                }
                            }
                        })
                        .onAppear {
                            timerText = String(timer)
                        }
                }
            }
        }
        .padding(2)
    }
}

