//
//  ProgressView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 01.10.2023.
//

import SwiftUI

struct ProgressView: View {
    @ObservedObject var viewModel: GustavViewModel
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 5) {
                ForEach(Array(viewModel.timers.enumerated()), id: \.offset) { index, timer in
                    if index == viewModel.activeTimerIndex {
                        ProgressBarView(progress: $viewModel.progress)
                            .frame(width: viewModel.getProgressBarWidth(geometry: geometry, timerIndex: index))
                    } else if index < viewModel.activeTimerIndex {
                        ProgressBarView(progress: .constant(1.0))
                            .frame(width: viewModel.getProgressBarWidth(geometry: geometry, timerIndex: index))
                    } else {
                        ProgressBarView(progress: .constant(0.0))
                            .frame(width: viewModel.getProgressBarWidth(geometry: geometry, timerIndex: index))
                    }
                }
            }
        }
        .padding(.horizontal)
        .frame(height: CGFloat(viewModel.progressBarHeight))
    }
}
