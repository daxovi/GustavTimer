//
//  ControlButtonsView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 15.09.2024.
//

import SwiftUI

struct ControlButtonsView: View {
    @StateObject var viewModel = GustavViewModel.shared
    @Environment(\.requestReview) var requestReview
    
    var body: some View {
        HStack(spacing: 0) {
            ControlButton(action: {
                viewModel.startStopTimer(requestReview: {requestReview()})
            }, text: viewModel.isTimerRunning ? "STOP" : "START")
            if viewModel.isTimerRunning {
                ControlButton(action: { viewModel.skipLap() }, text: "SKIP")
            } else {
                ControlButton(action: { viewModel.resetTimer() }, text: "RESET")
            }
        }
    }
}

#Preview {
    ControlButtonsView()
}