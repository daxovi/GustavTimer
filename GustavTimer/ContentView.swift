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
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Query var customImage: [CustomImageModel]
    
    var body: some View {
        ZStack {
            background
            
            VStack {
                ProgressArrayView()
                    .padding(.top)
                HStack {
                    rounds
                    Spacer()
                    editButton
                }
                Spacer()
                
                counter
                
                Spacer()
                
                ControlButtonsView()
            }
            .font(Font.custom("MartianMono-Regular", size: 15))
            .ignoresSafeArea(edges: .bottom)
            .statusBar(hidden: true)
            .persistentSystemOverlays(.hidden)
        }
    }
    
    var background: some View {
        if viewModel.bgIndex == -1 {
            if let lastImageData = customImage.last?.image, let uiImage = UIImage(data: lastImageData) {
                BGImageView(image: Image(uiImage: uiImage))
            } else {
                BGImageView(image: viewModel.getImage())
            }
        } else {
            BGImageView(image: viewModel.getImage())
        }
    }
    
    var rounds: some View {
        Text( "\(viewModel.timers[viewModel.activeTimerIndex].name) (\(viewModel.round))")
                .safeAreaPadding(.horizontal)
                .foregroundColor(Color("StartColor").opacity((viewModel.round == 0) ? 0.0 : 1.0))
                .animation(.easeInOut(duration: 0.2), value: viewModel.round)
    }
    
    var counter: some View {
        Text("\(viewModel.count)")
            .font(Font.custom(AppConfig.counterFontName, size: 800))
            .minimumScaleFactor(0.01)
            .foregroundColor(Color("StartColor"))
    }
    
    var editButton: some View {
        Button("EDIT") {
            print("button edit")
            viewModel.toggleSheet()
        }
        .safeAreaPadding(.horizontal)
        .sheet(isPresented: $viewModel.showingSheet, onDismiss: {
            viewModel.saveSettings()
        }) { EditSheetView() }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
