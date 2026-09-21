import SwiftUI
import AVFoundation
import Photos
import UIKit

/// 影片直接在畫面裡播放：中間有播放鈕，點畫面播放或暫停，底下有進度條。
/// 整理畫面與單張檢視共用。影片是相簿裡的（可能在 iCloud），載入時允許從網路下載。
struct InlineVideoView: View {
    let asset: PHAsset
    /// 影片還沒開始時先顯示的縮圖。
    let poster: UIImage?

    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var isLoading = false
    @State private var progress: Double = 0
    @State private var endObserver: NSObjectProtocol?
    @State private var timeObserver: Any?

    var body: some View {
        ZStack {
            if let player {
                PlayerLayerView(player: player)
            } else if let poster {
                Image(uiImage: poster).resizable().scaledToFit()
            }

            if isLoading {
                ProgressView().tint(.white)
            } else if !isPlaying {
                Image(systemName: "play.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .floatingGlass(in: Circle(), interactive: true)
                    .accessibilityHidden(true)
            }

            VStack {
                Spacer()
                if player != nil {
                    ProgressView(value: progress)
                        .tint(.white)
                        .padding(.horizontal, 14)
                        .padding(.bottom, 10)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { toggle() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(isPlaying ? "Pause video" : "Play video"))
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("video.player")
        .onDisappear(perform: stop)
        .task(id: asset.localIdentifier) { stop() }
    }

    private func toggle() {
        if let player {
            if isPlaying { player.pause(); isPlaying = false } else { play(player) }
            return
        }
        load()
    }

    private func load() {
        guard !isLoading else { return }
        isLoading = true
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .automatic
        PHImageManager.default().requestPlayerItem(forVideo: asset, options: options) { item, _ in
            DispatchQueue.main.async {
                isLoading = false
                guard let item else { return }
                let newPlayer = AVPlayer(playerItem: item)
                player = newPlayer
                observe(newPlayer, item: item)
                play(newPlayer)
            }
        }
    }

    private func play(_ player: AVPlayer) {
        // 靜音鍵開著也要有聲音，跟系統照片一樣。
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        player.play()
        isPlaying = true
    }

    private func observe(_ player: AVPlayer, item: AVPlayerItem) {
        endObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { _ in
            player.seek(to: .zero)
            isPlaying = false
            progress = 0
        }
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.2, preferredTimescale: 600), queue: .main) { time in
            let total = item.duration.seconds
            if total.isFinite, total > 0 { progress = min(1, time.seconds / total) }
        }
    }

    private func stop() {
        if let timeObserver, let player { player.removeTimeObserver(timeObserver) }
        timeObserver = nil
        if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
        endObserver = nil
        player?.pause()
        player = nil
        isPlaying = false
        progress = 0
    }
}

/// 把 AVPlayer 的畫面放進 SwiftUI。
private struct PlayerLayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspect
        return view
    }

    func updateUIView(_ view: PlayerView, context: Context) {
        view.playerLayer.player = player
    }

    final class PlayerView: UIView {
        override static var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    }
}
