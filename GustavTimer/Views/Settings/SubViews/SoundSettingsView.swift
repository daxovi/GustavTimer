//
//  SoundView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 05.09.2024.
//

import SwiftUI
import GustavUI

struct SoundSettingsView: View {
    
    @Binding var selectedSound: SoundModel?    
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
                    .tint(Color.gustavPink)
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
                                            .foregroundColor(Color.gustavPink)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .animation(.easeInOut, value: selectedSound)
            .font(.gustavBody)
            .toolbar{toolbar}
    }
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        if #available(iOS 26, *){
            ToolbarItem(placement: .title) {
                HStack {
                    Text("SOUND")
                        .font(.settingsNavbarTitle)
                }
                .padding(.vertical)
            }
        } else {
            // Fallback to earlier versions
            ToolbarItem(placement: .title) {
                HStack {
                    Text("SOUND")
                        .font(.settingsNavbarTitle)
                }
                .padding(.vertical)
            }
        }
    }

}

#Preview {
    SoundSettingsView(selectedSound: .constant(AppConfig.soundThemes.first!))
}
