import Foundation

/// App 與桌面小工具共用的資料。App 寫進 App Group 資料夾，小工具只讀。
/// 小工具是獨立的程式，看不到 App 的標籤與相簿，所以由 App 預先算好。
struct WidgetTag: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    /// 表情符號（如果標籤用的是表情）。
    var emoji: String?
    /// SF Symbol 名稱（如果標籤用的是圖標）。
    var symbolName: String?
    /// 例如「5 張」，已經依語言排好。
    var countText: String
    /// 設了日子的標籤：從今天起每一天的文字，例如「6年1個月16天」。第 0 個是產生當天。沒有日子就是空陣列。
    var dayTexts: [String]
    /// 封面縮圖檔名（在 covers 資料夾），最多三張，最新的在前。
    var coverFiles: [String]
    /// 第一張封面的位置與放大（跟 App 的卡片一樣）。舊資料沒有就置中。
    var coverFraming: CoverFraming?
    var hasDays: Bool { !dayTexts.isEmpty }
}

struct WidgetSnapshot: Codable {
    /// 產生的那一天的 0 點。小工具用它算今天對應 `dayTexts` 的第幾個。
    var day: Date
    var tags: [WidgetTag]
    /// 日子卡片文字的位置與樣式（跟 App 的「選集」同一份設定）。舊資料沒有就用預設。
    var textPosition: CardTextPosition?
    var textStyle: CardTextStyle?

    static let groupID = "group.com.picdeck.app"
    static let dayCount = 21

    static var directory: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)?
            .appendingPathComponent("Widget", isDirectory: true)
    }
    static var coversDirectory: URL? { directory?.appendingPathComponent("covers", isDirectory: true) }
    private static var fileURL: URL? { directory?.appendingPathComponent("snapshot.json") }

    static func load() -> WidgetSnapshot? {
        guard let url = fileURL, let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    func write() {
        guard let directory = Self.directory, let url = Self.fileURL else { return }
        try? FileManager.default.createDirectory(at: Self.coversDirectory!, withIntermediateDirectories: true)
        if let data = try? JSONEncoder().encode(self) { try? data.write(to: url, options: .atomic) }
    }

    /// 某一天要顯示的日子文字。超過預先算好的範圍就回最後一天的。
    func dayText(for tag: WidgetTag, on date: Date) -> String? {
        guard tag.hasDays else { return nil }
        let days = Calendar.current.dateComponents([.day], from: day, to: Calendar.current.startOfDay(for: date)).day ?? 0
        return tag.dayTexts[max(0, min(days, tag.dayTexts.count - 1))]
    }
}
