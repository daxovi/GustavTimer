//
//  OnboardingPageView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 25.12.2025.
//

import SwiftUI
import AVKit

struct OnboardingPageView: View {
    var title: LocalizedStringKey? = nil
    var description: LocalizedStringKey? = nil
    var mediaFilename: String? = nil
    let actionLabel: LocalizedStringKey
    let action: () -> Void
    
    @Environment(\.theme) var theme
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            if let mediaFilename {
                if let url = Bundle.main.url(forResource: mediaFilename, withExtension: "mp4") {
                    LoopingPlayerView(url: url)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                } else {
                    Image(mediaFilename)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }
            }
            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                
                if let title {
                    Text(title)
                        .font(theme.fonts.onboardingTitle)
                }
                
                if let description {
                    Text(description)
                }
                    
                Button(action: action) {
                    HStack {
                        Text(actionLabel)
                            .textCase(.uppercase)
                            .font(theme.fonts.onboardingButtonLabel)
                        Spacer()
                    }
                }
                .padding(.vertical)
            }
            .padding(24)
            .font(theme.fonts.body)
            .lineSpacing(4)
            .foregroundStyle(.white)
        }
    }
}

private struct LoopingPlayerView: View {
    let url: URL
    @State private var player: AVQueuePlayer = .init()
    @State private var looper: AVPlayerLooper?

    var body: some View {
        AspectFillPlayerContainer(player: player)
            .onAppear {
                let item = AVPlayerItem(url: url)
                let queue = AVQueuePlayer(items: [item])
                self.player = queue
                self.looper = AVPlayerLooper(player: queue, templateItem: item)
                queue.isMuted = true
                queue.play()
            }
            .onDisappear {
                player.pause()
                looper = nil
            }
    }
}

#if canImport(UIKit)
import UIKit
private struct AspectFillPlayerContainer: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.player = player
        return view
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
        uiView.player = player
    }
}

private final class PlayerView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer.videoGravity = .resizeAspectFill
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        playerLayer.videoGravity = .resizeAspectFill
    }
}
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
private struct AspectFillPlayerContainer: NSViewRepresentable {
    let player: AVPlayer

    func makeNSView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.player = player
        return view
    }

    func updateNSView(_ nsView: PlayerView, context: Context) {
        nsView.player = player
    }
}

private final class PlayerView: NSView {
    override func makeBackingLayer() -> CALayer { AVPlayerLayer() }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        playerLayer.videoGravity = .resizeAspectFill
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        playerLayer.videoGravity = .resizeAspectFill
    }
}
#endif

#Preview {
    OnboardingPageView(
        title: "Vlastní tréninky",
        description: "Poskládej si vlastní intervaly, pauzy a opakování. Každý blok si můžeš pojmenovat, nastavit opakování a upozornění.", mediaFilename: nil,
        actionLabel: "Pokračuj") {
            //
        }
}
