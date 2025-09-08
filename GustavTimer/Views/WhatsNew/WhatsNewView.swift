//
//  WhatsNewView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 07.12.2024.
//

import SwiftUI
import AVKit

struct WhatsNewView: View {
    var buttonLabel: LocalizedStringKey
    var tags: [String] = []
    var action: () -> Void
    
    private let player = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "whatsnew", ofType: "mp4")!))
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
                Text("whatsnew-title")
            }
        .ignoresSafeArea()
    }
    
    private func setUpLoop(for player: AVPlayer) {
            // Přidání notifikace pro detekci konce videa
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                player.seek(to: .zero) // Vrátí video na začátek
                player.play() // Znovu spustí video
            }
        }
}

#Preview {
    WhatsNewView(buttonLabel: "enter challenge", action: {})
    .ignoresSafeArea()
}
