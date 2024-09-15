//
//  SoundManager.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 30.06.2024.
//

import Foundation
import AVKit

class SoundManager {
            
    static let instance = SoundManager() // Singleton
    
    var player: AVAudioPlayer?
    
    enum SoundOption: String {
        case countdown
        case final
    }
    
    init() {
        configureAudioSession()
    }
    
    func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category. \(error.localizedDescription)")
        }
    }
    
    func playSound(sound: SoundOption, theme: String) {
        
        guard let url = Bundle.main.url(forResource: theme + "-" + sound.rawValue, withExtension: ".mp3") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("Error playing sound. \(error.localizedDescription)")
        }
    }
}
