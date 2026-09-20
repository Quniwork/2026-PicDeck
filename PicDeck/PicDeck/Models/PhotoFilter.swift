import Foundation

/// 照片分頁的篩選條件。免費版只能用 `.all`，其餘為付費解鎖。
enum PhotoFilter: String, CaseIterable, Identifiable, Hashable {
    case all
    case favorites
    case photos
    case videos
    case screenshots
    /// 在系統照片裡編輯過（調整、濾鏡、裁切）。
    case edited
    /// 沒有放進任何自己建立的相簿。
    case notInAlbum

    var id: String { rawValue }

    var isFree: Bool { self == .all }

    var title: String {
        switch self {
        case .all: return String(localized: "All Items")
        case .favorites: return String(localized: "Favorites")
        case .photos: return String(localized: "Photos")
        case .videos: return String(localized: "Videos")
        case .screenshots: return String(localized: "Screenshots")
        case .edited: return String(localized: "Edited")
        case .notInAlbum: return String(localized: "Not in an album")
        }
    }

    var systemImage: String {
        switch self {
        case .all: return "square.grid.3x3"
        case .favorites: return "heart"
        case .photos: return "photo"
        case .videos: return "video"
        case .screenshots: return "camera.viewfinder"
        case .edited: return "slider.horizontal.3"
        case .notInAlbum: return "rectangle.on.rectangle.slash"
        }
    }
}

/// 照片分頁目前選的篩選：系統分類或使用者標籤。
enum PhotoSelection: Hashable {
    case filter(PhotoFilter)
    case tag(UUID)

    /// 免費版只有「全部」可用，標籤篩選需付費。
    var isFree: Bool {
        if case .filter(let filter) = self { return filter.isFree }
        return false
    }

    var isAll: Bool {
        if case .filter(.all) = self { return true }
        return false
    }
}

/// 照片分頁的子分頁。順序對齊參考 App：年、月、日、日記、時間軸、全部。
enum PhotoScale: String, CaseIterable, Identifiable, Hashable {
    case year
    case month
    case day
    /// 依日期分段、帶標題資訊的瀏覽（參考 App 的「展開」）。
    case timeline
    /// 純格狀、不帶日期資訊的密集瀏覽（參考 App 的「緊湊」）。
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .year: return String(localized: "Year")
        case .month: return String(localized: "Month")
        case .day: return String(localized: "Day")
        case .timeline: return String(localized: "Timeline")
        case .all: return String(localized: "All")
        }
    }

    var isFree: Bool { true }
}

/// 整理分頁的待整理集合。
enum OrganizeBucket: Hashable, Identifiable {
    case allUnorganized
    case unorganizedPhotos
    case unorganizedVideos
    case unorganizedScreenshots
    case month(year: Int, month: Int)

    var id: String {
        switch self {
        case .allUnorganized: return "all"
        case .unorganizedPhotos: return "photos"
        case .unorganizedVideos: return "videos"
        case .unorganizedScreenshots: return "screenshots"
        case .month(let year, let month): return "\(year)-\(month)"
        }
    }

    var title: String {
        switch self {
        case .allUnorganized: return String(localized: "All unorganized")
        case .unorganizedPhotos: return String(localized: "Unorganized photos")
        case .unorganizedVideos: return String(localized: "Unorganized videos")
        case .unorganizedScreenshots: return String(localized: "Unorganized screenshots")
        case .month(let year, let month):
            return DateTitle.month(year: year, month: month)
        }
    }
}

/// 共用的日期標題格式。
enum DateTitle {
    static func month(year: Int, month: Int) -> String {
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        guard let date = Calendar.current.date(from: parts) else { return "\(year)" }
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("yyyyMMMM")
        return formatter.string(from: date)
    }

    static func monthShort(month: Int) -> String {
        var parts = DateComponents()
        parts.year = 2000
        parts.month = month
        guard let date = Calendar.current.date(from: parts) else { return "\(month)" }
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMM")
        return formatter.string(from: date)
    }

    static func day(year: Int, month: Int, day: Int) -> String {
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        guard let date = Calendar.current.date(from: parts) else { return "\(day)" }
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    static func dayShort(day: Int) -> String { "\(day)" }

    /// 一段日期，例如 2025/5/11 至 2025/5/17。同一天就只顯示那一天。
    static func range(from start: Date, to end: Date) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("yMd")

        let calendar = PhotoGrouping.calendar
        let earlier = min(start, end)
        let later = max(start, end)
        let head = formatter.string(from: earlier)
        guard !calendar.isDate(earlier, inSameDayAs: later) else { return head }
        return String(format: String(localized: "%1$@ – %2$@"), head, formatter.string(from: later))
    }

    /// 不帶星期的日期，例如 2026年9月19日。
    static func dayMedium(year: Int, month: Int, day: Int) -> String {
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        guard let date = Calendar.current.date(from: parts) else { return "\(day)" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

enum GridContext: String {
    case all, timeline, journal

    init?(_ scale: PhotoScale) {
        switch scale {
        case .all: self = .all
        case .timeline: self = .timeline
        default: return nil
        }
    }
}
