import Foundation

/// 選集頁上的一個區塊。使用者可以調整順序、隱藏，也可以自己加「標籤月曆／週曆」。
struct HomeSectionConfig: Codable, Identifiable, Hashable {
    enum Kind: String, Codable {
        /// 舊版：所有日子標籤合成一個區塊。開啟時會拆成每個標籤各一列（dayCard）。
        case days
        /// 舊版：所有釘選標籤合成一個區塊。開啟時會拆成每個標籤各一列（tagCard）。
        case pinnedTags
        /// 一個設了日期的標籤卡片（顯示過了多久）。
        case dayCard
        /// 一個釘在首頁的標籤卡片（封面與張數）。
        case tagCard
        /// 往年的今天。
        case onThisDay
        /// 某個標籤在「當月」或「當週」拍的照片，排成月曆或週曆。
        case tagPeriod
    }

    enum Period: String, Codable, CaseIterable, Identifiable {
        case month, week
        var id: String { rawValue }
    }

    var id = UUID()
    var kind: Kind
    var tagID: UUID?
    var period: Period?
    var isHidden = false

    static let defaults: [HomeSectionConfig] = [
        HomeSectionConfig(kind: .days),
        HomeSectionConfig(kind: .pinnedTags),
        HomeSectionConfig(kind: .onThisDay),
    ]
}
