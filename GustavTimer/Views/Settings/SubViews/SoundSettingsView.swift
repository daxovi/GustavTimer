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
                Section {
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
                    Section {
                        ForEach(AppConfig.soundThemes, id: \.id) { soundTheme in
                            Button {
                                selectedSound = soundTheme
                                SoundManager.instance.playSound(sound: .final, soundModel: soundTheme)
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
                    } header: {
                        Text("SELECT_SOUND")
                    }
                }
            }
            .animation(.easeInOut, value: selectedSound)
    }
}

#Preview {
    SoundSettingsView(selectedSound: .constant(AppConfig.soundThemes.first!))
}
