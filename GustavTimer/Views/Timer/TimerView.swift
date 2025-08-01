//
//  TimerView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 26.07.2025.
//

import SwiftUI
import SwiftData

struct TimerView: View {
    @Binding var showSettings: Bool
    @Environment(\.modelContext) var context
    @StateObject var viewModel = TimerViewModel()
    
    var body: some View {
        ZStack {
            BackgroundImageView()
            
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
                
                controlButtons
            }
            .font(Font.custom("MartianMono-Regular", size: 15))
            .ignoresSafeArea(edges: .bottom)
            .statusBar(hidden: true)
            .persistentSystemOverlays(.hidden)
        }
        .onAppear {
            viewModel.showWhatsNew()
        }
        .onAppear {
            viewModel.setModelContext(context)
        }
        .onChange(of: showSettings) { _, _ in
            viewModel.resetTimer()
        }
        .sheet(isPresented: $viewModel.showingWhatsNew) {
            WhatsNewView(buttonLabel: "enter challenge", tags: ["#whatsnew", "V1.4"], action: {
                viewModel.showingWhatsNew = false
                viewModel.showingSheet.toggle()
            })
            
        }
        // depplink
        .onOpenURL { URL in
            viewModel.handleDeepLink(url: URL)
        }
    }
    
    var controlButtons: some View {
        HStack(spacing: 16) {
            ControlButton(
                action: viewModel.startStopTimer,
                label: viewModel.isTimerRunning ? "STOP" : "START",
                description: viewModel.isTimerRunning ? nil : "\(viewModel.timers[viewModel.activeTimerIndex].name)",
                color: viewModel.isTimerRunning ? .stop : .start)
            
            ControlButton(
                action: viewModel.isTimerRunning ? viewModel.skipLap : viewModel.resetTimer,
                label: viewModel.isTimerRunning ? "SKIP" : "RESET",
                color: .reset)
            .frame(width: 100)
            
        }
        .animation(.easeInOut, value: viewModel.isTimerRunning)
        .frame(maxWidth: .infinity)
        .padding()
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
            Button {
                showSettings.toggle()
            } label: {
                HStack {
                    HStack{
                            Image(systemName: "infinity.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color(viewModel.isLooping ? .start : .reset))
                        Image(systemName: viewModel.isSoundEnabled ? "speaker.wave.2.circle.fill" : "speaker.slash.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color(viewModel.isSoundEnabled ? .start : .reset))
                    }
                    .frame(height: 20)

                    Text("EDIT")
                }
                .foregroundColor(Color("StartColor"))
        }
        .safeAreaPadding(.horizontal)
    }
    
}
