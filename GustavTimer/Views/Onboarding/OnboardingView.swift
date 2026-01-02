//
//  OnboardingView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 25.12.2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var selection: Int = 0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        TabView(selection: $selection) {
            OnboardingPageView(
                title: "OB_TIMER_TITLE",
                description: "OB_TIMER_DESCRIPTION",
                mediaFilename: nil,
                actionLabel: "OB_CONTINUE") {
                    next()
                }
                .tag(0)
            
            OnboardingPageView(
                title: "OB_FAVOURITES_TITLE",
                description: "OB_FAVOURITES_DESCRIPTION",
                mediaFilename: nil,
                actionLabel: "OB_CONTINUE") {
                    next()
                }
                .tag(1)
            
            OnboardingPageView(
                title: "OB_GUSTAV_TITLE",
                description: "OB_GUSTAV_DESCRIPTION",
                mediaFilename: "fristensky",
                actionLabel: "OB_FINISH") {
                    next()
                }
                .tag(2)
            
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .ignoresSafeArea()
        .background {
            Color.black.ignoresSafeArea()
        }
    }
    
    func next() {
        if selection < 2 {
            withAnimation {
                selection += 1
            }
        } else {
            dismiss()
        }
    }
}

#Preview {
    OnboardingView()
}
