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
        VStack(spacing: 8) {
            Text("FAVOURITES_EMPTY_LABEL")
                .multilineTextAlignment(.center)
                .font(theme.fonts.emptyLabel)
                .foregroundStyle(theme.colors.light)
            Text("FAVOURITES_EMPTY_SUBTITLE")
                .multilineTextAlignment(.center)
                .font(theme.fonts.emptySubtitle)
                .foregroundStyle(theme.colors.light)
        }
        .padding()
        .frame(height: 150)
        .frame(maxWidth: .infinity, minHeight: 44)
        .listRowBackground(theme.colors.white)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

#Preview {
    List {
        FavouritesEmptyView()
    }
}
