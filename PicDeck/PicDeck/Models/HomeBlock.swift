import Foundation
import CoreGraphics

/// 卡片大小。
///
/// 自動換行（wrap）：
/// - 小：一排兩欄，高度是寬度的 1/2
/// - 中：一排兩欄，高度與寬度相同
/// - 大：一排一欄，高度是寬度的 1/2，往下排
///
/// 橫向捲動（no wrap）：卡片排成一列往右滑，最右邊那張刻意被切掉一截，提示還可以滑；
/// 比例跟上面一樣，小、中一次看到兩張多一點，大一次看到一張多一點。
enum CardSize: String, Codable, CaseIterable, Identifiable {
    case small, medium, large
    var id: String { rawValue }

    /// `contentWidth` 是整個畫面的內容寬度（含左右邊距）。
    func dimensions(contentWidth: CGFloat, wraps: Bool, spacing: CGFloat = 12) -> CGSize {
        let sideMargin: CGFloat = 16
        if wraps {
            let available = contentWidth - sideMargin * 2
            let half = (available - spacing) / 2
            switch self {
            case .small: return CGSize(width: half, height: half / 2)
            case .medium: return CGSize(width: half, height: half)
            case .large: return CGSize(width: available, height: available / 2)
            }
        }
        let scrollable = contentWidth - sideMargin
        switch self {
        case .small:
            let width = (scrollable - spacing * 2) / 2.35
            return CGSize(width: width, height: width / 2)
        case .medium:
            let width = (scrollable - spacing * 2) / 2.35
            return CGSize(width: width, height: width)
        case .large:
            let width = (scrollable - spacing) / 1.2
            return CGSize(width: width, height: width / 2)
        }
    }

    /// 卡片上的字依卡片大小縮放：小卡不要太小、大卡不要太大，全部落在 0.85 到 0.95 之間。
    static func textScale(for size: CGSize) -> CGFloat {
        let basis = min(size.width, size.height * 1.6)
        return min(0.95, max(0.85, basis / 300))
    }
}

/// 選集頁上的一個區塊。使用者自己建立、命名、排序，每個區塊有自己的標籤與顯示方式。
///
/// - 日子：設了日期的標籤，卡片顯示過了多久。
/// - 標籤：任何標籤（包含有日期的），卡片或列表。
/// - 月曆／週曆：某些標籤在當月、當週拍的照片，排在對應的日子上。
/// - 那年今天：系統區塊，往年今天拍的照片。
struct HomeBlock: Codable, Identifiable, Hashable {
    enum Mode: String, Codable, CaseIterable, Identifiable {
        case days, tags, monthCalendar, weekCalendar, onThisDay
        var id: String { rawValue }
    }

    /// 標籤區塊的呈現方式。
    enum TagsLayout: String, Codable, CaseIterable, Identifiable {
        case cards, list
        var id: String { rawValue }
    }

    var id = UUID()
    var mode: Mode
    /// 使用者取的標題。空的就用種類的預設名稱。
    var title: String = ""
    var tagIDs: [UUID] = []
    var isHidden = false
    /// 卡片大小（日子區塊、標籤區塊的卡片）。
    var size: CardSize = .small
    /// 自動換行（true）或橫向捲動（false，預設）。
    var wraps: Bool = false
    /// 標籤區塊：卡片或列表。
    var layout: TagsLayout = .cards

    /// 這個區塊放的是標籤（不含系統區塊）。
    var holdsTags: Bool { mode != .onThisDay }

    static let defaults: [HomeBlock] = [
        HomeBlock(mode: .days),
        HomeBlock(mode: .tags),
        HomeBlock(mode: .onThisDay),
    ]
}

/// 區塊種類的名稱、圖標與說明。
enum HomeBlockNames {
    static func defaultTitle(for mode: HomeBlock.Mode) -> String {
        switch mode {
        case .days: return String(localized: "Days")
        case .tags: return String(localized: "Tags")
        case .monthCalendar: return String(localized: "Month calendar")
        case .weekCalendar: return String(localized: "Week calendar")
        case .onThisDay: return String(localized: "On this day")
        }
    }

    static func icon(for mode: HomeBlock.Mode) -> String {
        switch mode {
        case .days: return "calendar.badge.clock"
        case .tags: return "tag"
        case .monthCalendar: return "calendar"
        case .weekCalendar: return "calendar.day.timeline.left"
        case .onThisDay: return "clock.arrow.circlepath"
        }
    }

    static func explanation(for mode: HomeBlock.Mode) -> String {
        switch mode {
        case .days: return String(localized: "Cards that show how long it has been since a date, such as a birthday. You can add tags with a date here.")
        case .tags: return String(localized: "Any tags, including tags with a date, shown as cards or a list.")
        case .monthCalendar: return String(localized: "The photos of the tags you pick, laid out on the days of this month.")
        case .weekCalendar: return String(localized: "The photos of the tags you pick, laid out on the days of this week.")
        case .onThisDay: return String(localized: "Photos taken on this day in past years.")
        }
    }
}
