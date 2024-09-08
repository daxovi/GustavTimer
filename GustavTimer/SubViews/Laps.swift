//
//  Laps.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 13.07.2024.
//

import SwiftUI

struct Laps: View {
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
        ForEach(viewModel.timers.indices, id: \.self) { index in
            NavigationLink {
                LapDetail(index: index, viewModel: viewModel)
            } label: {
                HStack {
                    Text("\(viewModel.timers[index].name)")
                    Spacer()
                    Text("\(viewModel.timers[index].value)")
                        .foregroundColor(Color("StopColor"))
                        .font(Font.custom("MartianMono-Bold", size: 15))
                }
            }
        }
        .onMove(perform: move)
        .onDelete(perform: delete)
    }
}
