import Foundation
import SwiftUI

/// App 端狀態：待刪清單、每日額度、解鎖狀態、教學是否看過。
@MainActor
final class AppModel: ObservableObject {

    // MARK: - 免費版規則

    /// 免費版每日處理張數上限；付費解除。
    static let dailyFreeLimit = 30

    @Published private(set) var trashedAssetIDs: [String] = []

    /// 底部分頁：0 首頁、1 照片、2 整理、3 更多。別的畫面要跳到某個分頁時改這個。
    @Published var selectedTab = 0
    /// 別的分頁（例如首頁的標籤卡片）要求照片分頁切到某個篩選。照片分頁套用後會清掉。
    @Published var requestedSelection: PhotoSelection?
    /// 桌面小工具點進來時，照片分頁要切到哪個子分頁（例如時間軸）。
    @Published var requestedScale: PhotoScale?
    /// 選集頁要直接打開的標籤（保留給其他入口用）。
    @Published var requestedCollectionTagID: UUID?
    /// 整理分頁裡目前在哪個子層。
    @Published var organizeSection: OrganizeSection = .photos
    @Published private(set) var processedToday: Int = 0
    @Published private(set) var isUnlocked: Bool = false
    @Published var hasSeenTutorial: Bool = false
    /// 照片分頁上次選的子分頁，下次開啟會回到這裡。預設是「全部」。
    @Published private(set) var lastPhotoScale: PhotoScale = .all

    /// 介面外觀：自動跟著系統，或固定淺色、深色。
    @Published var appearance: AppAppearance = .system {
        didSet {
            defaults.set(appearance.rawValue, forKey: Key.appearance)
            appearance.apply()
        }
    }

    /// 照片分頁要不要顯示截圖。關掉時，所有項目裡看不到截圖（選「截圖」時仍會顯示）。
    @Published var showsScreenshots: Bool = true {
        didSet { defaults.set(showsScreenshots, forKey: Key.showsScreenshots) }
    }

    /// 全部子分頁的排序：依加入照片庫的時間，或依拍攝時間（預設）。
    @Published var sortsByAdded: Bool = false {
        didSet { defaults.set(sortsByAdded, forKey: Key.sortsByAdded) }
    }

    /// 顯示方式（每列幾張、是否依原比例）。全部、時間軸、日記各自獨立設定。
    @Published private(set) var gridColumnsByScale: [String: Int] = [:]
    @Published private(set) var gridFitsByScale: [String: Bool] = [:]
    static let gridColumnRange = 2...8
    static let defaultGridColumns = 4

    func gridColumns(for scale: GridContext) -> Int {
        gridColumnsByScale[scale.rawValue] ?? Self.defaultGridColumns
    }

    func gridFitsAspect(for scale: GridContext) -> Bool {
        gridFitsByScale[scale.rawValue] ?? false
    }

    /// 放大＝每列變少，縮小＝每列變多。
    func zoom(_ scale: GridContext, in zoomIn: Bool) {
        let next = gridColumns(for: scale) + (zoomIn ? -1 : 1)
        guard Self.gridColumnRange.contains(next) else { return }
        gridColumnsByScale[scale.rawValue] = next
        defaults.set(next, forKey: Key.gridColumns + "." + scale.rawValue)
    }

    func setGridFitsAspect(_ value: Bool, for scale: GridContext) {
        gridFitsByScale[scale.rawValue] = value
        defaults.set(value, forKey: Key.gridFitsAspect + "." + scale.rawValue)
    }


    /// 日記的排序：由新到舊（預設，倒序）或由舊到新。
    @Published var journalNewestFirst: Bool = true {
        didSet { defaults.set(journalNewestFirst, forKey: Key.journalNewestFirst) }
    }

    private let defaults = UserDefaults.standard
    private enum Key {
        static let journalNewestFirst = "picdeck.journalNewestFirst"
        static let gridColumns = "picdeck.gridColumns"
        static let gridFitsAspect = "picdeck.gridFitsAspect"

        static let sortsByAdded = "picdeck.sortsByAdded"
        static let showsScreenshots = "picdeck.showsScreenshots"
        static let trashed = "picdeck.trashed"
        static let processedCount = "picdeck.processedToday.count"
        static let processedDate = "picdeck.processedToday.date"
        static let unlocked = "picdeck.unlocked"
        static let plan = "picdeck.plan"
        static let journalDate = "picdeck.journalCreated.date"
        static let journalCount = "picdeck.journalCreated.count"
        static let purchaseDate = "picdeck.purchaseDate"
        static let trialStart = "picdeck.trialStart"
        static let tutorial = "picdeck.hasSeenTutorial"
        static let photoScale = "picdeck.lastPhotoScale"
        static let appearance = "picdeck.appearance"
    }

    init() {
        load()
        // UI 測試用：帶 -startOnPhotos 啟動時直接停在照片分頁。
        if ProcessInfo.processInfo.arguments.contains("-startOnPhotos") { selectedTab = 2 }
        // UI 測試用：帶 -resetUnlock 啟動時回到未解鎖、沒試用過的狀態。
        if ProcessInfo.processInfo.arguments.contains("-resetUnlock") { resetUnlockForTesting() }
        // UI 測試用：帶 -subscribeForTesting 啟動時直接變成已訂閱（測完還原使用者的狀態用）。
        if ProcessInfo.processInfo.arguments.contains("-subscribeForTesting") { purchase(.monthly) }
        _sortsByAdded = Published(initialValue: defaults.bool(forKey: Key.sortsByAdded))
        if defaults.object(forKey: Key.journalNewestFirst) != nil {
            _journalNewestFirst = Published(initialValue: defaults.bool(forKey: Key.journalNewestFirst))
        }
        for scale in [GridContext.all, .timeline, .journal, .collection] {
            let columns = defaults.integer(forKey: Key.gridColumns + "." + scale.rawValue)
            if Self.gridColumnRange.contains(columns) { gridColumnsByScale[scale.rawValue] = columns }
            if defaults.object(forKey: Key.gridFitsAspect + "." + scale.rawValue) != nil {
                gridFitsByScale[scale.rawValue] = defaults.bool(forKey: Key.gridFitsAspect + "." + scale.rawValue)
            }
        }
        if defaults.object(forKey: Key.showsScreenshots) != nil {
            _showsScreenshots = Published(initialValue: defaults.bool(forKey: Key.showsScreenshots))
        }
        if let raw = defaults.string(forKey: Key.appearance),
           let saved = AppAppearance(rawValue: raw) {
            // 直接寫底層值，不觸發 didSet；視窗在畫面出現時才套用。
            _appearance = Published(initialValue: saved)
        }
    }

    // MARK: - 額度

    var remainingToday: Int {
        isUnlocked ? Int.max : max(0, Self.dailyFreeLimit - processedToday)
    }

    // MARK: - 日記額度（免費每天新增 1 則）

    static let dailyJournalFreeLimit = 1

    /// 今天已經新增了幾則日記（只算新增，編輯舊的不算）。跨日自動歸零。
    var journalCreatedToday: Int {
        guard defaults.string(forKey: Key.journalDate) == Self.todayKey() else { return 0 }
        return defaults.integer(forKey: Key.journalCount)
    }

    /// 免費版今天還能新增日記嗎。訂閱後沒有上限。
    var canCreateJournal: Bool {
        isUnlocked || journalCreatedToday < Self.dailyJournalFreeLimit
    }

    func noteJournalCreated() {
        guard !isUnlocked else { return }
        let count = journalCreatedToday + 1
        defaults.set(Self.todayKey(), forKey: Key.journalDate)
        defaults.set(count, forKey: Key.journalCount)
        objectWillChange.send()
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

    // MARK: - 方案（訂閱、買斷、試用）

    enum Plan: String { case monthly, lifetime }
    static let trialDays = 30

    /// 已購買的方案。nil＝沒買。開發階段是本機模擬，尚未接 StoreKit。
    @Published private(set) var purchasedPlan: Plan?
    /// 開始試用的日期。nil＝還沒試用過（每個人只能試用一次）。
    @Published private(set) var trialStart: Date?

    /// 訂閱開始的日期（開發階段是本機模擬）。
    @Published private(set) var purchaseDate: Date?

    /// 目前這一期的到期日。每月訂閱從開始日起每個月往後推一個月，例如 9/21 訂閱，到期日是 10/21，過了再推到 11/21。
    /// 沒訂閱、或是買斷，回 nil。
    var subscriptionExpiry: Date? {
        guard purchasedPlan == .monthly, let start = purchaseDate else { return nil }
        let calendar = Calendar.current
        var months = 1
        while let next = calendar.date(byAdding: .month, value: months, to: start), next <= Date() { months += 1 }
        return calendar.date(byAdding: .month, value: months, to: start)
    }

    var hasUsedTrial: Bool { trialStart != nil }

    var trialEndDate: Date? {
        trialStart.flatMap { Calendar.current.date(byAdding: .day, value: Self.trialDays, to: $0) }
    }

    var isTrialActive: Bool {
        guard purchasedPlan == nil, let end = trialEndDate else { return false }
        return Date() < end
    }

    /// 試用剩幾天，沒在試用就是 0。
    var trialDaysLeft: Int {
        guard isTrialActive, let end = trialEndDate else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: end).day ?? 0
        return max(1, days + 1)
    }

    /// 依購買與試用狀態重新算是否解鎖。開 App 與回到前景時呼叫，試用到期才會鎖回去。
    func refreshEntitlement() {
        let value = purchasedPlan != nil || isTrialActive
        if value != isUnlocked { isUnlocked = value }
    }

    func startTrial() {
        guard !hasUsedTrial else { return }
        trialStart = Date()
        defaults.set(trialStart, forKey: Key.trialStart)
        refreshEntitlement()
    }

    func purchase(_ plan: Plan) {
        purchasedPlan = plan
        purchaseDate = Date()
        defaults.set(plan.rawValue, forKey: Key.plan)
        defaults.set(purchaseDate, forKey: Key.purchaseDate)
        unlock()
    }

    func unlock() {
        isUnlocked = true
        defaults.set(true, forKey: Key.unlocked)
    }

    func resetUnlockForTesting() {
        isUnlocked = false
        purchasedPlan = nil
        purchaseDate = nil
        trialStart = nil
        defaults.set(false, forKey: Key.unlocked)
        defaults.removeObject(forKey: Key.plan)
        defaults.removeObject(forKey: Key.journalDate)
        defaults.removeObject(forKey: Key.journalCount)
        defaults.removeObject(forKey: Key.purchaseDate)
        defaults.removeObject(forKey: Key.trialStart)
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
        case .allUnorganized, .unorganizedPhotos, .unorganizedVideos, .unorganizedScreenshots:
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
        trialStart = defaults.object(forKey: Key.trialStart) as? Date
        purchaseDate = defaults.object(forKey: Key.purchaseDate) as? Date
        if let raw = defaults.string(forKey: Key.plan), let plan = Plan(rawValue: raw) {
            purchasedPlan = plan
        } else if defaults.bool(forKey: Key.unlocked) {
            // 舊版本只有「已解鎖」一個旗標，當成買斷。
            purchasedPlan = .lifetime
        }
        isUnlocked = purchasedPlan != nil || isTrialActive
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


/// 整理分頁的三個子層。
enum OrganizeSection: String, CaseIterable, Identifiable {
    case photos, tags, albums
    var id: String { rawValue }

    var title: String {
        switch self {
        case .photos: return String(localized: "Photos")
        case .tags: return String(localized: "Tags")
        case .albums: return String(localized: "Folders and albums")
        }
    }
}


/// 介面外觀。
enum AppAppearance: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return String(localized: "Automatic")
        case .light: return String(localized: "Light")
        case .dark: return String(localized: "Dark")
        }
    }

    var style: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }

    /// 直接設在視窗上。這樣彈出的表單、對話框、選單都一起跟著換，不用每一層各自處理。
    @MainActor
    func apply() {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}
