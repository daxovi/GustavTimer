//
//  Laps.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 13.07.2024.
//

import SwiftUI

struct Laps: View {
    @StateObject var viewModel: GustavViewModel
    
    private func move(from source: IndexSet, to destination: Int) {
        viewModel.timers.move(fromOffsets: source, toOffset: destination)
    }
    
    private func delete(at offsets: IndexSet) {
        if viewModel.timers.count > 1 {
            viewModel.timers.remove(atOffsets: offsets)
        }
    }
    
    var body: some View {
        ForEach(viewModel.timers.indices, id: \.self) { index in
            TimerRow(timer: $viewModel.timers[index], index: index, maxCountdownValue: viewModel.maxCountdownValue)
        }
        .onMove(perform: move)
        .onDelete(perform: delete)
    }
}
