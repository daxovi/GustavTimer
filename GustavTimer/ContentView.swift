//
//  ContentView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 19.04.2023.
//

import SwiftUI
import StoreKit
import SwiftData

struct ContentView: View {
    @StateObject var viewModel = GustavViewModel.shared
    @Environment(\.requestReview) var requestReview
    @Query var customImage: [CustomImageModel]
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack {
                if viewModel.bgIndex == -1 {
                    if let lastImageData = customImage.last?.image, let uiImage = UIImage(data: lastImageData) {
                        BGImageView(image: Image(uiImage: uiImage))
                    } else {
                        BGImageView(image: viewModel.getImage())
                    }
                } else {
                    BGImageView(image: viewModel.getImage())
                }
                
                VStack {
                    ProgressArrayView(viewModel: viewModel)
                        .padding(.top)
                    HStack {
                        rounds
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
    
    var rounds: some View {
        Text( "\(viewModel.timers[viewModel.activeTimerIndex].name)")
            .textCase(.uppercase)
                .safeAreaPadding(.horizontal)
                .foregroundColor(Color("StartColor").opacity((viewModel.round == 0) ? 0.0 : 1.0))
                .animation(.easeInOut(duration: 0.2), value: viewModel.round)
    }
    
    var counter: some View {
        Text("\(viewModel.count)")
            .font(Font.custom(AppConfig.counterFontName, size: 500))
            .minimumScaleFactor(0.01)
            .padding((viewModel.count < 10) ? 30 : 0)
            .foregroundColor(Color("StartColor"))
    }
    
    var controlButtons: some View {
        HStack(spacing: 0) {
            Button(action: {
                viewModel.startStopTimer()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                    if viewModel.stopCounter > 20 && !viewModel.isTimerRunning {
                        if !viewModel.isTimerRunning {
                            viewModel.stopCounter = 0
                            requestReview()
                        }
                    }
                }
            }) {
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
        .sheet(isPresented: $viewModel.showingSheet, onDismiss: {
            viewModel.saveSettings()
        }) { EditSheetView(viewModel: viewModel) }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
