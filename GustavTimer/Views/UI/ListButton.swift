//
//  ListButton.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 22.09.2024.
//

import SwiftUI

struct ListButton: View {
    var name: LocalizedStringKey
    var value: LocalizedStringKey?
    
    @Environment(\.theme) var theme
    
    var body: some View {
        HStack {
            Text(name)
            Spacer()
            if let value {
                Text(value)
                    .foregroundColor(Color("ResetColor"))
            }
        }
        .font(theme.fonts.body)
    }
}

#Preview {
    List {
        NavigationLink {
            Text("Destination")
        } label: {
            ListButton(name: "Hello", value: "World")
        }
    }
}
