import Foundation
import Photos

/// 依年、月、日分組的結果。分組都在背景執行，上萬張也不會卡住畫面。
enum PhotoGrouping {

    /// 一個分組（某一年、某一月或某一天）。
    struct Bucket: Identifiable, Hashable {
        let id: String
        let title: String
        let count: Int
        let coverID: String?
        let year: Int
        let month: Int?
        let day: Int?
    }

    /// 月檢視用：月份卡片加上該月哪幾天有照片。
    struct MonthCalendar: Identifiable, Hashable {
        let id: String
        let year: Int
        let month: Int
        /// 卡片上方顯示的月份名稱，例如「9月」。
        let title: String
        let count: Int
        let coverID: String?
        /// 該月有照片的日期。
        let daysWithPhotos: Set<Int>
        /// 該月第一天是星期幾（1 = 週日，依系統曆法）。
        let firstWeekday: Int
        /// 該月共有幾天。
        let dayCount: Int
    }

    /// 日檢視用：某一天的格子內容。
    struct DayCell: Identifiable, Hashable {
        let id: String
        let day: Int
        let count: Int
        let coverID: String?
        /// 日記心情表情，目前還沒有日記資料來源，先保留欄位。
        let mood: String?
    }

    /// 日檢視用：一個月的日曆。
    struct MonthOfDays: Identifiable {
        let id: String
        let year: Int
        let month: Int
        let title: String
        /// 該月一號是星期幾（依 calendar 的 weekday 編號）。
        let firstWeekday: Int
        let dayCount: Int
        /// 有照片的日期，key 是日。
        let cells: [Int: DayCell]
    }

    /// 依年份分組的月曆，年檢視與月檢視共用。
    struct YearOfMonths: Identifiable {
        let id: String
        let year: Int
        let months: [MonthCalendar]
    }

    /// 時間軸用的一段：一天的標題加上那天的照片。
    struct DaySection: Identifiable {
        let id: String
        let title: String
        let weekday: String
        /// 這一段代表的日期，用來算紀念日天數。
        let date: Date
        let count: Int
        let assets: [PHAsset]
    }

    /// 一週從週日開始。
    static let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        return calendar
    }()

    /// 週日到週六的標題。
    static var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let offset = calendar.firstWeekday - 1
        return Array(symbols[offset...] + symbols[..<offset])
    }

    // MARK: - 年

    static func years(from assets: [PHAsset]) async -> [Bucket] {
        await Task.detached(priority: .userInitiated) {
            var map: [Int: [PHAsset]] = [:]
            for asset in assets {
                guard let date = asset.creationDate else { continue }
                let year = calendar.component(.year, from: date)
                map[year, default: []].append(asset)
            }

            return map
                .sorted { $0.key > $1.key }
                .map { year, items in
                    Bucket(id: "y\(year)",
                           title: "\(year)",
                           count: items.count,
                           coverID: items.first?.localIdentifier,
                           year: year, month: nil, day: nil)
                }
        }.value
    }

    // MARK: - 月

    /// 傳入 year 就只回傳該年的月份，否則回傳所有月份。
    static func months(from assets: [PHAsset], year: Int? = nil) async -> [Bucket] {
        await Task.detached(priority: .userInitiated) {
            var map: [DateComponents: [PHAsset]] = [:]
            for asset in assets {
                guard let date = asset.creationDate else { continue }
                let parts = calendar.dateComponents([.year, .month], from: date)
                if let year, parts.year != year { continue }
                map[parts, default: []].append(asset)
            }

            return map
                .compactMap { parts, items -> (Bucket, Date)? in
                    guard let y = parts.year, let m = parts.month,
                          let date = calendar.date(from: parts) else { return nil }
                    // 在某一年底下只顯示月份名稱，跨年檢視才帶年份。
                    let title = year == nil ? DateTitle.month(year: y, month: m)
                                            : DateTitle.monthShort(month: m)
                    let bucket = Bucket(id: "m\(y)-\(m)",
                                        title: title,
                                        count: items.count,
                                        coverID: items.first?.localIdentifier,
                                        year: y, month: m, day: nil)
                    return (bucket, date)
                }
                .sorted { $0.1 > $1.1 }
                .map(\.0)
        }.value
    }

    // MARK: - 月曆

    /// 產生帶小月曆的月份卡片，依年份分組（最新的年在前）。
    /// 傳入 year 就只算該年。
    static func monthCalendars(from assets: [PHAsset], year: Int? = nil) async -> [YearOfMonths] {
        await Task.detached(priority: .userInitiated) {
            var monthAssets: [DateComponents: [PHAsset]] = [:]
            var monthDays: [DateComponents: Set<Int>] = [:]

            for asset in assets {
                guard let date = asset.creationDate else { continue }
                let parts = calendar.dateComponents([.year, .month, .day], from: date)
                if let year, parts.year != year { continue }
                let key = DateComponents(year: parts.year, month: parts.month)
                monthAssets[key, default: []].append(asset)
                if let day = parts.day {
                    monthDays[key, default: []].insert(day)
                }
            }

            var byYear: [Int: [MonthCalendar]] = [:]

            for (key, items) in monthAssets {
                guard let y = key.year, let m = key.month,
                      let monthStart = calendar.date(from: key),
                      let range = calendar.range(of: .day, in: .month, for: monthStart) else { continue }

                let card = MonthCalendar(id: "mc\(y)-\(m)",
                                         year: y,
                                         month: m,
                                         title: DateTitle.monthShort(month: m),
                                         count: items.count,
                                         coverID: items.first?.localIdentifier,
                                         daysWithPhotos: monthDays[key] ?? [],
                                         firstWeekday: calendar.component(.weekday, from: monthStart),
                                         dayCount: range.count)
                byYear[y, default: []].append(card)
            }

            return byYear
                .sorted { $0.key > $1.key }
                .map { year, months in
                    YearOfMonths(id: "yr\(year)",
                                 year: year,
                                 months: months.sorted { $0.month < $1.month })
                }
        }.value
    }

    // MARK: - 日曆（日檢視）

    /// 產生依月份分組的日曆，每一天帶封面與張數。最新的月份在前。
    static func dayCalendars(from assets: [PHAsset]) async -> [MonthOfDays] {
        await Task.detached(priority: .userInitiated) {
            var dayAssets: [DateComponents: [PHAsset]] = [:]

            for asset in assets {
                guard let date = asset.creationDate else { continue }
                let parts = calendar.dateComponents([.year, .month, .day], from: date)
                dayAssets[parts, default: []].append(asset)
            }

            var byMonth: [DateComponents: [Int: DayCell]] = [:]
            for (parts, items) in dayAssets {
                guard let day = parts.day else { continue }
                let monthKey = DateComponents(year: parts.year, month: parts.month)
                let cell = DayCell(id: "dc\(parts.year ?? 0)-\(parts.month ?? 0)-\(day)",
                                   day: day,
                                   count: items.count,
                                   coverID: items.first?.localIdentifier,
                                   mood: nil)
                byMonth[monthKey, default: [:]][day] = cell
            }

            return byMonth
                .compactMap { key, cells -> (MonthOfDays, Date)? in
                    guard let y = key.year, let m = key.month,
                          let monthStart = calendar.date(from: key),
                          let range = calendar.range(of: .day, in: .month, for: monthStart) else { return nil }

                    let month = MonthOfDays(id: "md\(y)-\(m)",
                                            year: y,
                                            month: m,
                                            title: DateTitle.month(year: y, month: m),
                                            firstWeekday: calendar.component(.weekday, from: monthStart),
                                            dayCount: range.count,
                                            cells: cells)
                    return (month, monthStart)
                }
                .sorted { $0.1 > $1.1 }
                .map(\.0)
        }.value
    }

    // MARK: - 日

    /// 傳入 year/month 就只回傳該月的日期。
    static func days(from assets: [PHAsset], year: Int? = nil, month: Int? = nil) async -> [Bucket] {
        await Task.detached(priority: .userInitiated) {
            var map: [DateComponents: [PHAsset]] = [:]
            for asset in assets {
                guard let date = asset.creationDate else { continue }
                let parts = calendar.dateComponents([.year, .month, .day], from: date)
                if let year, parts.year != year { continue }
                if let month, parts.month != month { continue }
                map[parts, default: []].append(asset)
            }

            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none

            return map
                .compactMap { parts, items -> (Bucket, Date)? in
                    guard let y = parts.year, let m = parts.month, let d = parts.day,
                          let date = calendar.date(from: parts) else { return nil }
                    // 在某一月底下只顯示日期數字，跨月檢視才帶完整日期。
                    let title = (year == nil || month == nil) ? formatter.string(from: date)
                                                              : DateTitle.dayShort(day: d)
                    let bucket = Bucket(id: "d\(y)-\(m)-\(d)",
                                        title: title,
                                        count: items.count,
                                        coverID: items.first?.localIdentifier,
                                        year: y, month: m, day: d)
                    return (bucket, date)
                }
                .sorted { $0.1 > $1.1 }
                .map(\.0)
        }.value
    }

    // MARK: - 某一天的照片

    static func assets(from assets: [PHAsset], year: Int, month: Int, day: Int) async -> [PHAsset] {
        await Task.detached(priority: .userInitiated) {
            assets.filter { asset in
                guard let date = asset.creationDate else { return false }
                let parts = calendar.dateComponents([.year, .month, .day], from: date)
                return parts.year == year && parts.month == month && parts.day == day
            }
        }.value
    }

    // MARK: - 時間軸

    /// 依日期分段，最新的在前。limit 可限制每段張數（摘要式檢視用）。
    static func daySections(from assets: [PHAsset], limit: Int = .max) async -> [DaySection] {
        await Task.detached(priority: .userInitiated) {
            var map: [DateComponents: [PHAsset]] = [:]
            for asset in assets {
                guard let date = asset.creationDate else { continue }
                let parts = calendar.dateComponents([.year, .month, .day], from: date)
                map[parts, default: []].append(asset)
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none

            let weekdayFormatter = DateFormatter()
            weekdayFormatter.setLocalizedDateFormatFromTemplate("EEEE")

            return map
                .compactMap { parts, items -> (DaySection, Date)? in
                    guard let y = parts.year, let m = parts.month, let d = parts.day,
                          let date = calendar.date(from: parts) else { return nil }
                    let section = DaySection(id: "s\(y)-\(m)-\(d)",
                                             title: dateFormatter.string(from: date),
                                             weekday: weekdayFormatter.string(from: date),
                                             date: date,
                                             count: items.count,
                                             assets: Array(items.prefix(limit)))
                    return (section, date)
                }
                .sorted { $0.1 > $1.1 }
                .map(\.0)
        }.value
    }
}
