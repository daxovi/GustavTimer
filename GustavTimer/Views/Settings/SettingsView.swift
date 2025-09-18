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
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    @Environment(\.theme) var theme
    
    @State private var searchText: String = ""
    
    var body: some View {
        TabView {
            IntervalsTabView()
            .tabItem {
                Label("INTERVALS_TAB", systemImage: "timer")
            }
            
            FavouritesTabView()
            .tabItem {
                Label("FAVOURITES_TAB", systemImage: "star.fill")
            }
            
            SettingsTabView()
            .tabItem {
                Label("SETTINGS_TAB", systemImage: "gearshape")
            }
            
            Text("Whats New")
                .tabItem {
                    Label("WHATSNEW_TAB", systemImage: "iphone.app.switcher")
                }
            
            NavigationStack {
                Text("Search")
                Text(searchText)
            }
            .searchable(text: $searchText)
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
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
