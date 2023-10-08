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
            NavigationView {
                List {
                    ForEach((0..<viewModel.timers.count), id: \.self) { index in
                        HStack {
                                Stepper(value: $viewModel.timers[index],
                                        in: (1...300),
                                        step: 1) {
                                    Text("Lap \(index + 1): \(viewModel.timers[index])")
                                }
                        }
                        .padding(5)
                    }
                    .onMove(perform: { indices, newOffset in
                        viewModel.timers.move(fromOffsets: indices, toOffset: newOffset)
                    })
                    .onDelete(perform: viewModel.timers.count > 1 ? viewModel.removeTimer : nil)
                }
                .navigationBarTitleDisplayMode(.inline)
                .listStyle(.plain)
                .toolbar {
                    if !viewModel.isTimerFull {
                        Button("Add") {viewModel.addTimer()}
                    }
                    EditButton()
                }
            }
            Button(action: {
                viewModel.resetTimer()
                viewModel.toggleSheet()
            }, label: {
                Color.green
                    .overlay {
                        Text("SAVE")
                            .foregroundStyle(.white)
                    }
                    .frame(height: 100)
                    
            })
            
    }
        .ignoresSafeArea()
    }


}
