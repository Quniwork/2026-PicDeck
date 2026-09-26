import Foundation
import Photos

/// 一篇日記：心情表情加上文字。同一天可以有好幾篇，用 `dateKey` 分組，`id` 是這一篇自己的識別碼。
struct JournalEntry: Codable, Hashable, Identifiable {
    var id: String
    /// 這篇屬於哪一天，格式 yyyy-MM-dd。
    var dateKey: String
    var mood: String
    var text: String
    /// 這篇日記附帶的照片，由使用者自己挑。
    var photoIDs: [String] = []
    /// 日記自己的分類（跟照片標籤是兩回事），沒選就是 nil。
    var categoryID: JournalCategory.ID? = nil
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    private enum CodingKeys: String, CodingKey {
        case id, dateKey, mood, text, photoIDs, categoryID, createdAt, updatedAt
    }

    init(id: String = UUID().uuidString, dateKey: String, mood: String, text: String,
         photoIDs: [String] = [], categoryID: JournalCategory.ID? = nil,
         createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.dateKey = dateKey
        self.mood = mood
        self.text = text
        self.photoIDs = photoIDs
        self.categoryID = categoryID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        // 舊資料沒有 dateKey 欄位：那時候 id 本身就是日期鍵（一天一篇），拿它當回填。
        dateKey = try container.decodeIfPresent(String.self, forKey: .dateKey) ?? id
        mood = try container.decode(String.self, forKey: .mood)
        text = try container.decode(String.self, forKey: .text)
        photoIDs = try container.decodeIfPresent([String].self, forKey: .photoIDs) ?? []
        categoryID = try container.decodeIfPresent(JournalCategory.ID.self, forKey: .categoryID)
        let updated = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
        updatedAt = updated
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? updated
    }
}

/// 日記自己的分類（例如生活、工作、心情），跟照片標籤是兩套獨立系統。
struct JournalCategory: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var symbol: String = "sf:tag"
}

/// 日記資料。同一天可以寫好幾篇，用 `JournalEntry.id`（不是日期）當儲存的鍵。
@MainActor
final class JournalStore: ObservableObject {

    @Published private(set) var entries: [String: JournalEntry] = [:]
    @Published private(set) var categories: [JournalCategory] = []

    private let fileURL: URL
    private let categoriesFileURL: URL
    private let filename: String
    private let categoriesFilename: String
    private var saveTask: Task<Void, Never>?
    private var saveCategoriesTask: Task<Void, Never>?

    /// 可選的心情表情。
    nonisolated static let moods = ["😀", "🙂", "😐", "😔", "😭", "😡", "🥰", "🤒", "🎉", "💡"]

    init(filename: String = "journal.json", categoriesFilename: String = "journal-categories.json") {
        self.filename = filename
        self.categoriesFilename = categoriesFilename
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documents.appendingPathComponent(filename)
        self.categoriesFileURL = documents.appendingPathComponent(categoriesFilename)
        load()
        loadCategories()

        NotificationCenter.default.addObserver(forName: CloudSyncService.didSyncFromCloudNotification, object: nil, queue: .main) { [weak self] _ in
            self?.load()
            self?.loadCategories()
        }
    }

    // MARK: - 日期鍵

    nonisolated static func key(year: Int, month: Int, day: Int) -> String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }

    nonisolated static func key(for date: Date) -> String {
        let parts = PhotoGrouping.calendar.dateComponents([.year, .month, .day], from: date)
        return key(year: parts.year ?? 0, month: parts.month ?? 0, day: parts.day ?? 0)
    }

    nonisolated static func key(for asset: PHAsset) -> String? {
        guard let date = asset.creationDate else { return nil }
        return key(for: date)
    }

    /// 由日期鍵拆回年月日。
    nonisolated static func components(fromKey key: String) -> (year: Int, month: Int, day: Int)? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return (parts[0], parts[1], parts[2])
    }

    // MARK: - 查詢

    func entry(id: String) -> JournalEntry? {
        entries[id]
    }

    /// 這一天的所有日記，依寫下的先後排（同一天由上到下疊起來）。
    func entries(onDateKey key: String) -> [JournalEntry] {
        entries.values.filter { $0.dateKey == key }.sorted { $0.createdAt < $1.createdAt }
    }

    /// 這張照片所屬的那一篇日記（相容舊呼叫）。
    func entry(for asset: PHAsset) -> JournalEntry? {
        entries(for: asset).first
    }

    /// 這張照片所屬的所有日記（依日期由新到舊排）。
    func entries(for asset: PHAsset) -> [JournalEntry] {
        let id = asset.localIdentifier
        return entries.values.filter { $0.photoIDs.contains(id) }
            .sorted { $0.dateKey > $1.dateKey }
    }

    /// 這一天代表性的心情（月曆用），取最新寫的那一篇。
    func mood(year: Int, month: Int, day: Int) -> String? {
        entries(onDateKey: Self.key(year: year, month: month, day: day)).last?.mood
    }

    var count: Int { entries.count }

    /// 這張照片是否已經被放進任何一篇日記。放進去之後就不再提供「寫日記」。
    func isInJournal(_ asset: PHAsset) -> Bool {
        let id = asset.localIdentifier
        return entries.values.contains { $0.photoIDs.contains(id) }
    }

    // MARK: - 寫入

    /// 新增一篇，永遠是新的一篇，就算當天已經有別篇了。
    @discardableResult
    func create(mood: String, text: String, photoIDs: [String], dateKey: String,
                categoryID: JournalCategory.ID?, createdAt: Date? = nil) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !(trimmed.isEmpty && mood.isEmpty && photoIDs.isEmpty) else { return nil }
        let id = UUID().uuidString
        let date = createdAt ?? Date()
        entries[id] = JournalEntry(id: id, dateKey: dateKey, mood: mood, text: trimmed,
                                   photoIDs: photoIDs, categoryID: categoryID,
                                   createdAt: date, updatedAt: Date())
        scheduleSave()
        return id
    }

    /// 更新指定的那一篇；內容都清空就整篇刪掉。
    func update(id: String, mood: String, text: String, photoIDs: [String],
                categoryID: JournalCategory.ID?, dateKey: String? = nil,
                createdAt: Date? = nil) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty && mood.isEmpty && photoIDs.isEmpty {
            entries.removeValue(forKey: id)
        } else if var existing = entries[id] {
            existing.mood = mood
            existing.text = trimmed
            existing.photoIDs = photoIDs
            existing.categoryID = categoryID
            if let dateKey { existing.dateKey = dateKey }
            if let createdAt { existing.createdAt = createdAt }
            existing.updatedAt = Date()
            entries[id] = existing
        }
        scheduleSave()
    }

    /// 所有日記，依日期由新到舊（同一天內由先寫到後寫）。
    var sortedEntries: [JournalEntry] {
        entries.values.sorted {
            $0.dateKey == $1.dateKey ? $0.createdAt < $1.createdAt : $0.dateKey > $1.dateKey
        }
    }

    func delete(id: String) {
        entries.removeValue(forKey: id)
        scheduleSave()
    }

    func resetForTesting() {
        entries.removeAll()
        categories.removeAll()
        // 立刻寫檔，不要排程延遲：測試常常按下去馬上就把 App 整個關掉，
        // 400ms 的延遲存檔根本來不及跑，下次啟動又讀回沒清乾淨的舊資料。
        flush()
    }

    // MARK: - 分類

    func addCategory(name: String, symbol: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        categories.append(JournalCategory(name: trimmed, symbol: symbol))
        scheduleSaveCategories()
    }

    func renameCategory(id: JournalCategory.ID, to name: String, symbol: String) {
        guard let index = categories.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        categories[index].name = trimmed
        categories[index].symbol = symbol
        scheduleSaveCategories()
    }

    /// 刪除分類；用過這個分類的日記改回「沒有分類」，不連帶刪除日記本身。
    func deleteCategory(id: JournalCategory.ID) {
        categories.removeAll { $0.id == id }
        for key in entries.keys where entries[key]?.categoryID == id {
            entries[key]?.categoryID = nil
        }
        scheduleSaveCategories()
        scheduleSave()
    }

    func category(withID id: JournalCategory.ID?) -> JournalCategory? {
        guard let id else { return nil }
        return categories.first { $0.id == id }
    }

    func moveCategories(fromOffsets source: IndexSet, toOffset destination: Int) {
        categories.move(fromOffsets: source, toOffset: destination)
        scheduleSaveCategories()
    }

    // MARK: - 持久化

    private func load() {
        guard let data = CloudSyncService.shared.readData(filename: filename) ?? (try? Data(contentsOf: fileURL)),
              let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) else { return }
        entries = Dictionary(decoded.map { ($0.id, $0) }) { first, _ in first }
    }

    private func loadCategories() {
        guard let data = CloudSyncService.shared.readData(filename: categoriesFilename) ?? (try? Data(contentsOf: categoriesFileURL)),
              let decoded = try? JSONDecoder().decode([JournalCategory].self, from: data) else { return }
        categories = decoded
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
        let snapshot = Array(entries.values)
        let filename = self.filename
        Task.detached(priority: .utility) {
            guard let data = try? JSONEncoder().encode(snapshot) else { return }
            await MainActor.run {
                CloudSyncService.shared.writeData(data, filename: filename)
            }
        }
    }

    private func scheduleSaveCategories() {
        saveCategoriesTask?.cancel()
        saveCategoriesTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            self?.saveCategories()
        }
    }

    private func saveCategories() {
        let snapshot = categories
        let filename = self.categoriesFilename
        Task.detached(priority: .utility) {
            guard let data = try? JSONEncoder().encode(snapshot) else { return }
            await MainActor.run {
                CloudSyncService.shared.writeData(data, filename: filename)
            }
        }
    }

    func flush() {
        saveTask?.cancel()
        saveCategoriesTask?.cancel()
        save()
        saveCategories()
    }
}
