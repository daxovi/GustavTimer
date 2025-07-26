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
    
    var body: some View {
        HStack {
            Text(NSLocalizedString(name, comment: ""))
            Spacer()
            Text(NSLocalizedString(value, comment: ""))
                .foregroundColor(Color("ResetColor"))
        }
    }
}
