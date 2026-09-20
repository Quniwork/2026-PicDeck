import Foundation
import Photos

/// 「已整理」狀態的判定來源。
///
/// 已整理 = 在任何系統相簿中（由 PhotoKit 推導，換機不會失效）
///        或 被標記為保留（App 自存）。
///
/// 只有「保留」需要自己存，而且不另外建立相簿。為了降低換機或重裝後對不上的風險，
/// 每筆保留紀錄除了 PhotoKit 的識別碼，另存一組由照片本身推導的指紋
/// （拍攝時間 + 像素尺寸 + 媒體類型），識別碼失效時用指紋重新綁定。
/// 紀錄放在 Documents 目錄的 JSON 檔，會被 iCloud／電腦備份帶走。
@MainActor
final class OrganizedStore: ObservableObject {

    /// 一筆保留紀錄。
    struct KeptRecord: Codable, Hashable {
        var localIdentifier: String
        var fingerprint: String
        var keptAt: Date

        init(asset: PHAsset, keptAt: Date = Date()) {
            self.localIdentifier = asset.localIdentifier
            self.fingerprint = OrganizedStore.fingerprint(for: asset)
            self.keptAt = keptAt
        }
    }

    /// 屬於任一系統相簿的照片，由 PhotoKit 推導。
    @Published private(set) var inAlbumIDs: Set<String> = []
    /// 被標記保留的照片。
    @Published private(set) var keptIDs: Set<String> = []
    @Published private(set) var isRefreshing = false

    private var records: [String: KeptRecord] = [:]
    private var fingerprintIndex: [String: String] = [:]
    private let fileURL: URL
    private var saveTask: Task<Void, Never>?

    init(filename: String = "kept-records.json") {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documents.appendingPathComponent(filename)
        load()
    }

    // MARK: - 查詢

    func isOrganized(_ asset: PHAsset) -> Bool {
        inAlbumIDs.contains(asset.localIdentifier) || isKept(asset)
    }

    func isKept(_ asset: PHAsset) -> Bool {
        if keptIDs.contains(asset.localIdentifier) { return true }
        return fingerprintIndex[Self.fingerprint(for: asset)] != nil
    }

    var keptCount: Int { records.count }

    // MARK: - 寫入

    /// 保留：標記成已整理，不動系統相簿。
    func markOrganized(_ asset: PHAsset) {
        let record = KeptRecord(asset: asset)
        records[record.localIdentifier] = record
        fingerprintIndex[record.fingerprint] = record.localIdentifier
        keptIDs.insert(record.localIdentifier)
        scheduleSave()
    }

    func unmarkOrganized(_ asset: PHAsset) {
        let fingerprint = Self.fingerprint(for: asset)
        if let record = records.removeValue(forKey: asset.localIdentifier) {
            fingerprintIndex.removeValue(forKey: record.fingerprint)
            keptIDs.remove(record.localIdentifier)
        } else if let identifier = fingerprintIndex.removeValue(forKey: fingerprint) {
            records.removeValue(forKey: identifier)
            keptIDs.remove(identifier)
        }
        scheduleSave()
    }

    func resetKeptForTesting() {
        records.removeAll()
        fingerprintIndex.removeAll()
        keptIDs.removeAll()
        scheduleSave()
    }

    // MARK: - 重新整理

    /// 重新讀取相簿歸屬，並把換機後失效的識別碼用指紋重新綁定。
    func refresh(allAssets: [PHAsset] = []) async {
        isRefreshing = true
        defer { isRefreshing = false }

        inAlbumIDs = await Task.detached(priority: .userInitiated) { () -> Set<String> in
            var ids = Set<String>()
            let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            albums.enumerateObjects { collection, _, _ in
                PHAsset.fetchAssets(in: collection, options: nil).enumerateObjects { asset, _, _ in
                    ids.insert(asset.localIdentifier)
                }
            }
            return ids
        }.value

        reconcile(with: allAssets)
    }

    /// 用指紋把紀錄重新綁到目前圖庫的識別碼，順便清掉已不存在的孤兒紀錄。
    private func reconcile(with assets: [PHAsset]) {
        guard !records.isEmpty, !assets.isEmpty else {
            keptIDs = Set(records.keys)
            return
        }

        var rebuilt: [String: KeptRecord] = [:]
        var rebuiltIndex: [String: String] = [:]

        for asset in assets {
            let fingerprint = Self.fingerprint(for: asset)
            let existing = records[asset.localIdentifier]
                ?? fingerprintIndex[fingerprint].flatMap { records[$0] }
            guard let existing else { continue }

            var record = existing
            record.localIdentifier = asset.localIdentifier
            record.fingerprint = fingerprint
            rebuilt[asset.localIdentifier] = record
            rebuiltIndex[fingerprint] = asset.localIdentifier
        }

        let changed = rebuilt.count != records.count
        records = rebuilt
        fingerprintIndex = rebuiltIndex
        keptIDs = Set(rebuilt.keys)
        if changed { scheduleSave() }
    }

    /// 由照片屬性組成，不依賴 PhotoKit 識別碼。
    nonisolated static func fingerprint(for asset: PHAsset) -> String {
        let timestamp = asset.creationDate.map { Int($0.timeIntervalSince1970) } ?? 0
        return "\(timestamp)-\(asset.pixelWidth)x\(asset.pixelHeight)-\(asset.mediaType.rawValue)"
    }

    // MARK: - 持久化

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([KeptRecord].self, from: data) else { return }

        records = Dictionary(decoded.map { ($0.localIdentifier, $0) }) { first, _ in first }
        fingerprintIndex = Dictionary(decoded.map { ($0.fingerprint, $0.localIdentifier) }) { first, _ in first }
        keptIDs = Set(records.keys)
    }

    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            self?.save()
        }
    }

    private func save() {
        let snapshot = Array(records.values)
        let url = fileURL
        Task.detached(priority: .utility) {
            guard let data = try? JSONEncoder().encode(snapshot) else { return }
            try? data.write(to: url, options: .atomic)
        }
    }

    /// 立即寫入。
    func flush() {
        saveTask?.cancel()
        save()
    }
}
