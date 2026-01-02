//
//  GustavTimerApp.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 19.04.2023.
//

import SwiftUI
import SwiftData
import GustavUI

@main
struct GustavTimerApp: App {
    
    init() {
        GustavDesign.registerFonts()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [CustomImageModel.self, TimerData.self])
    }
}
