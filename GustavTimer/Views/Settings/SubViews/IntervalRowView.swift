//
//  IntervalRowView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 16.09.2025.
//

import SwiftUI
import GustavUI

struct IntervalRowView: View {
    @Binding var intervalName: String
    @Binding var intervalValue: Int
        
    @FocusState private var nameIsFocused: Bool
    @FocusState private var valueIsFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("INTERVAL")
                        .font(.settingsCaption)
                        .foregroundStyle(Color.gustavLight)
                    TextField("INTERVAL_NAME_PROMPT", text: $intervalName)
                        .font(.settingsIntervalName)
                        .focused($nameIsFocused)
                }
                
//                Spacer(minLength: 50)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("INTERVAL_VALUE")
                        .font(.settingsCaption)
                        .foregroundStyle(Color.gustavLight)
                    TextField("1-\(AppConfig.maxTimerValue)", value: $intervalValue, format: .number)
                        .keyboardType(.numberPad)
                        .font(.settingsIntervalValue)
                        .multilineTextAlignment(.trailing)
                        .focused($valueIsFocused)
                }
                .frame(maxWidth: 120)
            }
            
            if nameIsFocused || valueIsFocused {
                GustavSmallPillButton(label: "DONE") {
                    nameIsFocused = false
                    valueIsFocused = false
                }
            }
        }
    }
}
