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
    @Binding var showSettings: Bool
    @Environment(\.modelContext) var context
    @Environment(\.theme) var theme
    @StateObject var viewModel = TimerViewModel()
    @State private var orientation = UIDeviceOrientation.unknown

    
    var body: some View {
        ZStack {
            BackgroundImageView()
            if orientation.isLandscape {
                landscapeTimerView
            } else {
                portraitTimerView
            }
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
        .onAppear {
            // Nastavíme počáteční orientaci
            orientation = UIDevice.current.orientation
            // Zaregistrujeme se pro notifikace o změně orientace
            NotificationCenter.default.addObserver(
                forName: UIDevice.orientationDidChangeNotification,
                object: nil,
                queue: .main) { _ in
                    if UIDevice.current.orientation.isValidInterfaceOrientation {
                        orientation = UIDevice.current.orientation
                    }
                }
        }
        .onDisappear {
            // Odregistrujeme notifikace
            NotificationCenter.default.removeObserver(
                self,
                name: UIDevice.orientationDidChangeNotification,
                object: nil)
        }
        .sheet(isPresented: $viewModel.showingWhatsNew) {
            whatsNewSheet
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
                .padding(.top)
            
            headerSection
            
            Spacer()
            
            counterDisplay(timeDisplayFormat: .seconds)
            
            Spacer()
            
            horizontalControlButtons
        }
        .ignoresSafeArea(edges: .bottom)
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
    
    func counterDisplay(timeDisplayFormat: TimeDisplayFormat) -> some View {
        Text(viewModel.formattedCurrentTime(timeDisplayFormat: timeDisplayFormat))
            .font(theme.fonts.timerCounter)
            .minimumScaleFactor(0.01)
            .foregroundColor(Color("StartColor"))
    }
    
    var horizontalControlButtons: some View {
        HStack(spacing: 16) {
            startStopButton
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
            description: orientation.isLandscape ? nil : startButtonDescription.map { LocalizedStringKey($0) },
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
