import Foundation
import Photos
import UIKit
import WidgetKit

/// 把標籤整理成桌面小工具看得懂的資料，寫進 App Group 資料夾，並通知小工具重新整理。
/// 小工具是獨立的程式，讀不到相簿與標籤，所以標籤名稱、封面縮圖、每天的日子文字都由這裡預先算好。
@MainActor
enum WidgetSync {
    private static var isRunning = false
    private static var pending = false

    static func sync(tagStore: TagStore, library: PhotoLibraryService, model: AppModel) async {
        // 連續觸發時只留最後一次，不要同時跑好幾份。
        guard !isRunning else { pending = true; return }
        isRunning = true
        defer {
            isRunning = false
            if pending { pending = false; Task { await sync(tagStore: tagStore, library: library, model: model) } }
        }
        guard let coversDirectory = WidgetSnapshot.coversDirectory else { return }
        try? FileManager.default.createDirectory(at: coversDirectory, withIntermediateDirectories: true)

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // 有日子的標籤與釘在首頁的排前面，小工具挑標籤時比較好找。
        let ordered = tagStore.tags.sorted {
            ($0.hasAnniversary ? 0 : ($0.pinnedOnHome ? 1 : 2)) < ($1.hasAnniversary ? 0 : ($1.pinnedOnHome ? 1 : 2))
        }

        var output: [WidgetTag] = []
        var keepFiles = Set<String>()
        for tag in ordered {
            let ids = tagStore.assetIDs(withTag: tag.id)
            var assets = library.assets(withIDs: ids)
                .sorted { ($0.creationDate ?? .distantPast) > ($1.creationDate ?? .distantPast) }
            // 自己選的封面排第一張。
            if let custom = tag.coverAssetID, let asset = library.asset(withID: custom) {
                assets.removeAll { $0.localIdentifier == custom }
                assets.insert(asset, at: 0)
            }
            var files: [String] = []
            for (index, asset) in assets.prefix(3).enumerated() {
                guard let image = await ThumbnailLoader.shared.image(for: asset, size: 640),
                      let data = image.jpegData(compressionQuality: 0.8) else { continue }
                let name = "\(tag.id.uuidString)-\(index).jpg"
                try? data.write(to: coversDirectory.appendingPathComponent(name), options: .atomic)
                files.append(name)
                keepFiles.insert(name)
            }

            var emoji: String?
            var symbolName: String?
            switch AppIcon.decode(tag.symbol) {
            case .emoji(let value): emoji = value
            case .symbol(let name, _): symbolName = name
            case .none: break
            }

            var dayTexts: [String] = []
            if tag.hasAnniversary {
                for offset in 0..<WidgetSnapshot.dayCount {
                    if let day = calendar.date(byAdding: .day, value: offset, to: today),
                       let text = tag.anniversaryText(on: day) {
                        dayTexts.append(text)
                    }
                }
            }
            output.append(WidgetTag(id: tag.id.uuidString,
                                    name: tag.name,
                                    emoji: emoji,
                                    symbolName: symbolName,
                                    countText: String(format: String(localized: "%lld photos"), ids.count),
                                    dayTexts: dayTexts,
                                    coverFiles: files,
                                    coverFraming: tag.coverAssetID == nil ? nil : tag.coverFraming))
        }

        // 刪掉已經不用的封面。
        if let existing = try? FileManager.default.contentsOfDirectory(atPath: coversDirectory.path) {
            for name in existing where !keepFiles.contains(name) {
                try? FileManager.default.removeItem(at: coversDirectory.appendingPathComponent(name))
            }
        }
        WidgetSnapshot(day: today, tags: output,
                       textPosition: model.cardTextPosition, textStyle: model.cardTextStyle).write()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
