//
//  ContentView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 19.04.2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = GustavViewModel.shared
    
    var body: some View {
        ZStack {
            Text("\(viewModel.count)")
                .font(Font.custom("MartianMono-Bold", size: 500))
                .minimumScaleFactor(0.01)
            /*
            DotView()
                .frame(width: UIScreen.main.bounds.width)
             */
            
            VStack {
                ProgressView(viewModel: viewModel)
                HStack {
                    Spacer()
                    Button("EDIT") {
                        print("button edit")
                        viewModel.toggleSheet()
                    }
                    .padding()
                    .sheet(isPresented: $viewModel.showingSheet) { EditSheetView(viewModel: viewModel) }
                }
                
                Spacer()
                
                
            }
            .padding()
            .font(Font.custom("MartianMono-Regular", size: 15))
            
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    Button(action: viewModel.startStopTimer) {
                        if viewModel.isTimerRunning {
                            Color.red
                                .overlay {
                                    Text(viewModel.isTimerRunning ? "STOP" : "START")
                                        .font(Font.custom("MartianMono-Regular", size: 15))
                                }
                                .frame(height: 100)
                        } else {
                            Color.green
                                .overlay {
                                    Text(viewModel.isTimerRunning ? "STOP" : "START")
                                        .font(Font.custom("MartianMono-Regular", size: 15))
                                }
                                .frame(height: 100)
                        }
                       
                    }
                    Button(action: viewModel.resetTimer, label: {
                        Color.gray
                            .overlay {
                                Text("RESET")
                                    .font(Font.custom("MartianMono-Regular", size: 15))
                            }
                            .frame(height: 100)
                    })
                }
            }
            .foregroundStyle(.white)
            .ignoresSafeArea()
        }
    }
        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
