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
            Text("01")
            Text("02")
        }
        .tabViewStyle(.page)
    }
    
    func next() {
        if selection < 2 {
            selection += 1
        } else {
            dismiss()
        }
    }
}

#Preview {
    OnboardingView()
}
