//
//  FavouritesItemView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 06.09.2025.
//

import SwiftUI

struct FavouritesItemView: View {
    let timer: TimerData
    let onDelete: (() -> Void)
    let onSelect: (() -> Void)
    
    @Environment(\.theme) var theme
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 5) {
                    ForEach(timer.intervals) { interval in
                        VStack(alignment: .leading) {
                            Capsule()
                                .fill(theme.colors.volt)
                                .frame(height: 5)
                            Text(interval.name)
                                .font(theme.fonts.settingsCaption)
                                .lineLimit(1)
                                .padding(.trailing)
                                .foregroundStyle(theme.colors.light)
                        }
                    }
                }
                .padding(.top, 10)
                HStack {
                    Text(timer.name)
                        .font(theme.fonts.settingsLabelLarge)
                        .padding(.trailing, 4)
                    
                    theme.icons.loop
                        .frame(width: 22, height: 22)
                        .foregroundStyle(theme.colors.light)
                    
                    theme.icons.loop
                        .frame(width: 22, height: 22)
                        .foregroundStyle(theme.colors.light)
                    
                    Spacer()
                    
                    Image(systemName: "bin.xmark")
                        .foregroundStyle(.red)
                        .onTapGesture {
                            onDelete()
                        }
                }
            }
            .onTapGesture {
                onSelect()
            }
        }
    }
}

#Preview {
    List {
        FavouritesItemView(timer: .init(id: 4, name: "name"), onDelete: {}, onSelect: {})
    }
}
