//
//  ProgressView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 01.10.2023.
//

import SwiftUI

struct ProgressView: View {
    @ObservedObject var gustavViewModel: GustavViewModel
  //  @ObservedObject var viewModel = ProgressViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 5) {
                ForEach(Array(gustavViewModel.timers.enumerated()), id: \.offset) { index, timer in
                    if index == gustavViewModel.activeTimerIndex {
                        ProgressBarView(progress: $gustavViewModel.progress)
                            .frame(width: gustavViewModel.getProgressBarWidth(geometry: geometry, timerIndex: index))
                    } else if index < gustavViewModel.activeTimerIndex {
                        ProgressBarView(progress: .constant(1.0))
                            .frame(width: gustavViewModel.getProgressBarWidth(geometry: geometry, timerIndex: index))
                    } else {
                        ProgressBarView(progress: .constant(0.0))
                            .frame(width: gustavViewModel.getProgressBarWidth(geometry: geometry, timerIndex: index))
                    }
                }
            }
        }
        .padding(.horizontal)
        .frame(height: 8)
    }
}
