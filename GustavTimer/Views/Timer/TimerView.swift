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
    @Environment(\.theme) var theme
    @StateObject var viewModel = TimerViewModel()
    
    var body: some View {
        ZStack {
            BackgroundImageView()
            
            VStack {
                ProgressArrayView(viewModel: viewModel)
                    .padding(.top)
                
                headerSection
                
                Spacer()
                
                counterDisplay
                
                Spacer()
                
                controlButtons
            }
            .ignoresSafeArea(edges: .bottom)
            .statusBar(hidden: true)
            .persistentSystemOverlays(.hidden)
        }
        .onAppear {
            setupViewModel()
        }
        .onChange(of: showSettings) { _, newValue in
            if newValue {
                // SettingsView se otevírá, zastavit časovač
                viewModel.stopTimer()
            } else {
                // SettingsView se zavřelo, znovu načti data z databáze a resetuj časovač
                viewModel.reloadTimers(resetCurrentState: true)
            }
        }
        .sheet(isPresented: $viewModel.showingWhatsNew) {
            whatsNewSheet
        }
        .onOpenURL { url in
            viewModel.handleDeepLink(url: url)
        }
    }
}

// MARK: - View Components
private extension TimerView {
    
    var headerSection: some View {
        HStack {
            currentTimerInfo
            Spacer()
            settingsButton
        }
        .font(theme.fonts.headUpDisplay)
    }
    
    var currentTimerInfo: some View {
        Group {
            if let currentTimer = currentTimer {
                Text("\(currentTimer.name) (\(viewModel.round))")
                    .safeAreaPadding(.horizontal)
                    .foregroundColor(Color("StartColor").opacity(viewModel.round == 0 ? 0.0 : 1.0))
                    .animation(.easeInOut(duration: 0.2), value: viewModel.round)
            } else {
                Text("No Timer")
                    .safeAreaPadding(.horizontal)
                    .foregroundColor(Color("StartColor").opacity(0.5))
            }
        }
    }
    
    var counterDisplay: some View {
        Text(viewModel.formattedCurrentTime())
            .font(theme.fonts.timerCounter)
            .minimumScaleFactor(0.01)
            .foregroundColor(Color("StartColor"))
    }
    
    var controlButtons: some View {
        HStack(spacing: 16) {
            startStopButton
            secondaryButton
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
        .frame(width: 100)
    }
    
    var settingsButton: some View {
        Button {
            showSettings.toggle()
        } label: {
            HStack {
                settingsIcons
                Text("EDIT")
            }
            .foregroundColor(Color("StartColor"))
        }
        .safeAreaPadding(.horizontal)
    }
    
    var settingsIcons: some View {
        HStack {
            if viewModel.isLooping {
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
    
    var whatsNewSheet: some View {
        WhatsNewView(
            buttonLabel: "enter challenge",
            tags: ["#whatsnew", "V1.4"]
        ) {
            viewModel.showingWhatsNew = false
            viewModel.showingSheet.toggle()
        }
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
