import Foundation
import Photos

/// 使用者自訂的標籤。可以綁一個紀念日，用來算孩子年齡這類天數。
struct PhotoTag: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    /// 顯示用的表情符號。
    var symbol: String
    var createdAt: Date = Date()
    /// 紀念日的日期。沒設就是一般標籤。
    var anniversary: Date?
    /// 紀念日的換算方式。
    var anniversaryStyle: AnniversaryStyle = .yearMonthDay
    /// 釘選後會顯示在時間軸與日記的日期旁邊。
    var isPinned: Bool = false
    /// 釘在首頁。首頁會把它當成一個收藏，點進去可以再用其他標籤篩選。
    var pinnedOnHome: Bool = false

    /// 有日期才算紀念日標籤。
    var hasAnniversary: Bool { anniversary != nil }

    /// 這個標籤在某一天要顯示的文字，沒有紀念日就回 nil。
    func anniversaryText(on date: Date) -> String? {
        guard let anniversary else { return nil }
        return Anniversary.text(from: anniversary, to: date, style: anniversaryStyle)
    }

    // 舊版的 tags.json 沒有紀念日欄位，這裡用 decodeIfPresent 讓舊檔也讀得進來。
    init(id: UUID = UUID(),
         name: String,
         symbol: String,
         createdAt: Date = Date(),
         anniversary: Date? = nil,
         anniversaryStyle: AnniversaryStyle = .yearMonthDay,
         isPinned: Bool = false) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.createdAt = createdAt
        self.anniversary = anniversary
        self.anniversaryStyle = anniversaryStyle
        self.isPinned = isPinned
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        symbol = try container.decodeIfPresent(String.self, forKey: .symbol) ?? TagStore.defaultSymbol
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        anniversary = try container.decodeIfPresent(Date.self, forKey: .anniversary)
        anniversaryStyle = try container.decodeIfPresent(AnniversaryStyle.self,
                                                         forKey: .anniversaryStyle) ?? .yearMonthDay
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        pinnedOnHome = try container.decodeIfPresent(Bool.self, forKey: .pinnedOnHome) ?? false
    }
}

/// 標籤與照片的對應關係。
///
/// 跟已整理狀態一樣不動系統相簿，紀錄存在 Documents 目錄的 JSON 檔，
/// 每筆除了 PhotoKit 識別碼另存指紋，換機或重裝後識別碼失效時可用指紋重新綁定。
@MainActor
final class TagStore: ObservableObject {

    struct Assignment: Codable, Hashable {
        var localIdentifier: String
        var fingerprint: String
        var tagIDs: [UUID]
        /// 最後一次改標籤的時間。舊資料沒有。
        var updatedAt: Date? = nil
    }

    private struct Payload: Codable {
        var tags: [PhotoTag]
        var assignments: [Assignment]
    }

    @Published private(set) var tags: [PhotoTag] = []
    @Published private(set) var assignments: [String: Assignment] = [:]

    private var fingerprintIndex: [String: String] = [:]
    private let fileURL: URL
    private var saveTask: Task<Void, Never>?

    init(filename: String = "tags.json") {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documents.appendingPathComponent(filename)
        load()
        seedAnniversaryTagIfRequested()
    }

    /// 給 UI 測試用。帶 -seedAnniversaryTag 啟動時放一個固定的紀念日標籤，
    /// 這樣不必在測試裡操作日期選擇器。正常啟動不會執行。
    private func seedAnniversaryTagIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains("-seedAnniversaryTag") else { return }
        var parts = DateComponents()
        parts.year = 2020
        parts.month = 8
        parts.day = 5
        guard let date = PhotoGrouping.calendar.date(from: parts) else { return }

        let name = "堯"
        if let index = tags.firstIndex(where: { Self.normalizedName($0.name) == Self.normalizedName(name) }) {
            tags[index].anniversary = date
            tags[index].anniversaryStyle = .yearMonthDay
            tags[index].isPinned = true
            tags[index].pinnedOnHome = true
        } else {
            tags.append(PhotoTag(name: name,
                                 symbol: "🧒",
                                 anniversary: date,
                                 anniversaryStyle: .yearMonthDay,
                                 isPinned: true))
            tags[tags.count - 1].pinnedOnHome = true
        }
        scheduleSave()
    }

    // MARK: - 查詢

    func tagIDs(for asset: PHAsset) -> Set<UUID> {
        if let assignment = assignments[asset.localIdentifier] {
            return Set(assignment.tagIDs)
        }
        let fingerprint = OrganizedStore.fingerprint(for: asset)
        if let identifier = fingerprintIndex[fingerprint],
           let assignment = assignments[identifier] {
            return Set(assignment.tagIDs)
        }
        return []
    }

    func tags(for asset: PHAsset) -> [PhotoTag] {
        let ids = tagIDs(for: asset)
        return tags.filter { ids.contains($0.id) }
    }

    func tag(withID id: UUID) -> PhotoTag? {
        tags.first { $0.id == id }
    }

    /// 掛著這個標籤的照片識別碼。
    func assetIDs(withTag tagID: UUID) -> [String] {
        assignments.values.filter { $0.tagIDs.contains(tagID) }.map(\.localIdentifier)
    }

    /// 這個標籤被用在幾張照片上。
    func usageCount(of tagID: UUID) -> Int {
        assignments.values.filter { $0.tagIDs.contains(tagID) }.count
    }

    // MARK: - 標籤管理

    /// 沒有指定圖示時用的預設標籤符號。
    nonisolated static let defaultSymbol = "🏷️"

    /// 比對名稱用的正規化：去掉前後空白，忽略大小寫與全形半形差異。
    nonisolated static func normalizedName(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .widthInsensitive, .diacriticInsensitive],
                     locale: .current)
    }

    /// 這個名稱是不是已經有人用了。改名時用 excluding 略過自己。
    func nameExists(_ name: String, excluding id: UUID? = nil) -> Bool {
        let target = Self.normalizedName(name)
        guard !target.isEmpty else { return false }
        return tags.contains { $0.id != id && Self.normalizedName($0.name) == target }
    }

    /// 建立標籤。名稱空白或與現有標籤重複時不建立，回傳 nil。
    @discardableResult
    func createTag(name: String,
                   symbol: String,
                   anniversary: Date? = nil,
                   anniversaryStyle: AnniversaryStyle = .yearMonthDay,
                   isPinned: Bool = false,
                   pinnedOnHome: Bool = false) -> PhotoTag? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !nameExists(trimmed) else { return nil }
        var tag = PhotoTag(name: trimmed,
                           symbol: symbol,
                           anniversary: anniversary.map { Anniversary.startOfDay($0) },
                           anniversaryStyle: anniversaryStyle,
                           isPinned: anniversary == nil ? false : isPinned)
        tag.pinnedOnHome = pinnedOnHome
        tags.append(tag)
        scheduleSave()
        return tag
    }

    /// 改名。名稱空白或撞到其他標籤時不改，回傳 false。
    @discardableResult
    func renameTag(id: UUID, name: String, symbol: String) -> Bool {
        guard let index = tags.firstIndex(where: { $0.id == id }) else { return false }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !nameExists(trimmed, excluding: id) else { return false }
        tags[index].name = trimmed
        tags[index].symbol = symbol
        scheduleSave()
        return true
    }

    /// 一次更新名稱、符號與紀念日設定。名稱空白或撞名時整筆不改。
    @discardableResult
    func updateTag(id: UUID,
                   name: String,
                   symbol: String,
                   anniversary: Date?,
                   anniversaryStyle: AnniversaryStyle,
                   isPinned: Bool,
                   pinnedOnHome: Bool? = nil) -> Bool {
        guard let index = tags.firstIndex(where: { $0.id == id }) else { return false }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !nameExists(trimmed, excluding: id) else { return false }
        tags[index].name = trimmed
        tags[index].symbol = symbol
        tags[index].anniversary = anniversary.map { Anniversary.startOfDay($0) }
        tags[index].anniversaryStyle = anniversaryStyle
        // 沒有日期就沒有東西好釘。
        tags[index].isPinned = anniversary == nil ? false : isPinned
        if let pinnedOnHome { tags[index].pinnedOnHome = pinnedOnHome }
        scheduleSave()
        return true
    }

    /// 免費版可以有幾個設了日子的標籤。
    static let freeAnniversaryLimit = 1

    /// 目前有日子的標籤數，可以排除正在編輯的那一個。
    func anniversaryCount(excluding id: UUID? = nil) -> Int {
        tags.filter { $0.hasAnniversary && $0.id != id }.count
    }

    /// 釘在首頁的標籤（不含紀念日標籤，那些本來就有自己的卡片）。
    var homePinnedTags: [PhotoTag] { tags.filter { $0.pinnedOnHome && !$0.hasAnniversary } }

    /// 跟這個標籤出現在同一張照片上的其他標籤，依使用次數多到少。首頁收藏用來做二次篩選。
    func coTags(of tagID: UUID) -> [PhotoTag] {
        var counts: [UUID: Int] = [:]
        for assignment in assignments.values where assignment.tagIDs.contains(tagID) {
            for other in assignment.tagIDs where other != tagID { counts[other, default: 0] += 1 }
        }
        return tags.filter { counts[$0.id] != nil }
            .sorted { (counts[$0.id] ?? 0) > (counts[$1.id] ?? 0) }
    }

    /// 調整標籤的顯示順序。這個順序會套用到篩選選單、加標籤與管理頁。
    func moveTags(fromOffsets source: IndexSet, toOffset destination: Int) {
        tags.move(fromOffsets: source, toOffset: destination)
        scheduleSave()
    }

    /// 釘選且有日期的標籤，依建立順序。這些會顯示在時間軸與日記的日期旁邊。
    var pinnedAnniversaryTags: [PhotoTag] {
        tags.filter { $0.isPinned && $0.hasAnniversary }
    }

    func deleteTag(id: UUID) {
        tags.removeAll { $0.id == id }
        for (key, var assignment) in assignments {
            guard assignment.tagIDs.contains(id) else { continue }
            assignment.tagIDs.removeAll { $0 == id }
            if assignment.tagIDs.isEmpty {
                assignments.removeValue(forKey: key)
                fingerprintIndex.removeValue(forKey: assignment.fingerprint)
            } else {
                assignments[key] = assignment
            }
        }
        scheduleSave()
    }

    // MARK: - 指派

    func setTags(_ tagIDs: Set<UUID>, for asset: PHAsset) {
        let fingerprint = OrganizedStore.fingerprint(for: asset)
        let key = asset.localIdentifier

        // 換機後識別碼可能改變，先清掉指紋對應的舊紀錄。
        if let oldKey = fingerprintIndex[fingerprint], oldKey != key {
            assignments.removeValue(forKey: oldKey)
        }

        if tagIDs.isEmpty {
            assignments.removeValue(forKey: key)
            fingerprintIndex.removeValue(forKey: fingerprint)
        } else {
            assignments[key] = Assignment(localIdentifier: key,
                                          fingerprint: fingerprint,
                                          tagIDs: Array(tagIDs),
                                          updatedAt: Date())
            fingerprintIndex[fingerprint] = key
        }
        scheduleSave()
    }

    /// 這張照片標籤最後一次被改的時間。
    func lastEdited(for asset: PHAsset) -> Date? {
        assignments[asset.localIdentifier]?.updatedAt
    }

    func toggleTag(_ tagID: UUID, for asset: PHAsset) {
        var current = tagIDs(for: asset)
        if current.contains(tagID) {
            current.remove(tagID)
        } else {
            current.insert(tagID)
        }
        setTags(current, for: asset)
    }

    /// 一次幫多張照片加上同一個標籤。
    func addTag(_ tagID: UUID, to assets: [PHAsset]) {
        for asset in assets {
            var current = tagIDs(for: asset)
            current.insert(tagID)
            setTags(current, for: asset)
        }
    }

    func resetForTesting() {
        tags.removeAll()
        assignments.removeAll()
        fingerprintIndex.removeAll()
        scheduleSave()
    }

    // MARK: - 持久化

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let payload = try? JSONDecoder().decode(Payload.self, from: data) else { return }

        // 舊資料可能有重複名稱。只留最早建立的那一個，
        // 被併掉的標籤在指派紀錄裡改指向保留下來的那一個。
        var keptByName: [String: UUID] = [:]
        var remap: [UUID: UUID] = [:]
        var deduped: [PhotoTag] = []
        for tag in payload.tags.sorted(by: { $0.createdAt < $1.createdAt }) {
            let key = Self.normalizedName(tag.name)
            if let kept = keptByName[key] {
                remap[tag.id] = kept
            } else {
                keptByName[key] = tag.id
                deduped.append(tag)
            }
        }
        tags = deduped

        let migrated = payload.assignments.map { assignment -> Assignment in
            guard !remap.isEmpty else { return assignment }
            var copy = assignment
            var ids: [UUID] = []
            for id in assignment.tagIDs {
                let mapped = remap[id] ?? id
                if !ids.contains(mapped) { ids.append(mapped) }
            }
            copy.tagIDs = ids
            return copy
        }
        assignments = Dictionary(migrated.map { ($0.localIdentifier, $0) }) { first, _ in first }
        fingerprintIndex = Dictionary(migrated.map { ($0.fingerprint, $0.localIdentifier) }) { first, _ in first }
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
        let payload = Payload(tags: tags, assignments: Array(assignments.values))
        let url = fileURL
        Task.detached(priority: .utility) {
            guard let data = try? JSONEncoder().encode(payload) else { return }
            try? data.write(to: url, options: .atomic)
        }
    }

    func flush() {
        saveTask?.cancel()
        save()
    }
}
