//
//  AudioService.swift
//  GustavTimer
//
//  Created by AI Assistant on 10.08.2024.
//

import Foundation
import AVFoundation
import AudioToolbox

protocol AudioService {
    func playIntervalEnd()
    func playCycleEnd()
}

final class AudioServiceImpl: AudioService {
    private var soundsEnabled: Bool
    private var audioSession: AVAudioSession
    
    init(soundsEnabled: Bool = true) {
        self.soundsEnabled = soundsEnabled
        self.audioSession = AVAudioSession.sharedInstance()
        configureAudioSession()
    }
    
    func updateSoundsEnabled(_ enabled: Bool) {
        self.soundsEnabled = enabled
    }
    
    func playIntervalEnd() {
        guard soundsEnabled else { return }
        playSystemSound(1322) // Short beep sound
    }
    
    func playCycleEnd() {
        guard soundsEnabled else { return }
        playSystemSound(1025) // Success sound
    }
    
    private func configureAudioSession() {
        do {
            try audioSession.setCategory(.playback, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    private func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
}

// Mock implementation for testing
final class MockAudioService: AudioService {
    var intervalEndPlayCount = 0
    var cycleEndPlayCount = 0
    
    func playIntervalEnd() {
        intervalEndPlayCount += 1
    }
    
    func playCycleEnd() {
        cycleEndPlayCount += 1
    }
}