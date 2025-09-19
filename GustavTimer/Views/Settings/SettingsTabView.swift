//
//  SettingsTabView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 16.09.2025.
//

import SwiftUI

struct SettingsTabView: View {
    @ObservedObject var appSettings = AppSettings()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.theme) private var theme
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("HAPTICS", isOn: $appSettings.isVibrating)
                        .tint(theme.colors.pink)
                    
                    NavigationLink {
                        SoundSettingsView(isSoundEnabled: $appSettings.isSoundEnabled, selectedSound: $appSettings.selectedSound)
                    } label: {
                        ListButton(name: "SOUND", value: appSettings.isSoundEnabled ? LocalizedStringKey(appSettings.selectedSound) : "MUTE")
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
                    
                    Button("TRY_WEIGHTS") {
                        if let url = URL(string: AppConfig.weightsURL) {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    Button("FOLLOW_INSTAGRAM") {
                        if let url = URL(string: "https://www.instagram.com/gustavtraining") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .largeTitle) {
                    HStack {
                        Text("SETTINGS_TAB")
                            .font(theme.fonts.settingsLargeTitle)
                        Spacer()
                    }
                    .padding(.vertical)
                }

                ToolbarItem(placement: .navigationBarLeading) {
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
