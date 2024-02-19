//
//  EditSheetView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 01.10.2023.
//

import SwiftUI

struct EditSheetView: View {
    @StateObject var viewModel: GustavViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationStack {
                List {
                    HStack {
                        Text("Laps")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    laps
                    settingsToggle
                    bgSelector
                }
                .navigationBarTitleDisplayMode(.inline)
                .listStyle(.plain)
                .toolbar { toolbarButtons }
                .environment(\.editMode, $viewModel.editMode)
            }
            saveButton
        }
        .ignoresSafeArea()
    }

    
    var laps: some View {
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
    
    var toolbarButtons: some View {
        HStack {
            if !viewModel.isTimerFull {
                Button("Add lap") {viewModel.addTimer()}
            }
            EditButton()
        }
        .foregroundStyle(Color("ResetColor"))
    }
    
    var saveButton: some View {
        Button(action: {
            viewModel.resetTimer()
            viewModel.toggleSheet()
        }, label: {
            Color("StartColor")
                .overlay {
                    Text("SAVE")
                        .foregroundStyle(Color("ResetColor"))
                }
                .frame(height: viewModel.buttonHeight)
        })
    }
    
    var settingsToggle: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .fontWeight(.bold)
            Toggle("Always on display", isOn: $viewModel.isAlwaysOnDisplay)
                .tint(Color("StartColor"))
            Toggle("Sound", isOn: $viewModel.isSoundOn)
                .tint(Color("StartColor"))
        }
        .padding(.vertical)
    }
    
    var bgSelector: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Background")
                .fontWeight(.bold)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], content: {
                ForEach(0..<viewModel.bgImages.count, id: \.self) { index in
                    viewModel.bgImages[index].getImage()
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onTapGesture {
                            print("set image: \(index)")
                            viewModel.setBG(index: index)
                        }
                        .overlay {
                            if viewModel.bgIndex == index {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(style: .init(lineWidth: 4))
                                    .fill(Color("StartColor"))
                            }
                        }
                }
            })
        }
        .padding(.vertical)
    }
}
