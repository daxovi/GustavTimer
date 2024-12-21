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
                ZStack {
                    GeometryReader { proxy in
                        VideoPlayer(player: player)
                            .ignoresSafeArea()
                            .frame(height: proxy.size.height + 500)
                            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                            .onAppear() {
                                player.isMuted = true
                                player.play()
                                setUpLoop(for: player)
                            }
                            .allowsHitTesting(false)

                        HStack {
                            ForEach(tags, id: \.self) { tag in
                                Tag(tag)
                            }
                            Spacer()
                            Image(systemName: "xmark")
                                .font(.system(size: 24))
                                .foregroundStyle(.stop)
                                .onTapGesture { dismiss() }
                        }
                        .safeAreaPadding()
                    }
                }
                .ignoresSafeArea()
                ControlButton(action: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        action()
                    }
                }, text: buttonLabel, color: .start)
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
