//
//  ContentView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 19.04.2023.
//

import SwiftUI
import StoreKit
import SwiftData

struct ContentView: View {
    @Query var timerData: [TimerData]
    
    @Environment(\.modelContext) var context
    
    @AppStorage("selectedBackgroundIndex") private var selectedBackgroundIndex: Int = 0
    @AppStorage("activeTimerId") private var activeTimerId: Int = 0
    @AppStorage("selectedSound") private var selectedSound: String = "beep"
    @AppStorage("isSoundEnabled") private var isSoundEnabled: Bool = true
    
    @State private var showSettings = false
    
    private var defaultTimerId: Int = 0
    
    var body: some View {
        TimerView(showSettings: $showSettings)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onAppear {
                initializeDataIfNeeded()
            }
    }
    
    private func initializeDataIfNeeded() {
        if timerData.isEmpty {
            let defaultTimer = TimerData(id: defaultTimerId)
            context.insert(defaultTimer)
            print("DEBUG: Default timer created with id: \(defaultTimerId)")
            try? context.save()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: [CustomImageModel.self, TimerData.self])
    }
}
