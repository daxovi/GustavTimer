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
    @State var showTimer: Bool = false
    
    @Namespace var animation
    var body: some View {
        ZStack {
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
                    SearchTabView(searchText: $searchText)
                        .searchable(text: $searchText)
                }
            }
            .tint(theme.colors.pink)
            .font(theme.fonts.body)
            .tabBarMinimizeBehavior(.onScrollDown)
            .tabViewBottomAccessory {
                ZStack {
                    BackgroundImageView()
                        .matchedGeometryEffect(id: "background", in: animation, isSource: !showTimer)

                    HStack {
                        Text("START")
                            .font(theme.fonts.buttonLabel)
                            .foregroundStyle(theme.colors.neutral)
                            .frame(maxHeight: .infinity)
                            .padding(.horizontal, 18)
                            .glassEffect(.regular.tint(theme.colors.volt).interactive())
                            .matchedGeometryEffect(id: "button", in: animation, isSource: !showTimer)
                        .padding(4)
                        Spacer()
                        let mainTimer = timerData.first { $0.order == AppConfig.defaultTimer.order }
                        Text(mainTimer?.intervals.first?.value.formatted() ?? "")
                            .font(theme.fonts.timerCounter)
                            .minimumScaleFactor(0.01)
                            .foregroundStyle(theme.colors.volt)
                            .padding(2)
                            .padding(.trailing)
                            .matchedGeometryEffect(id: "number", in: animation, isSource: !showTimer)
                            
                    }
                }
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.3)) {
                            showTimer = true
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .clipped()
            }
            
            if showTimer {
                TimerView(namespace: animation, dismiss: {
                    withAnimation(.spring(duration: 0.2)) {
                        showTimer = false
                    }
                })
//                .matchedGeometryEffect(id: "background", in: animation, isSource: true)
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [CustomImageModel.self, TimerData.self])
}

struct CustomAccessoryView: View {
    @Environment(\.tabViewBottomAccessoryPlacement) var tabViewBottomAccessoryPlacement
    var namespace: Namespace.ID

    var body: some View {
        switch tabViewBottomAccessoryPlacement {
        case .expanded:
            ZStack {
                BackgroundImageView()
                    .matchedGeometryEffect(id: "background", in: namespace, isSource: false)
                ControlButton(action: {
                    //
                }, label: "START")
                .padding(4)
                .frame(width: 200)
            }
        default:
            Text("Limited space")
        }
    }
}
