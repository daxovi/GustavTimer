//
//  HintButton.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 08.09.2024.
//

import SwiftUI

struct HintButton: View {
    var labelText: String
    var action: () -> ()
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            Text(labelText)
                .underline()
                .opacity(0.5)
        })
        .buttonStyle(PlainButtonStyle())
    }
}
