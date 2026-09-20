import SwiftUI
import Photos

/// 共用的縮圖元件。用 PHCachingImageManager 讓大量捲動不卡。
struct AssetThumbnail: View {
    let asset: PHAsset
    var size: CGFloat = 120
    var showsDuration: Bool = true

    @State private var image: UIImage?

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle().fill(Color(.secondarySystemBackground))
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if showsDuration, asset.mediaType == .video {
                    Text(durationText)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                        .padding(4)
                }
            }
            .clipped()
            .contentShape(Rectangle())
            .accessibilityElement()
            .accessibilityAddTraits(.isImage)
            .accessibilityIdentifier("thumb.\(asset.localIdentifier)")
            .task(id: asset.localIdentifier) {
            image = await ThumbnailLoader.shared.image(for: asset, size: size)
        }
    }

    private var durationText: String {
        let total = Int(asset.duration.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

/// 縮圖載入器，共用一個 caching manager。
final class ThumbnailLoader {
    static let shared = ThumbnailLoader()

    private let manager = PHCachingImageManager()
    private let options: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        return options
    }()

    private init() {
        manager.allowsCachingHighQualityImages = false
    }

    func image(for asset: PHAsset, size: CGFloat) async -> UIImage? {
        let scale = await UIScreen.main.scale
        let target = CGSize(width: size * scale, height: size * scale)

        return await withCheckedContinuation { continuation in
            let box = ThumbnailResumeBox()
            manager.requestImage(for: asset,
                                 targetSize: target,
                                 contentMode: .aspectFill,
                                 options: options) { image, info in
                // opportunistic 會先回低解析度再回高解析度，只接受最終那次。
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                if isDegraded { return }
                guard box.tryResume() else { return }
                continuation.resume(returning: image)
            }
        }
    }
}

private final class ThumbnailResumeBox: @unchecked Sendable {
    private let lock = NSLock()
    private var resumed = false

    func tryResume() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        if resumed { return false }
        resumed = true
        return true
    }
}


/// 讓 PHAsset 可以直接用在 sheet(item:) 等需要 Identifiable 的地方。
extension PHAsset: @retroactive Identifiable {
    public var id: String { localIdentifier }
}
