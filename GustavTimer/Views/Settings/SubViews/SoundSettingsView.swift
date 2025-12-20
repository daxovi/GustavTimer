//
//  SoundView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 05.09.2024.
//

import SwiftUI

struct SoundSettingsView: View {
    
    @Binding var selectedSound: SoundModel?
    @Environment(\.theme) private var theme
    
    @State var lastSelectedSound: SoundModel? = nil
    
    var body: some View {
            List {
                SettingsSection {
                    Toggle(isOn: .init(get: {
                        selectedSound != nil
                    }, set: { bool in
                        if bool {
                            selectedSound = lastSelectedSound ?? .beep
                        } else {
                            lastSelectedSound = selectedSound
                            selectedSound = nil
                        }
                    })) {
                        Text("IS_SOUND_ENABLED")
                    }
                    .tint(theme.colors.pink)
                }
                
                if selectedSound != nil {
                    SettingsSection(label: "SELECT_SOUND") {
                        ForEach(AppConfig.soundThemes, id: \.id) { soundTheme in
                            Button {
                                selectedSound = soundTheme
                                SoundManager.instance.playSound(soundModel: soundTheme)
                            } label: {
                                HStack {
                                    Text(soundTheme.title)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if selectedSound == soundTheme {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(theme.colors.pink)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .animation(.easeInOut, value: selectedSound)
            .font(theme.fonts.body)
            .toolbar{toolbar}
    }
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        if #available(iOS 26, *){
            ToolbarItem(placement: .title) {
                HStack {
                    Text("SOUND")
                        .font(theme.fonts.settingsNavbarTitle)
                }
                .padding(.vertical)
            }
        } else {
            // Fallback to earlier versions
            ToolbarItem(placement: .title) {
                HStack {
                    Text("SOUND")
                        .font(theme.fonts.settingsNavbarTitle)
                }
                .padding(.vertical)
            }
        }
    }

}

#Preview {
    SoundSettingsView(selectedSound: .constant(AppConfig.soundThemes.first!))
}
