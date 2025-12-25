//
//  OnboardingPageView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 25.12.2025.
//

import SwiftUI

struct OnboardingPageView: View {
    var title: String? = nil
    var description: String? = nil
    var mediaFilename: String? = nil
    let actionLabel: String
    let action: () -> Void
    
    @Environment(\.theme) var theme
    
    var body: some View {
        ZStack {
            if let mediaFilename {
                // TODO: přidej mi video z bundle s názvem mediaFilename .mp4 a přehrávej ho v loopu
                // TODO: pokud nenajde v bundle video s mp4 tak najdi Asset pod stejným názvem a zobraz ten obrázek
            } else {
                Color.black
                    .ignoresSafeArea()
            }
            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                
                if let title {
                    Text(title)
                        .font(theme.fonts.onboardingTitle)
                }
                
                if let description {
                    Text(description)
                }
                    
                Button(action: action) {
                    Text(actionLabel)
                }
                .padding(.vertical)
            }
            .padding(24)
            .font(theme.fonts.body)
            .lineSpacing(4)
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    OnboardingPageView(
        title: "Vlastní tréninky",
        description: "Poskládej si vlastní intervaly, pauzy a opakování. Každý blok si můžeš pojmenovat, nastavit opakování a upozornění.", mediaFilename: nil,
        actionLabel: "Pokračuj") {
            //
        }
}
