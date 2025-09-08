//
//  SoundView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 05.09.2024.
//

import SwiftUI

struct SoundSelectorView: View {
    
    @Binding var isSoundEnabled: Bool
    @Binding var selectedSound: String
    
    @Environment(\.theme) private var theme
    
    var body: some View {
            List {
                Section {
                    Toggle(isOn: $isSoundEnabled) {
                        Text("IS_SOUND_ENABLED")
                    }
                }
                
                Section {
                    ForEach(AppConfig.soundThemes, id: \.self) { soundTheme in
                        Button {
                            selectedSound = soundTheme
                            SoundManager.instance.playSound(sound: .final, theme: soundTheme)
                        } label: {
                            HStack {
                                Text(soundTheme)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedSound == soundTheme {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(theme.colors.volt)
                                }
                            }
                        }
                    }
                }
            }
    }
}

#Preview {
    SoundSelectorView(isSoundEnabled: .constant(true), selectedSound: .constant("Gustav"))
}
