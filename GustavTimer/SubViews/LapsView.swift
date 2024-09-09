//
//  Laps.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 13.07.2024.
//

import SwiftUI

struct LapsView: View {
    @StateObject var viewModel: GustavViewModel
    @Environment(\.presentationMode) var presentationMode
    
    private func move(from source: IndexSet, to destination: Int) {
        viewModel.timers.move(fromOffsets: source, toOffset: destination)
    }
    
    private func delete(at offsets: IndexSet) {
        if viewModel.timers.count > 1 {
            viewModel.timers.remove(atOffsets: offsets)
        }
    }
    
    private func isLastTimer() -> Bool {
        return viewModel.timers.count <= 1
    }
    
    var body: some View {
        ForEach(viewModel.timers) { timer in
            NavigationLink {
                LapDetailView(timer: timer, viewModel: viewModel)
            } label: {
                HStack {
                    Text("\(timer.name)")
                    Spacer()
                    Text("\(timer.value)")
                        .foregroundColor(Color("ResetColor"))
                }
            }
        }
        .onMove(perform: move)
        .onDelete(perform: viewModel.timers.count > 1 ? delete : nil)
    }
}
