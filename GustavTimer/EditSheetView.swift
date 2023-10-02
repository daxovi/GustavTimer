//
//  EditSheetView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 01.10.2023.
//

import SwiftUI

struct EditSheetView: View {
    @ObservedObject var viewModel: GustavViewModel
    
    var body: some View {
        VStack {
            ForEach((0..<viewModel.timers.count), id: \.self) { index in
                HStack {
                    if (viewModel.timers[index] > 0) {
                        
                        Stepper(value: $viewModel.timers[index],
                                in: (1...100),
                                step: 1) {
                            Text("Lap \(index + 1): \(viewModel.timers[index])")
                        }
                        if viewModel.timers.count > 2 {
                            Button(action: {
                                viewModel.removeTimer(index: index)
                            }, label: {
                                Image(systemName: "minus.circle.fill")
                            })
                        }
                    } else {
                        HStack {
                            Spacer()
                            Button(action: {
                                viewModel.addTimer()
                            }, label: {
                                Image(systemName: "plus.circle.fill")
                            })
                        }
                    }
                }
                .padding()
            }
            Button("save") {
                viewModel.resetTimer()
                viewModel.toggleSheet()
            }
        }
    }
}
