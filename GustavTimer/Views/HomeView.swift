//
//  HomeView.swift
//  GustavTimer
//
//  Created by AI Assistant on 10.08.2024.
//

import SwiftUI

struct HomeView: View {
    @State private var timerViewModel: TimerViewModel
    @State private var showingTimersSheet = false
    @State private var showingSettingsSheet = false
    @Environment(\.scenePhase) var scenePhase
    
    init(timerViewModel: TimerViewModel) {
        self._timerViewModel = State(initialValue: timerViewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Timer Selection
                VStack(spacing: 10) {
                    if let currentTimer = timerViewModel.currentTimer {
                        Text(currentTimer.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Button("Select Different Timer") {
                            showingTimersSheet = true
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Text("No Timer Selected")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Button("Select Timer") {
                            showingTimersSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                // Current Interval Display
                if let currentInterval = timerViewModel.currentInterval {
                    VStack(spacing: 5) {
                        Text(currentInterval.title)
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text("Interval \(timerViewModel.currentIntervalIndex + 1) of \(timerViewModel.currentTimer?.intervals.count ?? 0)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Countdown Display
                VStack(spacing: 10) {
                    Text(timerViewModel.formattedRemainingTime)
                        .font(.system(size: 72, weight: .light, design: .monospaced))
                        .foregroundColor(timerViewModel.state == .running ? .primary : .secondary)
                    
                    // Progress Bar
                    ProgressView(value: timerViewModel.progress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .scaleEffect(x: 1, y: 4)
                }
                .padding(.horizontal)
                
                // Cycle Display (when loop is enabled)
                if timerViewModel.loopEnabled && timerViewModel.currentTimer != nil {
                    Text("Cycle \(timerViewModel.currentCycle)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Control Buttons
                VStack(spacing: 20) {
                    // Primary Controls
                    HStack(spacing: 20) {
                        Button(action: {
                            switch timerViewModel.state {
                            case .stopped, .paused:
                                timerViewModel.start()
                            case .running:
                                timerViewModel.pause()
                            }
                        }) {
                            Image(systemName: timerViewModel.state == .running ? "pause.fill" : "play.fill")
                                .font(.title)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(timerViewModel.currentTimer == nil)
                        
                        if timerViewModel.state == .paused {
                            Button("Resume") {
                                timerViewModel.resume()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        Button("Reset") {
                            timerViewModel.reset()
                        }
                        .buttonStyle(.bordered)
                        .disabled(timerViewModel.currentTimer == nil)
                    }
                    
                    // Secondary Controls
                    HStack(spacing: 15) {
                        Button("Prev") {
                            timerViewModel.previousInterval()
                        }
                        .buttonStyle(.bordered)
                        .disabled(timerViewModel.currentTimer == nil)
                        
                        Button("Restart") {
                            timerViewModel.restartCurrentInterval()
                        }
                        .buttonStyle(.bordered)
                        .disabled(timerViewModel.currentTimer == nil)
                        
                        Button("Next") {
                            timerViewModel.nextInterval()
                        }
                        .buttonStyle(.bordered)
                        .disabled(timerViewModel.currentTimer == nil)
                    }
                    
                    // Favorite Toggle
                    if let currentTimer = timerViewModel.currentTimer {
                        Button(action: {
                            // Toggle favorite status would go here
                            // This would require repository access - could be handled through a callback
                        }) {
                            Image(systemName: currentTimer.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(currentTimer.isFavorite ? .red : .secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .padding()
            .navigationTitle("Interval Trainer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Settings") {
                        showingSettingsSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingTimersSheet) {
                TimersListView(timerViewModel: timerViewModel)
            }
            .sheet(isPresented: $showingSettingsSheet) {
                SettingsView()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            timerViewModel.handleScenePhaseChange(newPhase)
        }
    }
}