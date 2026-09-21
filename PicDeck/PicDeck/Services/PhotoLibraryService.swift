import Foundation
import Photos
import UIKit

/// 封裝所有 PhotoKit 存取。所有結果都寫回系統相簿，App 不另存實體照片。
@MainActor
final class PhotoLibraryService: ObservableObject {

    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    /// 最近一次操作失敗的提示。畫面上的 `failureToast()` 會顯示它，幾秒後自動消失。
    @Published var failure: FailureNotice?
    @Published private(set) var isLoading = false
    /// 系統相簿有任何變動（在別的 App 改了喜愛、刪了照片、加了相簿）就加一。
    /// 畫面看到它變了，就重新取最新的照片狀態。
    @Published private(set) var libraryChangeCount = 0

    private let changeObserver = LibraryChangeObserver()

    init() {
        changeObserver.onChange = { [weak self] in
            Task { @MainActor in self?.libraryChangeCount += 1 }
        }
        PHPhotoLibrary.shared().register(changeObserver)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(changeObserver)
    }

    struct FailureNotice: Equatable, Identifiable {
        let id = UUID()
        let text: String
    }

    /// 執行一個會動到系統照片的操作。失敗就記下提示，不再默默吞掉。
    @discardableResult
    func attempt(_ failureText: String, _ operation: () async throws -> Void) async -> Bool {
        do {
            try await operation()
            return true
        } catch {
            // 使用者自己按了取消（例如系統的刪除確認），不算失敗，也不用提示。
            let nsError = error as NSError
            let cancelled = (nsError.domain == PHPhotosErrorDomain && nsError.code == PHPhotosError.userCancelled.rawValue)
                || (nsError.domain == NSCocoaErrorDomain && nsError.code == NSUserCancelledError)
            if !cancelled { failure = FailureNotice(text: failureText) }
            return false
        }
    }

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

    /// 建立系統相簿，回傳其 localIdentifier。給了資料夾就建在那個資料夾底下。
    func createAlbum(named name: String, inFolderID folderID: String? = nil) async throws -> String? {
        let parent = folderID.flatMap {
            PHCollectionList.fetchCollectionLists(withLocalIdentifiers: [$0], options: nil).firstObject
        }
        var placeholder: PHObjectPlaceholder?
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            placeholder = request.placeholderForCreatedAssetCollection
            if let parent, let placeholder {
                PHCollectionListChangeRequest(for: parent)?.addChildCollections([placeholder] as NSArray)
            }
        }
        return placeholder?.localIdentifier
    }

    /// 建立系統相簿資料夾，回傳其 localIdentifier。資料夾裡面還可以再放資料夾。
    func createFolder(named name: String, inFolderID folderID: String? = nil) async throws -> String? {
        let parent = folderID.flatMap {
            PHCollectionList.fetchCollectionLists(withLocalIdentifiers: [$0], options: nil).firstObject
        }
        var placeholder: PHObjectPlaceholder?
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHCollectionListChangeRequest.creationRequestForCollectionList(withTitle: name)
            placeholder = request.placeholderForCreatedCollectionList
            if let parent, let placeholder {
                PHCollectionListChangeRequest(for: parent)?.addChildCollections([placeholder] as NSArray)
            }
        }
        return placeholder?.localIdentifier
    }

    /// 系統相簿的階層：最上層是資料夾與相簿，資料夾底下還有資料夾與相簿。
    func albumTree() -> [AlbumNode] {
        nodes(from: PHCollectionList.fetchTopLevelUserCollections(with: nil))
    }

    private func nodes(from result: PHFetchResult<PHCollection>) -> [AlbumNode] {
        var output: [AlbumNode] = []
        result.enumerateObjects { collection, _, _ in
            if let album = collection as? PHAssetCollection {
                let count = PHAsset.fetchAssets(in: album, options: nil).count
                output.append(AlbumNode(id: album.localIdentifier,
                                        title: album.localizedTitle ?? "",
                                        isFolder: false,
                                        count: count,
                                        children: []))
            } else if let list = collection as? PHCollectionList {
                let children = self.nodes(from: PHCollection.fetchCollections(in: list, options: nil))
                output.append(AlbumNode(id: list.localIdentifier,
                                        title: list.localizedTitle ?? "",
                                        isFolder: true,
                                        count: 0,
                                        children: children))
            }
        }
        return output
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

    /// 資料夾改名。
    func renameFolder(id: String, to title: String) async throws {
        guard let list = PHCollectionList
            .fetchCollectionLists(withLocalIdentifiers: [id], options: nil).firstObject else { return }
        try await PHPhotoLibrary.shared().performChanges {
            PHCollectionListChangeRequest(for: list)?.title = title
        }
    }

    /// 刪除資料夾。資料夾底下的相簿會一起移除，照片仍然留在圖庫裡。
    func deleteFolder(id: String) async throws {
        let lists = PHCollectionList.fetchCollectionLists(withLocalIdentifiers: [id], options: nil)
        guard lists.firstObject != nil else { return }
        try await PHPhotoLibrary.shared().performChanges {
            PHCollectionListChangeRequest.deleteCollectionLists(lists)
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

    /// 一次把多張照片加進相簿。
    func addAssets(_ assets: [PHAsset], toAlbumWithID albumID: String) async throws {
        guard !assets.isEmpty,
              let collection = PHAssetCollection
                .fetchAssetCollections(withLocalIdentifiers: [albumID], options: nil).firstObject
        else { return }

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetCollectionChangeRequest(for: collection)?.addAssets(assets as NSArray)
        }
    }

    /// 把多張照片從相簿移出。只是不再屬於這個相簿，照片本身還在圖庫裡。
    func removeAssets(_ assets: [PHAsset], fromAlbumWithID albumID: String) async throws {
        guard !assets.isEmpty,
              let collection = PHAssetCollection
                .fetchAssetCollections(withLocalIdentifiers: [albumID], options: nil).firstObject
        else { return }

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetCollectionChangeRequest(for: collection)?.removeAssets(assets as NSArray)
        }
    }

    /// 這些照片「全部」都已經在哪些相簿裡。多張時取交集，跟標籤的勾選規則一樣。
    func albumIDs(containingAll assets: [PHAsset]) -> Set<String> {
        var result: Set<String>?
        for asset in assets {
            let ids = Set(PHAssetCollection
                .fetchAssetCollectionsContaining(asset, with: .album, options: nil)
                .objects(at: IndexSet(0..<PHAssetCollection
                    .fetchAssetCollectionsContaining(asset, with: .album, options: nil).count))
                .map(\.localIdentifier))
            result = result.map { $0.intersection(ids) } ?? ids
        }
        return result ?? []
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
            case .edited:
                return Self.collect(PHAsset.fetchAssets(with: options)).filter(\.hasAdjustments)
            case .notInAlbum:
                var inAlbums = Set<String>()
                let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
                albums.enumerateObjects { album, _, _ in
                    PHAsset.fetchAssets(in: album, options: nil)
                        .enumerateObjects { asset, _, _ in inAlbums.insert(asset.localIdentifier) }
                }
                return Self.collect(PHAsset.fetchAssets(with: options))
                    .filter { !inAlbums.contains($0.localIdentifier) }
            }
        }.value
    }

    /// 依「加入照片庫的時間」由新到舊排的名次。
    /// PhotoKit 沒有公開這個日期，只能用 fetch 的排序鍵 `addedDate`（未列在文件中）取得順序。
    func addedRanks() async -> [String: Int] {
        await Task.detached(priority: .userInitiated) {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "addedDate", ascending: false)]
            var ranks: [String: Int] = [:]
            var index = 0
            PHAsset.fetchAssets(with: options).enumerateObjects { asset, _, _ in
                ranks[asset.localIdentifier] = index
                index += 1
            }
            return ranks
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
/// 相簿樹上的一個節點：相簿或資料夾。
struct AlbumNode: Identifiable, Hashable {
    let id: String
    let title: String
    let isFolder: Bool
    /// 相簿裡的照片數。資料夾是 0。
    let count: Int
    let children: [AlbumNode]

    /// 給 `List(_, children:)` 用。相簿回 nil，資料夾回它底下的項目。
    var outlineChildren: [AlbumNode]? { isFolder ? children : nil }
}

struct AlbumSummary: Identifiable, Hashable {
    let id: String
    let title: String
    let count: Int
}


/// 系統相簿變動的通知會在背景執行緒送來，這裡只負責轉交，不碰任何畫面狀態。
private final class LibraryChangeObserver: NSObject, PHPhotoLibraryChangeObserver, @unchecked Sendable {
    var onChange: (() -> Void)?

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        onChange?()
    }
}
