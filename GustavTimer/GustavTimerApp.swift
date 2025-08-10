//
//  GustavTimerApp.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 19.04.2023.
//

import SwiftUI
import SwiftData

@main
struct GustavTimerApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: TimerTemplate.self)
    }
}
