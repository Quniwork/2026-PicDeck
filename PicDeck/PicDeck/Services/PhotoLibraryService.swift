import Foundation
import Photos
import UIKit

/// 封裝所有 PhotoKit 存取。所有結果都寫回系統相簿，App 不另存實體照片。
@MainActor
final class PhotoLibraryService: ObservableObject {

    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published private(set) var isLoading = false

    // MARK: - 權限

    func refreshAuthorizationStatus() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    func requestAuthorization() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        authorizationStatus = status
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorized || authorizationStatus == .limited
    }

    // MARK: - 讀取


    // MARK: - 縮圖

    func image(for asset: PHAsset, targetSize: CGSize) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false

            let box = ResumeBox()
            PHImageManager.default().requestImage(for: asset,
                                                 targetSize: targetSize,
                                                 contentMode: .aspectFit,
                                                 options: options) { image, _ in
                guard box.tryResume() else { return }
                continuation.resume(returning: image)
            }
        }
    }

    // MARK: - 寫入

    func setFavorite(_ asset: PHAsset, to value: Bool) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest(for: asset)
            request.isFavorite = value
        }
    }

    /// 真正從系統相簿刪除，照片會進入 iOS「最近刪除」，30 天內可救回。
    func delete(assetIDs: [String]) async throws {
        guard !assetIDs.isEmpty else { return }
        let result = PHAsset.fetchAssets(withLocalIdentifiers: assetIDs, options: nil)
        guard result.count > 0 else { return }

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(result)
        }
    }

    /// 建立系統相簿，回傳其 localIdentifier。
    func createAlbum(named name: String) async throws -> String? {
        var placeholder: PHObjectPlaceholder?
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            placeholder = request.placeholderForCreatedAssetCollection
        }
        return placeholder?.localIdentifier
    }

    func addAsset(_ asset: PHAsset, toAlbumWithID albumID: String) async throws {
        let collections = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumID], options: nil)
        guard let collection = collections.firstObject else { return }

        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCollectionChangeRequest(for: collection)
            request?.addAssets([asset] as NSArray)
        }
    }

    /// 改相簿名稱。
    func renameAlbum(id: String, to title: String) async throws {
        let collections = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [id], options: nil)
        guard let collection = collections.firstObject else { return }

        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCollectionChangeRequest(for: collection)
            request?.title = title
        }
    }

    /// 刪除相簿本身。相簿裡的照片還留在圖庫，只是不再屬於這個相簿。
    func deleteAlbum(id: String) async throws {
        let collections = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [id], options: nil)
        guard collections.firstObject != nil else { return }

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetCollectionChangeRequest.deleteAssetCollections(collections)
        }
    }

    func asset(withID id: String) -> PHAsset? {
        PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject
    }
}

/// 確保 continuation 只被 resume 一次。
private final class ResumeBox: @unchecked Sendable {
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

// MARK: - 新架構用的查詢

extension PhotoLibraryService {

    /// 依篩選條件取得照片。
    func assets(matching filter: PhotoFilter) async -> [PHAsset] {
        await Task.detached(priority: .userInitiated) {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            switch filter {
            case .all:
                return Self.collect(PHAsset.fetchAssets(with: options))
            case .photos:
                return Self.collect(PHAsset.fetchAssets(with: .image, options: options))
            case .videos:
                return Self.collect(PHAsset.fetchAssets(with: .video, options: options))
            case .favorites:
                options.predicate = NSPredicate(format: "favorite == YES")
                return Self.collect(PHAsset.fetchAssets(with: options))
            case .screenshots:
                return Self.collect(inSmartAlbum: .smartAlbumScreenshots, options: options)
            }
        }.value
    }

    /// 取某一天的所有照片，給日記挑選用。
    func assets(onYear year: Int, month: Int, day: Int) async -> [PHAsset] {
        await Task.detached(priority: .userInitiated) {
            var parts = DateComponents()
            parts.year = year
            parts.month = month
            parts.day = day
            let calendar = PhotoGrouping.calendar
            guard let start = calendar.date(from: parts),
                  let end = calendar.date(byAdding: .day, value: 1, to: start) else { return [] }

            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            options.predicate = NSPredicate(format: "creationDate >= %@ AND creationDate < %@",
                                            start as NSDate, end as NSDate)
            return Self.collect(PHAsset.fetchAssets(with: options))
        }.value
    }

    /// 依識別碼取回照片，保持給定順序。
    func assets(withIDs ids: [String]) -> [PHAsset] {
        guard !ids.isEmpty else { return [] }
        var found: [String: PHAsset] = [:]
        PHAsset.fetchAssets(withLocalIdentifiers: ids, options: nil).enumerateObjects { asset, _, _ in
            found[asset.localIdentifier] = asset
        }
        return ids.compactMap { found[$0] }
    }

    /// 本機所有使用者相簿，含張數。
    func userAlbums() async -> [AlbumSummary] {
        await Task.detached(priority: .userInitiated) {
            var result: [AlbumSummary] = []

            let regular = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                 subtype: .any,
                                                                 options: nil)
            regular.enumerateObjects { collection, _, _ in
                let count = PHAsset.fetchAssets(in: collection, options: nil).count
                result.append(AlbumSummary(id: collection.localIdentifier,
                                           title: collection.localizedTitle ?? "—",
                                           count: count))
            }
            return result.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        }.value
    }

    /// 屬於任何一個使用者相簿的照片識別碼。用來推導「已整理」。
    func identifiersInAnyAlbum() async -> Set<String> {
        await Task.detached(priority: .userInitiated) {
            var identifiers = Set<String>()
            let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            albums.enumerateObjects { collection, _, _ in
                PHAsset.fetchAssets(in: collection, options: nil).enumerateObjects { asset, _, _ in
                    identifiers.insert(asset.localIdentifier)
                }
            }
            return identifiers
        }.value
    }

    // MARK: - 私用工具

    fileprivate nonisolated static func collect(_ result: PHFetchResult<PHAsset>) -> [PHAsset] {
        var assets: [PHAsset] = []
        assets.reserveCapacity(result.count)
        result.enumerateObjects { asset, _, _ in assets.append(asset) }
        return assets
    }

    fileprivate nonisolated static func collect(inSmartAlbum subtype: PHAssetCollectionSubtype,
                                                options: PHFetchOptions) -> [PHAsset] {
        let collections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                  subtype: subtype,
                                                                  options: nil)
        var assets: [PHAsset] = []
        collections.enumerateObjects { collection, _, _ in
            assets.append(contentsOf: collect(PHAsset.fetchAssets(in: collection, options: options)))
        }
        return assets
    }
}

/// 相簿摘要，給資料夾分頁與歸檔快捷列用。
struct AlbumSummary: Identifiable, Hashable {
    let id: String
    let title: String
    let count: Int
}
