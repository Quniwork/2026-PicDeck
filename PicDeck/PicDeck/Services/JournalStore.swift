import Foundation
import Photos

/// 一天一篇日記：心情表情加上文字。
struct JournalEntry: Codable, Hashable, Identifiable {
    /// 以日期當 id，格式 yyyy-MM-dd。
    var id: String
    var mood: String
    var text: String
    /// 這篇日記附帶的照片，由使用者自己挑。
    var photoIDs: [String] = []
    var updatedAt: Date = Date()
}

/// 日記資料。以「日」為單位，不綁定單張照片，
/// 所以在任何一張當天的照片上寫日記，都是同一篇。
@MainActor
final class JournalStore: ObservableObject {

    @Published private(set) var entries: [String: JournalEntry] = [:]

    private let fileURL: URL
    private var saveTask: Task<Void, Never>?

    /// 可選的心情表情。
    nonisolated static let moods = ["😀", "🙂", "😐", "😔", "😭", "😡", "🥰", "🤒", "🎉", "💡"]

    init(filename: String = "journal.json") {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documents.appendingPathComponent(filename)
        load()
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

    // MARK: - 查詢

    func entry(forKey key: String) -> JournalEntry? {
        entries[key]
    }

    func entry(for asset: PHAsset) -> JournalEntry? {
        guard let key = Self.key(for: asset) else { return nil }
        return entries[key]
    }

    func mood(year: Int, month: Int, day: Int) -> String? {
        entries[Self.key(year: year, month: month, day: day)]?.mood
    }

    var count: Int { entries.count }

    // MARK: - 寫入

    func save(mood: String, text: String, photoIDs: [String], forKey key: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty && mood.isEmpty && photoIDs.isEmpty {
            entries.removeValue(forKey: key)
        } else {
            entries[key] = JournalEntry(id: key, mood: mood, text: trimmed, photoIDs: photoIDs)
        }
        scheduleSave()
    }

    /// 所有日記，最新的在前。
    var sortedEntries: [JournalEntry] {
        entries.values.sorted { $0.id > $1.id }
    }

    /// 由日期鍵拆回年月日。
    nonisolated static func components(fromKey key: String) -> (year: Int, month: Int, day: Int)? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return (parts[0], parts[1], parts[2])
    }

    func delete(forKey key: String) {
        entries.removeValue(forKey: key)
        scheduleSave()
    }

    func resetForTesting() {
        entries.removeAll()
        scheduleSave()
    }

    // MARK: - 持久化

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) else { return }
        entries = Dictionary(decoded.map { ($0.id, $0) }) { first, _ in first }
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
        let url = fileURL
        Task.detached(priority: .utility) {
            guard let data = try? JSONEncoder().encode(snapshot) else { return }
            try? data.write(to: url, options: .atomic)
        }
    }

    func flush() {
        saveTask?.cancel()
        save()
    }
}
