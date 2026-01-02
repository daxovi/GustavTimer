//
//  SettingsSection.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 11.11.2025.
//

import SwiftUI
import GustavUI

struct SettingsSection<Content: View>: View {
    var label: LocalizedStringKey? = nil
    @ViewBuilder let content: () -> Content
    @Environment(\.theme) private var theme
    
    var body: some View {
        if let label {
            Section(header: Text(label)
                .font(.sectionHeader)
                .foregroundStyle(Color.gustavNeutral)) {
                content()
            }
        } else {
            Section {
                content()
            }
        }
    }
}
