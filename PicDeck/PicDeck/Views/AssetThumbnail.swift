import SwiftUI
import Photos

/// 共用的縮圖元件。用 PHCachingImageManager 讓大量捲動不卡。
struct AssetThumbnail: View {
    let asset: PHAsset
    var size: CGFloat = 120
    var showsDuration: Bool = true
    /// 依原本比例完整顯示（留邊），而不是裁成正方形填滿。
    var fitsAspect: Bool = false
    /// 喜愛的照片右上角顯示愛心。
    var showsFavorite: Bool = false

    @State private var image: UIImage?

    private var aspectRatio: CGFloat {
        guard fitsAspect, asset.pixelWidth > 0, asset.pixelHeight > 0 else { return 1 }
        return CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
    }

    var body: some View {
        Color.clear
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay {
                if let image {
                    if fitsAspect {
                        Image(uiImage: image).resizable().scaledToFit()
                    } else {
                        Image(uiImage: image).resizable().scaledToFill()
                    }
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
            .overlay(alignment: .topTrailing) {
                if showsFavorite, asset.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2)
                        .padding(5)
                        .accessibilityHidden(true)
                }
            }
            .clipped()
            .contentShape(Rectangle())
            .accessibilityElement()
            .accessibilityAddTraits(.isImage)
            .accessibilityLabel(asset.accessibilitySummary)
            .accessibilityValue(asset.mediaType == .video ? durationText :
                                    (asset.isFavorite ? String(localized: "Favorite") : ""))
            .accessibilityIdentifier("thumb.\(asset.localIdentifier)")
            .task(id: "\(asset.localIdentifier)-\(fitsAspect)-\(Int(size.rounded()))") {
                image = await ThumbnailLoader.shared.image(for: asset, size: size, fitsAspect: fitsAspect)
        }
    }

    private var durationText: String {
        let total = Int(asset.duration.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

extension PHAsset {
    var accessibilitySummary: String {
        let kind = mediaType == .video ? String(localized: "Videos") : String(localized: "Photos")
        guard let creationDate else { return kind }
        return String.localizedStringWithFormat(
            String(localized: "%@, %@"),
            kind,
            creationDate.formatted(date: .abbreviated, time: .shortened)
        )
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

    func image(for asset: PHAsset, size: CGFloat, fitsAspect: Bool = false) async -> UIImage? {
        let scale = await UIScreen.main.scale
        let aspectHeight = fitsAspect && asset.pixelWidth > 0 && asset.pixelHeight > 0
            ? size * CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth)
            : size
        let target = CGSize(width: size * scale, height: aspectHeight * scale)

        return await withCheckedContinuation { continuation in
            let box = ThumbnailResumeBox()
            manager.requestImage(for: asset,
                                 targetSize: target,
                                 contentMode: fitsAspect ? .aspectFit : .aspectFill,
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
