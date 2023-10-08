//
//  ContentView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 19.04.2023.
//

import SwiftUI
import SceneKit
import RealityKit

struct ContentView: View {
    @ObservedObject var viewModel = GustavViewModel.shared
    
    var body: some View {
        ZStack {
            Text("\(viewModel.count)")
            
            VStack {
                ProgressView(gustavViewModel: viewModel)
                HStack {
                    Spacer()
                    Button("edit") {
                        print("button edit")
                        viewModel.toggleSheet()
                    }
                    .padding()
                    .sheet(isPresented: $viewModel.showingSheet) { EditSheetView(viewModel: viewModel) }
                }
                
                Spacer()
                
                VStack {
                    Button(action: viewModel.startStopTimer) {
                        Text(viewModel.isTimerRunning ? "Stop Timer" : "Start timer")
                            .padding()
                            .frame(width: UIScreen.main.bounds.width - 30)
                            .foregroundColor(.white)
                            .background(.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    Button("Reset Timer") {
                        viewModel.resetTimer()
                    }
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
