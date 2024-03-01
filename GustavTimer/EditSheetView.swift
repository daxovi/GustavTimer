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
                        Text("LAPS")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    laps
                    recentTimers
                    settingsToggle.padding(.top, 8)
                    bgSelector.padding(.top, 8)
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
    
    var recentTimers: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.recentTimers, id: \.self) { array in
                    Text(array.map { String($0) }.joined(separator: ":"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(content: {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.gray.opacity(0.2))
                        })
                        .fixedSize(horizontal: true, vertical: false)
                        .onTapGesture {
                            viewModel.timers = array
                        }
                }
            }
        }
    }
    
    var laps: some View {
        ForEach((0..<viewModel.timers.count), id: \.self) { index in
            HStack {
                Stepper(value: $viewModel.timers[index],
                        in: (1...300),
                        step: 1) {
                    Text(String(format: NSLocalizedString("LAP", comment: ""), "\(index + 1)", "\(viewModel.timers[index])"))
                }
            }
            .padding(2)
        }
        .onMove(perform: { indices, newOffset in
            viewModel.timers.move(fromOffsets: indices, toOffset: newOffset)
        })
        .onDelete(perform: viewModel.timers.count > 1 ? viewModel.removeTimer : nil)
    }
    
    var toolbarButtons: some View {
        HStack {
            if !viewModel.isTimerFull {
                Button("ADD_LAP") {viewModel.addTimer()}
            }
            Text(" ")
            EditButton()
        }
        .foregroundStyle(Color("ResetColor"))
    }
    
    var saveButton: some View {
        Button(action: viewModel.saveSettings, label: {
            Color("StartColor")
                .overlay {
                    Text("SAVE")
                        .foregroundStyle(Color("ResetColor"))
                }
                .frame(height: viewModel.buttonHeight)
        })
    }
    
    var settingsToggle: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("SETTINGS")
                .fontWeight(.bold)
            Toggle("LOOP", isOn: $viewModel.isLooping)
                .tint(Color("StartColor"))
            Toggle("SOUND", isOn: $viewModel.isSoundOn)
                .tint(Color("StartColor"))
        }
    }
    
    var bgSelector: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("BACKGROUND")
                .fontWeight(.bold)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0..<viewModel.bgImages.count, id: \.self) { index in
                        viewModel.bgImages[index].getImage()
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width / 3)
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
                            .padding(1)
                    }
                }
            }
        }
    }
}
