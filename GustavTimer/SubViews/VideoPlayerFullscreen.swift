//
//  VideoFullscreenRepresentable.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 21.12.2024.
//
import SwiftUI
import AVKit

struct VideoPlayerFullscreen: UIViewControllerRepresentable {
    let videoURL: URL
    let onHalfway: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.modalPresentationStyle = .fullScreen

        // Uložíme observer do kontextu, aby se nevymazal z paměti
        context.coordinator.setupTimeObserver(for: player, onHalfway: onHalfway)

        // Prezentujeme přehrávač na celou obrazovku
        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = .clear
        rootViewController.modalPresentationStyle = .fullScreen

        DispatchQueue.main.async {
            rootViewController.present(playerViewController, animated: true) {
                player.play()
            }
        }
        return rootViewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        private var timeObserverToken: Any?

        func setupTimeObserver(for player: AVPlayer, onHalfway: @escaping () -> Void) {
            let observer = player.addPeriodicTimeObserver(
                forInterval: CMTime(seconds: 1, preferredTimescale: 600),
                queue: .main
            ) { currentTime in
                guard let duration = player.currentItem?.duration.seconds, duration > 0 else { return }

                let halfway = duration / 2
                if currentTime.seconds >= halfway {
                    onHalfway()
                    self.removeTimeObserver(from: player)
                }
            }

            // Uložíme referenci na observer
            self.timeObserverToken = observer
        }

        func removeTimeObserver(from player: AVPlayer) {
            if let token = timeObserverToken {
                player.removeTimeObserver(token)
                timeObserverToken = nil
            }
        }

        deinit {
            // Odstranění pozorovatele při uvolnění koordinátoru
            if let token = timeObserverToken {
                print("Removing observer")
                timeObserverToken = nil
            }
        }
    }
}
