import Foundation
import AVFoundation

protocol AudioService {
    func playIntervalEnd()
    func playCycleEnd()
}

final class AudioServiceProd: AudioService {
    func playIntervalEnd() { play(id: 1104) }
    func playCycleEnd() { play(id: 1113) }
    private func play(id: UInt32) {
        guard UserDefaults.standard.bool(forKey: "soundsEnabled") else { return }
        AudioServicesPlaySystemSound(id)
    }
}
