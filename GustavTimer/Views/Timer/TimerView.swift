//
//  TimerView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 26.07.2025.
//

import SwiftUI
import SwiftData
import UIKit

struct TimerView: View {
    @Environment(\.modelContext) var context
    @Environment(\.theme) var theme
    @StateObject var viewModel = TimerViewModel()
    
    var namespace: Namespace.ID
    
    var dismiss: () -> ()
        
    var body: some View {
        ZStack {
            BackgroundImageView()
                .matchedGeometryEffect(id: "background", in: namespace, isSource: true)

            portraitTimerView
                .padding(.top, 70)
        }
        .onAppear {
            setupViewModel()
        }
        .onOpenURL { url in
            viewModel.handleDeepLink(url: url)
        }
    }
}

// MARK: - Orientation Handling
private extension TimerView {
    
    
    var portraitTimerView: some View {
        VStack {
            ProgressArrayView(viewModel: viewModel)
            
            headerSection
            
            Spacer()
            
            counterDisplay(timeDisplayFormat: .seconds)
            
            Spacer()
            
            horizontalControlButtons
        }
        .statusBar(hidden: true)
        .persistentSystemOverlays(.hidden)
    }
    
    var landscapeTimerView: some View {
        VStack {
            //            ProgressArrayView(viewModel: viewModel)
            //                .padding(.top)
            
            //            headerSection
            
            Spacer()
            
            counterDisplay(timeDisplayFormat: .minutesSecondsHundredths)
            
            Spacer()
        }
        //        .ignoresSafeArea(edges: .bottom)
        .statusBar(hidden: true)
        .persistentSystemOverlays(.hidden)
        .onTapGesture {
            viewModel.startStopTimer()
        }
    }
}

// MARK: - View Components
private extension TimerView {
    
    var headerSection: some View {
        HStack {
            currentTimerInfo
            Spacer()
            settingsIcons
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(Color("StartColor"))
                .padding(.horizontal)
                .onTapGesture {
                    dismiss()
                }
        }
        .font(theme.fonts.headUpDisplay)
    }
    
    @ViewBuilder
    var currentTimerInfo: some View {
        if let currentTimer = currentTimer {
            Text("\(currentTimer.name) (\(viewModel.finishedRounds)\(viewModel.rounds == -1 ? "" : ("/" + String(viewModel.rounds))))")
                .safeAreaPadding(.horizontal)
                .foregroundColor(Color("StartColor").opacity(viewModel.finishedRounds == 0 ? 0.0 : 1.0))
                .animation(.easeInOut(duration: 0.2), value: viewModel.finishedRounds)
        } else {
            Text("No Timer")
                .safeAreaPadding(.horizontal)
                .foregroundColor(Color("StartColor").opacity(0.5))
        }
    }
    
    func counterDisplay(timeDisplayFormat: TimeDisplayFormat) -> some View {
        Text(viewModel.formattedCurrentTime(timeDisplayFormat: timeDisplayFormat))
            .font(theme.fonts.timerCounter)
            .minimumScaleFactor(0.01)
            .foregroundColor(Color("StartColor"))
            .matchedGeometryEffect(id: "number", in: namespace, isSource: true)
    }
    
    var horizontalControlButtons: some View {
        HStack(spacing: 16) {
            startStopButton
                .matchedGeometryEffect(id: "button", in: namespace, isSource: true)
            secondaryButton
                .frame(width: 100)
        }
        .animation(.easeInOut, value: viewModel.isTimerRunning)
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    var verticalControlButtons: some View {
        VStack(spacing: 16) {
            startStopButton
            secondaryButton
                .frame(width: 100)
        }
        .animation(.easeInOut, value: viewModel.isTimerRunning)
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    var startStopButton: some View {
        ControlButton(
            action: viewModel.startStopTimer,
            label: viewModel.isTimerRunning ? "STOP" : "START",
            description: startButtonDescription.map { LocalizedStringKey($0) },
            color: viewModel.isTimerRunning ? .stop : .start
        )
    }
    
    var secondaryButton: some View {
        ControlButton(
            action: viewModel.isTimerRunning ? viewModel.skipLap : viewModel.resetTimer,
            riveAnimation: viewModel.isTimerRunning ? theme.animations.reset : theme.animations.reset,
            color: .reset
        )
    }
    
    var settingsIcons: some View {
        HStack {
            if viewModel.rounds == -1 {
                theme.icons.loop
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(theme.colors.volt)
            }
            
            if viewModel.isVibrating {
                theme.icons.vibration
                    .scaledToFit()
                    .foregroundColor(theme.colors.volt)
            }
            
            if viewModel.isSoundEnabled {
                soundIcon
            }
        }
        .frame(height: 20)
    }
    
    var soundIcon: some View {
        Image(systemName: viewModel.isSoundEnabled ? "speaker.wave.2.circle.fill" : "speaker.slash.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(Color(viewModel.isSoundEnabled ? .start : .reset))
    }
}

// MARK: - Computed Properties
private extension TimerView {
    
    var currentTimer: IntervalData? {
        guard viewModel.activeTimerIndex < viewModel.timers.count else { return nil }
        return viewModel.timers[viewModel.activeTimerIndex]
    }
    
    var startButtonDescription: String? {
        guard !viewModel.isTimerRunning, let currentTimer = currentTimer else { return nil }
        return currentTimer.name
    }
}

// MARK: - Helper Methods
private extension TimerView {
    
    func setupViewModel() {
        viewModel.setModelContext(context)
        viewModel.showWhatsNew()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CustomImageModel.self, TimerData.self])
}
