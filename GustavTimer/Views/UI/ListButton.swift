//
//  ListButton.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 22.09.2024.
//

import SwiftUI

struct ListButton: View {
    var name: String
    var value: String = ""
    
    @Environment(\.theme) var theme
    
    var body: some View {
        HStack {
            Text(NSLocalizedString(name, comment: ""))
            Spacer()
            Text(NSLocalizedString(value, comment: ""))
                .foregroundColor(Color("ResetColor"))
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
