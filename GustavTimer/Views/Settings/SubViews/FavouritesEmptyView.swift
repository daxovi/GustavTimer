//
//  EmptyFavouritesView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 06.09.2025.
//

import SwiftUI

struct FavouritesEmptyView: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        Text("FAVOURITES_EMPTY_MESSAGE")
            .multilineTextAlignment(.center)
            .padding()
            .frame(height: 120)
            .font(theme.fonts.buttonLabelSmall)
            .frame(maxWidth: .infinity, minHeight: 44)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 1)
                    .stroke(theme.colors.light, style: StrokeStyle(lineWidth: 2, dash: [8, 8]))
            )
            .foregroundStyle(theme.colors.light)
            .listRowBackground(Color.clear)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}
