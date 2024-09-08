//
//  SoundView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 05.09.2024.
//

import SwiftUI

struct SoundView: View {
    
    var soundThemeArray = ["sound1", "sound2", "sound3", "sound4", "sound5"]
    @StateObject var viewModel: GustavViewModel
    
    private let flexibleColumn = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: flexibleColumn, spacing: 10) {
                RoundedRectangle(cornerSize: CGSizeMake(10, 10))
                    .aspectRatio(1, contentMode: .fill)
                    .onTapGesture {
                        viewModel.isSoundOn = false
                    }
                    .foregroundColor(!viewModel.isSoundOn ? Color("StartColor") : Color.gray)
                    .overlay {
                        Text("no sound")
                    }
                ForEach(viewModel.soundThemeArray, id: \.self) { theme in
                    RoundedRectangle(cornerSize: CGSizeMake(10, 10))
                        .aspectRatio(1, contentMode: .fill)
                        .onTapGesture {
                            viewModel.isSoundOn = true
                            viewModel.activeSoundTheme = theme
                            SoundManager.instance.playSound(sound: .final, theme: theme)
                        }
                        .foregroundColor((viewModel.activeSoundTheme == theme && viewModel.isSoundOn) ? Color("StartColor") : Color.gray)
                        .overlay {
                            Text("\(theme)")
                        }
                }
            }
            .padding()
        }
    }
}

#Preview {
    SoundView(viewModel: GustavViewModel.shared)
}
