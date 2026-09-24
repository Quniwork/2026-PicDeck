import Foundation
import Photos

/// 一張照片的備註。例如標了 #美食 的照片，備註寫哪間餐廳、地點、營業時間、評價。
struct PhotoNote: Codable, Identifiable, Hashable {
    /// 照片的 localIdentifier。
    var id: String
    /// 換機或重裝後識別碼失效時，用指紋重新綁回同一張照片。
    var fingerprint: String
    var text: String
    /// 這件事做了沒，例如餐廳吃過了、景點去過了。
    var isDone: Bool = false
    var updatedAt: Date = Date()
}

/// 照片備註。跟標籤一樣只存在 App 自己的資料裡，不動系統照片。
@MainActor
final class NoteStore: ObservableObject {

    @Published private(set) var notes: [String: PhotoNote] = [:]

    private var fingerprintIndex: [String: String] = [:]
    private let fileURL: URL
    private var saveTask: Task<Void, Never>?

    init(filename: String = "notes.json") {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documents.appendingPathComponent(filename)
        load()
    }

    // MARK: - 查詢

    func note(for asset: PHAsset) -> PhotoNote? {
        if let note = notes[asset.localIdentifier] { return note }
        let fingerprint = OrganizedStore.fingerprint(for: asset)
        if let id = fingerprintIndex[fingerprint] { return notes[id] }
        return nil
    }

    func hasNote(_ asset: PHAsset) -> Bool { note(for: asset) != nil }

    /// 所有備註，最近改過的在前。
    var sortedNotes: [PhotoNote] {
        notes.values.sorted { $0.updatedAt > $1.updatedAt }
    }

    // MARK: - 寫入

    /// 存備註。文字清空就等於刪掉這則備註。
    func save(text: String, isDone: Bool, for asset: PHAsset) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let key = asset.localIdentifier
        let fingerprint = OrganizedStore.fingerprint(for: asset)

        // 換機後識別碼可能改變，先清掉指紋對應的舊紀錄。
        if let oldKey = fingerprintIndex[fingerprint], oldKey != key {
            notes.removeValue(forKey: oldKey)
        }

        if trimmed.isEmpty {
            notes.removeValue(forKey: key)
            fingerprintIndex.removeValue(forKey: fingerprint)
        } else {
            notes[key] = PhotoNote(id: key, fingerprint: fingerprint, text: trimmed, isDone: isDone)
            fingerprintIndex[fingerprint] = key
        }
        scheduleSave()
    }

    func save(text: String, for asset: PHAsset) {
        let isDone = note(for: asset)?.isDone ?? false
        save(text: text, isDone: isDone, for: asset)
    }

    func setDone(_ isDone: Bool, forNoteID id: String) {
        guard var note = notes[id] else { return }
        note.isDone = isDone
        notes[id] = note
        scheduleSave()
    }

    func delete(noteID id: String) {
        guard let note = notes.removeValue(forKey: id) else { return }
        fingerprintIndex.removeValue(forKey: note.fingerprint)
        scheduleSave()
    }

    // MARK: - 持久化

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([PhotoNote].self, from: data) else { return }
        notes = Dictionary(decoded.map { ($0.id, $0) }) { first, _ in first }
        fingerprintIndex = Dictionary(decoded.map { ($0.fingerprint, $0.id) }) { first, _ in first }
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
        let snapshot = Array(notes.values)
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
