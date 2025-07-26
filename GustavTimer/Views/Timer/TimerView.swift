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
    
    @StateObject var viewModel = TimerViewModel.shared
    
    var body: some View {
        ZStack {
            BackgroundImageView()
            
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
    
    enum DeviceType {
        case smalliPhone
        case largeiPhone
    }

    func deviceType() -> DeviceType {
        let screenWidth = UIScreen.main.bounds.width
        
        if screenWidth <= 385 {
            // iPhone SE, SE2, iPhone 8
            return .smalliPhone
        } else {
            // iPhone X, 11, 12, a další větší modely
            return .largeiPhone
        }
    }
    
    var controlButtons: some View {
        HStack(spacing: 0) {
            ControlButton(action: {
                viewModel.startStopTimer()
            }, text: viewModel.isTimerRunning ? "STOP" : "START", color: viewModel.isTimerRunning ? .stop : .start)
            if viewModel.isTimerRunning {
                ControlButton(action: { viewModel.skipLap() }, text: "SKIP", color: .reset)
            } else {
                ControlButton(action: { viewModel.resetTimer() }, text: "RESET", color: .reset)
            }
        }
        .frame(maxWidth: 1000)
        .clipShape(RoundedRectangle(cornerRadius: 0))
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
