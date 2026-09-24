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
    /// Prevent a retained but hidden grid from requesting images in the background.
    var isActive: Bool = true

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
            .task(id: "\(asset.localIdentifier)-\(fitsAspect)-\(Int(size.rounded()))-\(isActive)") {
                guard isActive else { return }
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

        let request = ThumbnailRequest(manager: manager)
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                request.install(continuation)
                let id = manager.requestImage(for: asset,
                                              targetSize: target,
                                              contentMode: fitsAspect ? .aspectFit : .aspectFill,
                                              options: options) { image, info in
                    let cancelled = (info?[PHImageCancelledKey] as? Bool) ?? false
                    let error = info?[PHImageErrorKey] as? Error
                    let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                    if cancelled || error != nil {
                        request.finishUsingDegradedImage()
                    } else if isDegraded {
                        request.storeDegradedImage(image)
                    } else {
                        request.finish(returning: image)
                    }
                }
                request.setRequestID(id)
            }
        } onCancel: {
            request.cancel()
        }
    }
}

private final class ThumbnailRequest: @unchecked Sendable {
    private let lock = NSLock()
    private let manager: PHCachingImageManager
    private var requestID: PHImageRequestID?
    private var continuation: CheckedContinuation<UIImage?, Never>?
    private var degradedImage: UIImage?
    private var completed = false
    private var cancelled = false

    init(manager: PHCachingImageManager) { self.manager = manager }

    func install(_ continuation: CheckedContinuation<UIImage?, Never>) {
        lock.lock()
        let shouldResume = cancelled || completed
        if !shouldResume { self.continuation = continuation }
        lock.unlock()
        if shouldResume { continuation.resume(returning: nil) }
    }

    func setRequestID(_ id: PHImageRequestID) {
        lock.lock()
        let shouldCancel = cancelled
        if !shouldCancel && !completed { requestID = id }
        lock.unlock()
        if shouldCancel { manager.cancelImageRequest(id) }
    }

    func finish(returning image: UIImage?) {
        lock.lock()
        guard !completed else { lock.unlock(); return }
        completed = true
        let continuation = self.continuation
        self.continuation = nil
        lock.unlock()
        continuation?.resume(returning: image)
    }

    func storeDegradedImage(_ image: UIImage?) {
        guard let image else { return }
        lock.lock()
        if !completed { degradedImage = image }
        lock.unlock()
    }

    func finishUsingDegradedImage() {
        lock.lock()
        guard !completed else { lock.unlock(); return }
        completed = true
        let image = degradedImage
        let continuation = self.continuation
        self.continuation = nil
        lock.unlock()
        continuation?.resume(returning: image)
    }

    func cancel() {
        lock.lock()
        cancelled = true
        let id = requestID
        requestID = nil
        lock.unlock()
        if let id { manager.cancelImageRequest(id) }
        finish(returning: nil)
    }
}


/// 讓 PHAsset 可以直接用在 sheet(item:) 等需要 Identifiable 的地方。
extension PHAsset: @retroactive Identifiable {
    public var id: String { localIdentifier }
}
