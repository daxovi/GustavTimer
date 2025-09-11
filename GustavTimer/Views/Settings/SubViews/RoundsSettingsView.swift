//
//  RoundsSettingsView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 11.09.2025.
//

import SwiftUI

struct RoundsSettingsView: View {
    @Binding var rounds: Int
    @State var lastRoundOption: Int = 1
    
    @Environment(\.theme) private var theme
    
    var body: some View {
        List {
            Section {
                Toggle(isOn: .init(get: {
                    rounds == -1
                }, set: { value in
                    rounds = value ? -1 : lastRoundOption
                })) {
                    Text("IS_LOOPING")
                }
            }
            
            if rounds != -1 {
                Section {
                    ForEach(AppConfig.roundsOptions, id: \.self) { roundOption in
                        Button {
                            rounds = roundOption
                            lastRoundOption = roundOption
                        } label: {
                            HStack {
                                Text("\(roundOption)")
                                    .foregroundColor(.primary)
                                Spacer()
                                if rounds == roundOption {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(theme.colors.pink)
                                }
                            }
                        }
                    }
                } header: {
                    Text("SELECT_ROUNDS_NUMBER")
                }
            }
        }
    }
}

#Preview {
    RoundsSettingsView(rounds: .constant(3))
}
