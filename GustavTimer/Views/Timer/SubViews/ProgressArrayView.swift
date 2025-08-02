//
//  ProgressArrayView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 01.10.2023.
//

import SwiftUI

struct ProgressArrayView: View {
    @StateObject var viewModel: TimerViewModel
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 5) {
                ForEach(Array(viewModel.timers.enumerated()), id: \.offset) { index, timer in
                    ProgressBar(progress: (index == viewModel.activeTimerIndex) ? $viewModel.progress : (index < viewModel.activeTimerIndex) ? .constant(1.0) : .constant(0.0))
                        .frame(width: viewModel.getProgressBarWidth(geometry: geometry, timerIndex: index))
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                }
            }
        }
        .padding(.horizontal)
        .frame(height: 6)
    }
}
