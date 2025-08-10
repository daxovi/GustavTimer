//
//  HapticsService.swift
//  GustavTimer
//
//  Created by AI Assistant on 10.08.2024.
//

import Foundation
import UIKit

protocol HapticsService {
    func intervalEnd()
    func cycleEnd()
}

final class HapticsServiceImpl: HapticsService {
    private var hapticsEnabled: Bool
    private let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    init(hapticsEnabled: Bool = true) {
        self.hapticsEnabled = hapticsEnabled
        prepareGenerators()
    }
    
    func updateHapticsEnabled(_ enabled: Bool) {
        self.hapticsEnabled = enabled
        if enabled {
            prepareGenerators()
        }
    }
    
    func intervalEnd() {
        guard hapticsEnabled else { return }
        rigidGenerator.impactOccurred()
    }
    
    func cycleEnd() {
        guard hapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }
    
    private func prepareGenerators() {
        rigidGenerator.prepare()
        notificationGenerator.prepare()
    }
}

// Mock implementation for testing
final class MockHapticsService: HapticsService {
    var intervalEndCount = 0
    var cycleEndCount = 0
    
    func intervalEnd() {
        intervalEndCount += 1
    }
    
    func cycleEnd() {
        cycleEndCount += 1
    }
}