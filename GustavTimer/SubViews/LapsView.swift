//
//  Laps.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 13.07.2024.
//

import SwiftUI

struct LapsView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var bgLapOpacity: [Int: Double] = [:] // Mapujeme indexy na opacity
    @Environment(\.colorScheme) var colorScheme


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
            let timer = viewModel.timers[index]
            NavigationLink {
                LapDetailView(timer: timer, viewModel: viewModel)
            } label: {
                ListButton(name: timer.name, value: "\(timer.value)")

            }
            .listRowBackground(
            ZStack {
                Color(colorScheme == .dark ? UIColor.secondarySystemBackground : .white)
                if viewModel.startedFromDeeplink {
                    Color("StartColor").opacity(bgLapOpacity[index] ?? 1.0)
                        .animation(.easeInOut(duration: 0.4))
                    }
                }
                
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(index) * 0.2) {
                        bgLapOpacity[index] = 0 // Animace opacity pro každý řádek
                }
            }
        }
        .onMove(perform: move)
        .onDelete(perform: viewModel.timers.count > 1 ? delete : nil)

    }
}
