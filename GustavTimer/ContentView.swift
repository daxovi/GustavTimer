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
    @AppStorage("selectedBackgroundIndex") private var selectedBackgroundIndex: Int = 0
    @AppStorage("activeTimerId") private var activeTimerId: Int = 0
    @AppStorage("selectedSound") private var selectedSound: String = "beep"
    @AppStorage("isSoundEnabled") private var isSoundEnabled: Bool = true
    
    @State private var showSettings = false
    
    var body: some View {
        TimerView(showSettings: $showSettings)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
