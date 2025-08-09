//
//  TimeDisplayFormatView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 26.07.2025.
//

import SwiftUI

struct TimeDisplayFormatView: View {
    
    @AppStorage("timeDisplayFormat") private var timeDisplayFormat: TimeDisplayFormat = .seconds
    
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(TimeDisplayFormat.allCases, id: \.self) { format in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(format.displayName)
                            .font(theme.fonts.body)
                            .foregroundColor(.primary)
                        
                        Text(exampleText(for: format))
                            .font(theme.fonts.settingsCaption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: timeDisplayFormat == format ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(timeDisplayFormat == format ? theme.colors.volt : .secondary)
                        .font(.title2)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(timeDisplayFormat == format ? theme.colors.volt.opacity(0.1) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(timeDisplayFormat == format ? theme.colors.volt : Color.clear, lineWidth: 2)
                )
                .onTapGesture {
                    timeDisplayFormat = format
                }
                .animation(.easeInOut, value: timeDisplayFormat)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Time Format")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func exampleText(for format: TimeDisplayFormat) -> String {
        switch format {
        case .seconds:
            return "Example: 30, 29, 28..."
        case .minutesSecondsHundredths:
            return "Example: 1:30.5, 1:30.4, 1:30.3..."
        }
    }
}

#Preview {
    NavigationView {
        TimeDisplayFormatView()
    }
}