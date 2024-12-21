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

    func makeUIViewController(context: Context) -> UIViewController {
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.modalPresentationStyle = .fullScreen // Zajistí fullscreen

        // Vytvoří UIViewController, který okamžitě spustí fullscreen přehrávač
        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = .clear
        rootViewController.modalPresentationStyle = .fullScreen

        DispatchQueue.main.async {
            rootViewController.present(playerViewController, animated: true) {
                player.play() // Spustí video automaticky
            }
        }
        return rootViewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
