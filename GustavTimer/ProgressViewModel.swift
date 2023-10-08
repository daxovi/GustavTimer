//
//  ProgressViewModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 08.10.2023.
//

import Foundation
import Combine

class ProgressViewModel:ObservableObject {

    init() {
        
    }
    /*
    private func countProgressRatio(timerIndex: Int) -> Double {
        let sum = Double(timers.reduce(0, +))
        if timers.count > timerIndex {
            return Double(timers[timerIndex])/sum
        } else {
            return 0
        }
    }
    
    func getProgressBarWidth(geometry: GeometryProxy, timerIndex: Int) -> Double {
        let width = geometry.size.width - ((CGFloat(timers.count) - 1) * 5)
        if timerIndex < timers.count {
            return width * countProgressRatio(timerIndex: timerIndex)
        } else {
            return 0.0
        }
    }
     */
}
