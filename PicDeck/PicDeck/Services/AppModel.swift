import Foundation
import SwiftUI

/// App 端狀態：待刪清單、每日額度、解鎖狀態、教學是否看過。
@MainActor
final class AppModel: ObservableObject {

    // MARK: - 免費版規則

    /// 免費版每日處理張數上限；付費解除。
    static let dailyFreeLimit = 30

    @Published private(set) var trashedAssetIDs: [String] = []
    @Published private(set) var processedToday: Int = 0
    @Published private(set) var isUnlocked: Bool = false
    @Published var hasSeenTutorial: Bool = false
    /// 照片分頁上次選的子分頁，下次開啟會回到這裡。預設是「全部」。
    @Published private(set) var lastPhotoScale: PhotoScale = .all

    private let defaults = UserDefaults.standard
    private enum Key {
        static let trashed = "picdeck.trashed"
        static let processedCount = "picdeck.processedToday.count"
        static let processedDate = "picdeck.processedToday.date"
        static let unlocked = "picdeck.unlocked"
        static let tutorial = "picdeck.hasSeenTutorial"
        static let photoScale = "picdeck.lastPhotoScale"
    }

    init() {
        load()
    }

    // MARK: - 額度

    var remainingToday: Int {
        isUnlocked ? Int.max : max(0, Self.dailyFreeLimit - processedToday)
    }

    var hasQuotaLeft: Bool {
        isUnlocked || processedToday < Self.dailyFreeLimit
    }

    /// 處理一張照片就扣一次額度；付費版不扣。
    func consumeQuota() {
        guard !isUnlocked else { return }
        processedToday += 1
        persistQuota()
    }

    func refundQuota() {
        guard !isUnlocked, processedToday > 0 else { return }
        processedToday -= 1
        persistQuota()
    }

    // MARK: - 解鎖（v0.1 為本機模擬，尚未接 StoreKit）

    func unlock() {
        isUnlocked = true
        defaults.set(true, forKey: Key.unlocked)
    }

    func resetUnlockForTesting() {
        isUnlocked = false
        defaults.set(false, forKey: Key.unlocked)
    }

    /// 照片分頁的篩選：免費版只有「全部」。
    func canUse(_ filter: PhotoFilter) -> Bool {
        filter.isFree || isUnlocked
    }

    /// 照片分頁目前選的篩選：免費版只有「全部」，標籤篩選需付費。
    func canUse(_ selection: PhotoSelection) -> Bool {
        selection.isFree || isUnlocked
    }

    /// 照片分頁的子分頁：日記為付費。
    func canUse(_ scale: PhotoScale) -> Bool {
        scale.isFree || isUnlocked
    }

    /// 整理分頁：免費版只有月＋年的列，三個固定入口為付費。
    func canUse(_ bucket: OrganizeBucket) -> Bool {
        switch bucket {
        case .month:
            return true
        case .allUnorganized, .unorganizedVideos, .unorganizedScreenshots:
            return isUnlocked
        }
    }

    // MARK: - 待刪清單（兩階段刪除的第一階段）

    func markTrashed(_ assetID: String) {
        guard !trashedAssetIDs.contains(assetID) else { return }
        trashedAssetIDs.append(assetID)
        persistTrash()
    }

    func unmarkTrashed(_ assetID: String) {
        trashedAssetIDs.removeAll { $0 == assetID }
        persistTrash()
    }

    func clearTrash() {
        trashedAssetIDs.removeAll()
        persistTrash()
    }

    // MARK: - 持久化

    private func load() {
        trashedAssetIDs = defaults.stringArray(forKey: Key.trashed) ?? []
        isUnlocked = defaults.bool(forKey: Key.unlocked)
        hasSeenTutorial = defaults.bool(forKey: Key.tutorial)

        if let raw = defaults.string(forKey: Key.photoScale),
           let saved = PhotoScale(rawValue: raw),
           saved.isFree || defaults.bool(forKey: Key.unlocked) {
            lastPhotoScale = saved
        }

        let today = Self.todayKey()
        if defaults.string(forKey: Key.processedDate) == today {
            processedToday = defaults.integer(forKey: Key.processedCount)
        } else {
            processedToday = 0
            defaults.set(today, forKey: Key.processedDate)
            defaults.set(0, forKey: Key.processedCount)
        }
    }

    /// 記住使用者最後切換的子分頁。
    func setLastPhotoScale(_ scale: PhotoScale) {
        guard scale != lastPhotoScale else { return }
        lastPhotoScale = scale
        defaults.set(scale.rawValue, forKey: Key.photoScale)
    }

    func markTutorialSeen() {
        hasSeenTutorial = true
        defaults.set(true, forKey: Key.tutorial)
    }

    private func persistTrash() {
        defaults.set(trashedAssetIDs, forKey: Key.trashed)
    }

    private func persistQuota() {
        defaults.set(Self.todayKey(), forKey: Key.processedDate)
        defaults.set(processedToday, forKey: Key.processedCount)
    }

    private static func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }
}
