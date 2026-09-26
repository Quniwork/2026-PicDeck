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
    /// 最後一次確認已寫入或讀取的系統說明；nil 代表尚未同步的舊版備註。
    var lastSyncedCaption: String?
}

/// 照片備註；iOS 27 起與系統照片說明雙向同步。
@MainActor
final class NoteStore: ObservableObject {

    @Published private(set) var notes: [String: PhotoNote] = [:]

    private var fingerprintIndex: [String: String] = [:]
    private let fileURL: URL
    private let filename: String
    private var saveTask: Task<Void, Never>?
    private weak var library: PhotoLibraryService?
    private var captionTasks: [String: Task<Void, Never>] = [:]
    private var pendingCaptions: [String: String] = [:]

    func attach(library: PhotoLibraryService) {
        self.library = library
    }

    init(filename: String = "notes.json") {
        self.filename = filename
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documents.appendingPathComponent(filename)
        load()

        NotificationCenter.default.addObserver(forName: CloudSyncService.didSyncFromCloudNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.load() }
        }
    }

    // MARK: - 查詢

    func note(for asset: PHAsset) -> PhotoNote? {
        if let note = notes[asset.localIdentifier] { return note }
        let fingerprint = OrganizedStore.fingerprint(for: asset)
        return fingerprintIndex[fingerprint].flatMap { notes[$0] }
    }

    /// 重新取得照片庫的資產，避免沿用畫面中舊 PHAsset 的說明內容。
    func refreshFromPhotos(for asset: PHAsset) async {
        guard #available(iOS 27.0, *) else { return }
        let id = asset.localIdentifier
        let result = await Task.detached(priority: .userInitiated) { () -> (Bool, String?) in
            guard let current = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject else {
                return (false, nil)
            }
            return (true, current.extendedMetadata.caption)
        }.value
        guard !Task.isCancelled, result.0, pendingCaptions[id] == nil else { return }
        let systemText = result.1?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let fingerprint = OrganizedStore.fingerprint(for: asset)
        let old = note(for: asset)

        if let old, old.lastSyncedCaption == nil, systemText.isEmpty {
            // 舊版只存在 PicDeck 的備註首次同步時寫到照片庫。
            queueCaptionWrite(old.text, for: asset)
            return
        }
        if let old, old.text == systemText {
            if old.lastSyncedCaption != systemText {
                var synced = old
                synced.lastSyncedCaption = systemText
                notes[old.id] = synced
                scheduleSave()
            }
            return
        }
        if let old, old.lastSyncedCaption == systemText {
            // 上次寫入失敗或中斷後，保留本機輸入並重試。
            queueCaptionWrite(old.text, for: asset)
            return
        }

        if let old { notes.removeValue(forKey: old.id) }
        if systemText.isEmpty {
            fingerprintIndex.removeValue(forKey: fingerprint)
        } else {
            notes[id] = PhotoNote(id: id, fingerprint: fingerprint, text: systemText,
                                  isDone: old?.isDone ?? false, lastSyncedCaption: systemText)
            fingerprintIndex[fingerprint] = id
        }
        scheduleSave()
    }

    func note(withID id: String) -> PhotoNote? {
        notes[id]
    }

    func hasNote(_ asset: PHAsset) -> Bool { note(for: asset) != nil }

    /// 所有備註，最近改過的在前。
    var sortedNotes: [PhotoNote] {
        notes.values.sorted { $0.updatedAt > $1.updatedAt }
    }

    // MARK: - 寫入

    /// 存備註。文字清空就等於刪掉這則備註，並同步寫入系統「照片.app」說明欄位。
    func save(text: String, isDone: Bool, for asset: PHAsset) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let key = asset.localIdentifier

        let currentNote = notes[key]
        if let currentNote, currentNote.text == trimmed, currentNote.isDone == isDone {
            return
        }
        if currentNote == nil && trimmed.isEmpty {
            return
        }

        let fingerprint = OrganizedStore.fingerprint(for: asset)

        // 換機後識別碼可能改變，先清掉指紋對應的舊紀錄。
        if let oldKey = fingerprintIndex[fingerprint], oldKey != key {
            notes.removeValue(forKey: oldKey)
        }

        if trimmed.isEmpty {
            notes.removeValue(forKey: key)
            fingerprintIndex.removeValue(forKey: fingerprint)
        } else {
            notes[key] = PhotoNote(id: key, fingerprint: fingerprint, text: trimmed,
                                   isDone: isDone, lastSyncedCaption: currentNote?.lastSyncedCaption)
            fingerprintIndex[fingerprint] = key
        }
        scheduleSave()

        queueCaptionWrite(trimmed, for: asset)
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

        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject {
            queueCaptionWrite("", for: asset)
        }
    }

    private func queueCaptionWrite(_ text: String, for asset: PHAsset) {
        guard #available(iOS 27.0, *), let library else { return }
        let id = asset.localIdentifier
        let previous = captionTasks[id]
        pendingCaptions[id] = text
        captionTasks[id] = Task { [weak self] in
            await previous?.value
            guard let self, !Task.isCancelled else { return }
            // 快速連續編輯只寫入最後一版。
            guard pendingCaptions[id] == text else { return }
            let succeeded = await library.updateCaption(text, for: asset)
            if succeeded, var note = notes[id], note.text == text {
                note.lastSyncedCaption = text
                notes[id] = note
                scheduleSave()
            }
            if pendingCaptions[id] == text { pendingCaptions.removeValue(forKey: id) }
        }
    }

    // MARK: - 持久化

    private func load() {
        guard let data = CloudSyncService.shared.readData(filename: filename) ?? (try? Data(contentsOf: fileURL)),
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
        let fileURL = self.fileURL
        let filename = self.filename
        Task.detached(priority: .utility) {
            guard let data = try? JSONEncoder().encode(snapshot) else { return }
            try? data.write(to: fileURL, options: .atomic)
            await MainActor.run {
                CloudSyncService.shared.writeData(data, filename: filename)
            }
        }
    }

    func flush() {
        saveTask?.cancel()
        save()
    }
}
