//
//  WhatsNewView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 07.12.2024.
//

import SwiftUI

struct WhatsNewView<Content: View>: View {
    var buttonLabel: LocalizedStringKey
    var action: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @ViewBuilder var content: Content
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray5)
            VStack {
                Image("monthly1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Spacer()
            }
            VStack {
                Spacer()
                HStack {
                    Tag("#whatsnew")
                    Tag("v1.3")
                    Spacer()
                }
                .safeAreaPadding(.horizontal)
                content
                    .safeAreaPadding(.horizontal)
                ControlButton(action: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        action()
                    }
                }, text: buttonLabel, color: .start)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    WhatsNewView(buttonLabel: "enter challenge", action: {}) {
        VStack {
            HStack {
                    Text("2025")
                Spacer()
            }
            HStack {
                    Text("Monthly")
                Spacer()
            }
            HStack {
                    Text("Challenge")
                Spacer()
            }
        }
    }
    .ignoresSafeArea()
}
