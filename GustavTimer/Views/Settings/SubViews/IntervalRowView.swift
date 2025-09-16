//
//  IntervalRowView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 16.09.2025.
//

import SwiftUI

struct IntervalRowView: View {
    @Binding var intervalName: String
    @Binding var intervalValue: Int
    
    @Environment(\.theme) private var theme
    
    @FocusState private var nameIsFocused: Bool
    @FocusState private var valueIsFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("INTERVAL")
                        .font(theme.fonts.settingsCaption)
                        .foregroundStyle(theme.colors.light)
                    TextField("Name", text: $intervalName)
                        .font(theme.fonts.settingsIntervalName)
                        .focused($nameIsFocused)
                }
                
                Spacer(minLength: 50)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("INTERVAL_VALUE")
                        .font(theme.fonts.settingsCaption)
                        .foregroundStyle(theme.colors.light)
                    TextField("1-\(AppConfig.maxTimerValue)", value: $intervalValue, format: .number)
                        .keyboardType(.numberPad)
                        .font(theme.fonts.settingsIntervalValue)
                        .multilineTextAlignment(.trailing)
                        .focused($valueIsFocused)
                }
                .frame(maxWidth: 120)
            }
            
            if nameIsFocused || valueIsFocused {
                Button("DONE") {
                    nameIsFocused = false
                    valueIsFocused = false
                }
                .font(theme.fonts.settingsCaption)
                .foregroundStyle(.white)
                .padding(4)
                .padding(.horizontal, 10)
                .glassEffect(.regular.tint(theme.colors.pink).interactive())
            }
        }
    }
}
