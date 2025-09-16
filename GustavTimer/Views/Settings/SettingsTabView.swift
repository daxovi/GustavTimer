//
//  SettingsTabView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 16.09.2025.
//

import SwiftUI

struct SettingsTabView: View {
    @AppStorage("isVibrating") var isVibrating: Bool = false
    @AppStorage("selectedSound") var selectedSound: String = "beep"
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.theme) private var theme
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("HAPTICS", isOn: $isVibrating)
                        .tint(theme.colors.pink)
                    
                    NavigationLink {
                        SoundSettingsView(isSoundEnabled: $isSoundEnabled, selectedSound: $selectedSound)
                    } label: {
                        ListButton(name: "SOUND", value: isSoundEnabled ? LocalizedStringKey(selectedSound) : "MUTE")
                    }
                    
                    //            NavigationLink {
                    //                TimeDisplayFormatView()
                    //            } label: {
                    //                ListButton(name: "Time Format", value: viewModel.timeDisplayFormat.displayName)
                    //            }
                    //
                    //            NavigationLink {
                    //                BackgroundSelectorView()
                    //            } label: {
                    //                ListButton(name: "BACKGROUND")
                    //            }
                }
                
                Section {
                    Button("RATE") {
                        if let url = URL(string: AppConfig.reviewURL) {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    Button("Try Gustav Weights") {
                        if let url = URL(string: AppConfig.weightsURL) {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    Button("Follow Gustav on Instagram") {
                        if let url = URL(string: "https://www.instagram.com/gustavtraining") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
            .navigationTitle("SETTINGS_TAB")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .close) {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}
