//
//  GustavTimerApp.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 19.04.2023.
//

import SwiftUI
import SwiftData
import BackgroundTasks

@main
struct GustavTimerApp: App {
    
    @Environment(\.scenePhase) private var phase

    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [CustomImageModel.self])
        .onChange(of: phase, { oldValue, newPhase in
            switch newPhase {
            case .background: startBackgroundTask()
            default: break
            }
        })
    }
    
    func startBackgroundTask() {
        var backgroundTask: UIBackgroundTaskIdentifier = .invalid
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}
