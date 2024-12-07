//
//  HashtagBadge.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 07.12.2024.
//

import SwiftUI

struct Tag: View {
    var label: String
    var isHighlighted: Bool
    var action: (() -> Void)?
    
    init(_ label: String, isHighlighted: Bool = false, action: (() -> Void)? = nil) {
        self.label = label
        self.isHighlighted = isHighlighted
        self.action = action
    }
    
    var body: some View {
                Text(label)
                    .padding(7)
                    .padding(.horizontal, 4)
                    .font(Font.custom("MartianMono-Regular", size: 12))
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(
                                Color(isHighlighted ? .accent : .white)
                                    .shadow(.inner(color: .black.opacity(0.35), radius: 1, x: 0, y: 1))
                            )
                    )
                    .foregroundStyle(Color("ResetColor"))
                    .onTapGesture { action?() }
                    .textCase(.uppercase)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
        HStack {
            Tag("#whatsnew")
            Tag("#monthly")
            Tag("V1.3", isHighlighted: true)

        }
    }
}
