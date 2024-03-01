//
//  ContentView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 19.04.2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = GustavViewModel.shared
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack {
                BGImageView(image: viewModel.getImage())
                
                VStack {
                    ProgressView(viewModel: viewModel)
                        .padding(.top)
                    HStack {
                        Spacer()
                        
                        editButton
                    }
                    Spacer()
                    
                    counter
                    
                    Spacer()
                    Spacer()
                    
                    controlButtons
                }
                .font(Font.custom("MartianMono-Regular", size: 15))
                .ignoresSafeArea(edges: .bottom)
                .statusBar(hidden: true)
            }
        })
    }
    
    var counter: some View {
        Text("\(viewModel.count)")
            .font(Font.custom("MartianMono-Bold", size: 500))
            .minimumScaleFactor(0.01)
            .padding((viewModel.count < 10) ? 30 : 0)
            .foregroundColor(Color("StartColor"))
    }
    
    var controlButtons: some View {
        HStack(spacing: 0) {
            Button(action: viewModel.startStopTimer) {
                if viewModel.isTimerRunning {
                    Color("StopColor")
                        .overlay {
                            Text("STOP")
                        }
                        .frame(height: viewModel.buttonHeight)
                } else {
                    Color("StartColor")
                        .overlay {
                            Text("START")
                                .foregroundStyle(Color("ResetColor"))
                        }
                        .frame(height: viewModel.buttonHeight)
                }
            }
            
            if viewModel.isTimerRunning {
                Button(action: viewModel.skipLap, label: {
                    Color("ResetColor")
                        .overlay {
                            Text("SKIP")
                        }
                        .frame(height: viewModel.buttonHeight)
                })
            } else {
                Button(action: viewModel.resetTimer, label: {
                    Color("ResetColor")
                        .overlay {
                            Text("RESET")
                        }
                        .frame(height: viewModel.buttonHeight)
                })
            }
        }
    }
    
    var editButton: some View {
        Button("EDIT") {
            print("button edit")
            viewModel.toggleSheet()
        }
        .safeAreaPadding(.horizontal)
        .sheet(isPresented: $viewModel.showingSheet) { EditSheetView(viewModel: viewModel).interactiveDismissDisabled() }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
