//  SettingsView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 01.10.2023.
//

import SwiftUI
import AVFoundation
import _AVKit_SwiftUI
import SwiftData

struct SettingsView: View {
    @Query(sort: \TimerData.id, order: .reverse) var timerData: [TimerData]
//    @StateObject var viewModel = SettingsViewModel()
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    @Environment(\.theme) var theme
    
    @State private var searchText: String = ""
    
    var body: some View {
        TabView {
            Tab("INTERVALS_TAB", systemImage: "timer") {
                IntervalsTabView()
            }
            Tab("FAVOURITES_TAB", systemImage: "star.fill") {
                FavouritesTabView()
            }
            Tab("SETTINGS_TAB", systemImage: "gearshape") {
                SettingsTabView()
            }
            Tab("WHATSNEW_TAB", systemImage: "iphone.app.switcher") {
                Text("Whats New")
            }
            Tab(role: .search) {
                NavigationStack {
                    Text("Search")
                    Text(searchText)
                }
                .searchable(text: $searchText)
            }
        }
        .tint(theme.colors.pink)
        .font(theme.fonts.body)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [CustomImageModel.self, TimerData.self])
}

