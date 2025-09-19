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
    @State var selectedTab: Int = 0
    
    var body: some View {
            TabView(selection: $selectedTab) {
                Tab("INTERVALS_TAB", systemImage: "timer", value: 0) {
                    IntervalsTabView()
                }
                Tab("FAVOURITES_TAB", systemImage: "star.fill", value: 1) {
                    FavouritesTabView()
                }
                Tab("SETTINGS_TAB", systemImage: "gearshape", value: 2) {
                    SettingsTabView()
                }
                Tab("WHATSNEW_TAB", systemImage: "iphone.app.switcher", value: 3) {
                    Text("Whats New")
                }
                Tab(value: 4, role: .search) {
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
