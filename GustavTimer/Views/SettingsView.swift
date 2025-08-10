//
//  SettingsView.swift
//  GustavTimer
//
//  Created by AI Assistant on 10.08.2024.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("loopEnabled") private var loopEnabled: Bool = false
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("soundsEnabled") private var soundsEnabled: Bool = true
    @AppStorage("timeFormat") private var timeFormat: String = "mm:ss"
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Timer Behavior") {
                    Toggle("Loop Enabled", isOn: $loopEnabled)
                        .help("When enabled, timer will restart from the first interval after completing all intervals")
                }
                
                Section("Feedback") {
                    Toggle("Haptics Enabled", isOn: $hapticsEnabled)
                        .help("Vibration feedback when intervals complete")
                    
                    Toggle("Sounds Enabled", isOn: $soundsEnabled)
                        .help("Audio feedback when intervals complete")
                }
                
                Section("Display") {
                    Picker("Time Format", selection: $timeFormat) {
                        Text("Seconds (45)").tag("ss")
                        Text("Minutes:Seconds (1:25)").tag("mm:ss")
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    // Preview section showing current format
                    HStack {
                        Text("Preview:")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(formatPreviewTime())
                            .font(.system(.title3, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                } header: {
                    Text("Time Format Preview")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatPreviewTime() -> String {
        let sampleDuration = Duration.seconds(125) // 2:05 or 125s
        let seconds = Int(sampleDuration.components.seconds)
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        if timeFormat == "ss" {
            return String(format: "%d", seconds)
        } else {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }
    }
}

#Preview {
    SettingsView()
}