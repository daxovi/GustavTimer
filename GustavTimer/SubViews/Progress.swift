//
//  ProgressView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 01.10.2023.
//

import SwiftUI

struct ProgressView: View {
    @StateObject var viewModel: GustavViewModel
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 5) {
                ForEach(Array(viewModel.timers.enumerated()), id: \.offset) { index, timer in
                    ProgressView(value: (index == viewModel.activeTimerIndex) ? $viewModel.progress : (index < viewModel.activeTimerIndex) ? .constant(1.0) : .constant(0.0), total: $viewModel.duration)
                }
            }
        }
        .padding(.horizontal)
        .frame(height: CGFloat(viewModel.progressBarHeight))
    }
}
