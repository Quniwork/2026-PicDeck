import Foundation
import Combine
import UIKit

/// 管理 PicDeck 的 iCloud 雲端同步與防刪除還原服務。
///
/// 採用「本機優先 + iCloud 鏡像雙軌儲存（Dual-Track）」架構：
/// 1. 離線或未登入 iCloud 時：讀寫本機 Document Directory，100% 正常運作。
/// 2. 登入 iCloud 時：所有標籤、日記、備註自動鏡像至專屬 iCloud 容器。
/// 3. 使用者刪除 App 又重裝時：本機資料雖被系統清空，但啟動時偵測到 iCloud 容器有備份，自動全量還原！
@MainActor
final class CloudSyncService: ObservableObject {
    static let shared = CloudSyncService()

    /// 廣播通知：當雲端資料還原或外部同步完成時觸發，通知各 Store 重新載入。
    static let didSyncFromCloudNotification = Notification.Name("CloudSyncServiceDidSyncFromCloud")

    @Published private(set) var isICloudAvailable: Bool = false
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var isSyncing: Bool = false

    /// 全自動備份目錄：在 Documents/自動備份
    /// （配合 UIFileSharingEnabled，使用者可在「檔案」App > 我的 iPhone > PicDeck > 自動備份 中看到）
    var autoBackupDirectoryURL: URL {
        localDocumentsURL.appendingPathComponent("自動備份", isDirectory: true)
    }

    private let lastAutoBackupKey = "PicDeck_LastAutoBackupDate"
    @Published private(set) var lastAutoBackupDate: Date? {
        didSet {
            if let date = lastAutoBackupDate {
                UserDefaults.standard.set(date.timeIntervalSince1970, forKey: lastAutoBackupKey)
            }
        }
    }

    private let fileManager = FileManager.default
    private let ubiquityContainerID = "iCloud.com.picdeck.app"
    private let kvStore = NSUbiquitousKeyValueStore.default

    /// 本地沙盒目錄
    let localDocumentsURL: URL

    /// iCloud 雲端目錄（若未登入或不可用則為 nil）
    private(set) var cloudDocumentsURL: URL?

    private init() {
        self.localDocumentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if let timestamp = UserDefaults.standard.object(forKey: lastAutoBackupKey) as? Double {
            self.lastAutoBackupDate = Date(timeIntervalSince1970: timestamp)
        }
        setupKVStoreObserver()
        setupUbiquityObserver()
        setupAppLifecycleObservers()
        ensureAutoBackupDirectory()
        checkICloudStatus()
        performAutomaticBackup()
    }

    // MARK: - 狀態檢查

    /// 監聽 App 退到背景時自動觸發備份
    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.performAutomaticBackup()
        }
    }

    /// 監聽 iCloud 帳號登入/登出變化
    private func setupUbiquityObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSUbiquityIdentityDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkICloudStatus()
        }
    }

    /// 確保「檔案」App 中的 PicDeck 自動備份資料夾與中文說明存在
    private func ensureAutoBackupDirectory() {
        let dir = autoBackupDirectoryURL
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        let readmeURL = dir.appendingPathComponent("備份說明.txt")
        if !fileManager.fileExists(atPath: readmeURL.path) {
            let infoText = """
            【PicDeck 自動備份資料夾】
            此資料夾由 PicDeck App 自動維護與同步。
            當您在 App 中新增標籤、撰寫日記、編輯相片備註時，系統會自動於背景在此處更新最新的備份檔案。
            若您刪除 App 後重新安裝，App 啟動時會自動偵測此目錄並為您全量還原！
            """
            try? infoText.write(to: readmeURL, atomically: true, encoding: .utf8)
        }
    }

    /// 異步檢查 iCloud 是否可用與容器路徑
    func checkICloudStatusAsync() async {
        let (available, url) = await Task.detached(priority: .userInitiated) { [fileManager, ubiquityContainerID] () -> (Bool, URL?) in
            guard fileManager.ubiquityIdentityToken != nil else {
                return (false, nil)
            }
            guard let containerURL = fileManager.url(forUbiquityContainerIdentifier: ubiquityContainerID)
                ?? fileManager.url(forUbiquityContainerIdentifier: nil) else {
                return (false, nil)
            }
            let docsURL = containerURL.appendingPathComponent("Documents")
            if !fileManager.fileExists(atPath: docsURL.path) {
                try? fileManager.createDirectory(at: docsURL, withIntermediateDirectories: true)
            }
            return (true, docsURL)
        }.value

        self.isICloudAvailable = available
        self.cloudDocumentsURL = url
        if !available {
            self.lastSyncDate = nil
        }
    }

    /// 檢查 iCloud 是否可用與容器路徑
    func checkICloudStatus() {
        Task {
            await checkICloudStatusAsync()
            if self.isICloudAvailable {
                self.initialSyncAndMigration()
            }
        }
    }

    private func setupKVStoreObserver() {
        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: kvStore,
            queue: .main
        ) { [weak self] _ in
            self?.handleKVStoreChange()
        }
        kvStore.synchronize()
    }

    private func handleKVStoreChange() {
        guard isICloudAvailable else { return }
        NotificationCenter.default.post(name: Self.didSyncFromCloudNotification, object: nil)
    }

    // MARK: - 啟動初次同步與重裝自動還原

    /// 當本機資料為空（刪除 App 又重新安裝時），自動嘗試從「檔案」App 的 PicDeck 自動備份目錄還原
    private func restoreFromAutoBackupIfNeeded() {
        let files = ["tags.json", "journal.json", "journal-categories.json", "notes.json"]
        let hasAnyLocal = files.contains { fileManager.fileExists(atPath: localDocumentsURL.appendingPathComponent($0).path) }
        if !hasAnyLocal {
            let backupFile = autoBackupDirectoryURL.appendingPathComponent("PicDeck_最新自動備份.picdeck")
            if fileManager.fileExists(atPath: backupFile.path) {
                _ = restoreFromBackupArchive(at: backupFile)
            }
        }
    }

    /// App 啟動時：若本機為空但雲端有資料（刪除重裝情境），自動還原！
    /// 若本機有資料但雲端為空，自動備份至雲端。
    func initialSyncAndMigration() {
        restoreFromAutoBackupIfNeeded()

        Task.detached(priority: .utility) { [weak self, fileManager, localDocumentsURL] in
            guard let self else { return }
            let isAvailable = await MainActor.run { self.isICloudAvailable }
            guard isAvailable else { return }
            guard let cloudURL = await MainActor.run(body: { self.cloudDocumentsURL }) else { return }

            let syncedFiles = ["tags.json", "journal.json", "journal-categories.json", "notes.json"]
            var didSyncAny = false

            for filename in syncedFiles {
                let localFile = localDocumentsURL.appendingPathComponent(filename)
                let cloudFile = cloudURL.appendingPathComponent(filename)

                let localExists = fileManager.fileExists(atPath: localFile.path)
                let cloudExists = fileManager.fileExists(atPath: cloudFile.path)

                if !localExists && cloudExists {
                    // 情境 1：使用者刪除 App 又重新安裝，本地沒有，雲端有備份 -> 自動還原！
                    if (try? fileManager.copyItem(at: cloudFile, to: localFile)) != nil {
                        didSyncAny = true
                    }
                } else if localExists && !cloudExists {
                    // 情境 2：本地有舊資料，但尚未上傳雲端 -> 自動備份至雲端！
                    if (try? fileManager.copyItem(at: localFile, to: cloudFile)) != nil {
                        didSyncAny = true
                    }
                } else if localExists && cloudExists {
                    // 情境 3：兩邊都有，比較修改時間
                    if let localAttr = try? fileManager.attributesOfItem(atPath: localFile.path),
                       let cloudAttr = try? fileManager.attributesOfItem(atPath: cloudFile.path),
                       let localDate = localAttr[.modificationDate] as? Date,
                       let cloudDate = cloudAttr[.modificationDate] as? Date {
                        if cloudDate > localDate {
                            // 雲端比較新 -> 還原至本地
                            _ = try? fileManager.removeItem(at: localFile)
                            if (try? fileManager.copyItem(at: cloudFile, to: localFile)) != nil {
                                didSyncAny = true
                            }
                        } else if localDate > cloudDate {
                            // 本地比較新 -> 上傳至雲端
                            _ = try? fileManager.removeItem(at: cloudFile)
                            if (try? fileManager.copyItem(at: localFile, to: cloudFile)) != nil {
                                didSyncAny = true
                            }
                        }
                    }
                }
            }

            if didSyncAny {
                await MainActor.run {
                    self.lastSyncDate = Date()
                    NotificationCenter.default.post(name: Self.didSyncFromCloudNotification, object: nil)
                }
            }
        }
    }

    // MARK: - 檔案讀寫介面（由各 Store 呼叫）

    /// 讀取檔案資料：優先自本地讀取（最快最即時），若本地不存在則嘗試從 iCloud 載入並快取到本地
    func readData(filename: String) -> Data? {
        let localFile = localDocumentsURL.appendingPathComponent(filename)
        if let data = try? Data(contentsOf: localFile) {
            return data
        }

        // 本地沒有，嘗試從 iCloud 容器讀取
        if isICloudAvailable, let cloudURL = cloudDocumentsURL {
            let cloudFile = cloudURL.appendingPathComponent(filename)
            if let data = try? Data(contentsOf: cloudFile) {
                // 快取回本地供日後離線使用
                try? data.write(to: localFile, options: .atomic)
                return data
            }
        }
        return nil
    }

    /// 執行全自動備份（每次資料變更或 App 退到背景時自動呼叫）
    func performAutomaticBackup() {
        Task.detached(priority: .utility) { [weak self, fileManager, localDocumentsURL] in
            guard let self else { return }
            let dir = await MainActor.run { self.autoBackupDirectoryURL }
            if !fileManager.fileExists(atPath: dir.path) {
                try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
            }

            let files = ["tags.json", "journal.json", "journal-categories.json", "notes.json"]
            var backupDict: [String: Any] = [
                "version": 1,
                "backupDate": Date().timeIntervalSince1970,
                "app": "PicDeck"
            ]

            var hasAnyData = false
            for filename in files {
                let fileURL = localDocumentsURL.appendingPathComponent(filename)
                if let data = try? Data(contentsOf: fileURL),
                   let json = try? JSONSerialization.jsonObject(with: data) {
                    backupDict[filename] = json
                    hasAnyData = true
                }
            }

            guard hasAnyData else { return }

            guard let data = try? JSONSerialization.data(withJSONObject: backupDict, options: [.prettyPrinted]) else {
                return
            }

            let latestBackupURL = dir.appendingPathComponent("PicDeck_最新自動備份.picdeck")
            try? data.write(to: latestBackupURL, options: .atomic)

            await MainActor.run {
                self.lastAutoBackupDate = Date()
            }
        }
    }

    /// 寫入檔案：本地原子寫入 + 自動備份 + 背景鏡像至 iCloud
    func writeData(_ data: Data, filename: String) {
        let localFile = localDocumentsURL.appendingPathComponent(filename)
        // 1. 本地立即寫入
        try? data.write(to: localFile, options: .atomic)

        // 2. 自動更新「檔案」App 中的 PicDeck 最新自動備份
        performAutomaticBackup()

        // 3. 非同步鏡像至 iCloud 容器（僅在 iCloud 可用時執行）
        guard isICloudAvailable, let cloudURL = cloudDocumentsURL else { return }
        Task.detached(priority: .utility) { [fileManager] in
            let cloudFile = cloudURL.appendingPathComponent(filename)
            do {
                try data.write(to: cloudFile, options: .atomic)
                await MainActor.run {
                    CloudSyncService.shared.lastSyncDate = Date()
                }
            } catch {
                // 雲端寫入失敗不更新時間
            }
        }
    }

    // MARK: - Key-Value 偏好設置同步（選集、封面設定）

    func syncDataToCloudKV(key: String, data: Data) {
        guard isICloudAvailable else { return }
        kvStore.set(data, forKey: key)
        kvStore.synchronize()
    }

    func readDataFromCloudKV(key: String) -> Data? {
        guard isICloudAvailable else { return nil }
        return kvStore.data(forKey: key)
    }

    // MARK: - 使用者手動操作

    enum SyncCheckResult {
        case connected
        case notSignedIn
        case containerUnavailable
    }

    /// 手動立即強制同步並回報結果
    @discardableResult
    func forceSyncNow() async -> SyncCheckResult {
        isSyncing = true
        defer { isSyncing = false }

        await checkICloudStatusAsync()

        guard isICloudAvailable, let cloudURL = cloudDocumentsURL else {
            if fileManager.ubiquityIdentityToken == nil {
                return .notSignedIn
            } else {
                return .containerUnavailable
            }
        }

        initialSyncAndMigration()
        kvStore.synchronize()
        try? await Task.sleep(nanoseconds: 500_000_000)
        lastSyncDate = Date()
        return .connected
    }

    // MARK: - 手動資料備份與還原（防刪除保護）

    /// 建立本機資料整合備份檔（包含標籤、日記、分類與照片備註）
    func createBackupArchiveURL() -> URL? {
        let files = ["tags.json", "journal.json", "journal-categories.json", "notes.json"]
        var backupDict: [String: Any] = [
            "version": 1,
            "exportDate": Date().timeIntervalSince1970
        ]

        for filename in files {
            let fileURL = localDocumentsURL.appendingPathComponent(filename)
            if let data = try? Data(contentsOf: fileURL),
               let json = try? JSONSerialization.jsonObject(with: data) {
                backupDict[filename] = json
            }
        }

        guard let data = try? JSONSerialization.data(withJSONObject: backupDict, options: [.prettyPrinted]) else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent("PicDeck_Backup_\(timestamp).picdeck")
        do {
            try data.write(to: tempURL, options: .atomic)
            return tempURL
        } catch {
            return nil
        }
    }

    /// 從備份檔還原資料
    func restoreFromBackupArchive(at url: URL) -> Bool {
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        guard let data = try? Data(contentsOf: url),
              let dict = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
            return false
        }

        let files = ["tags.json", "journal.json", "journal-categories.json", "notes.json"]
        var restoredCount = 0

        for filename in files {
            if let obj = dict[filename],
               let fileData = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]) {
                let localFile = localDocumentsURL.appendingPathComponent(filename)
                if (try? fileData.write(to: localFile, options: .atomic)) != nil {
                    restoredCount += 1
                }
            }
        }

        if restoredCount > 0 {
            NotificationCenter.default.post(name: Self.didSyncFromCloudNotification, object: nil)
            return true
        }
        return false
    }
}
