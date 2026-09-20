import Foundation

/// 紀念日的計算方式。
///
/// 起算日當天，D-day 是 D+0、日數是第 1 天，兩者差一天，這與常見的紀念日 App 一致。
enum AnniversaryStyle: String, Codable, CaseIterable, Identifiable, Sendable {
    /// D+2237
    case dday
    /// 2238 天
    case days
    /// 319 週 5 天
    case weeks
    /// 73 個月 15 天
    case months
    /// 6 年 1 個月 15 天
    case yearMonthDay

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dday: return String(localized: "D-day")
        case .days: return String(localized: "Days")
        case .weeks: return String(localized: "Weeks")
        case .months: return String(localized: "Months")
        case .yearMonthDay: return String(localized: "Years, months, days")
        }
    }
}

/// 從起算日到某一天的長度，依選定方式換算成文字。
enum Anniversary {

    /// 只取年月日，時分秒一律歸零，避免同一天因時間不同算出差一天。
    static func startOfDay(_ date: Date) -> Date {
        PhotoGrouping.calendar.startOfDay(for: date)
    }

    /// 起算日到目標日之間相隔幾天。起算日當天是 0，之前是負數。
    static func elapsedDays(from start: Date, to target: Date) -> Int {
        let calendar = PhotoGrouping.calendar
        let parts = calendar.dateComponents([.day],
                                            from: startOfDay(start),
                                            to: startOfDay(target))
        return parts.day ?? 0
    }

    /// 依方式算出顯示文字，例如「6 年 1 個月 15 天」。
    /// 目標日早於起算日時，前面加上負號。
    static func text(from start: Date, to target: Date, style: AnniversaryStyle) -> String {
        let elapsed = elapsedDays(from: start, to: target)

        switch style {
        case .dday:
            // D-day 不加負號，改用 D- 表示還沒到。
            return elapsed >= 0 ? "D+\(elapsed)" : "D-\(-elapsed)"

        case .days:
            // 起算日當天算第 1 天。
            let days = elapsed >= 0 ? elapsed + 1 : elapsed - 1
            return signed(format("%lld days", abs(days)), isNegative: days < 0)

        case .weeks:
            let days = elapsed >= 0 ? elapsed + 1 : -(elapsed - 1)
            let total = abs(days)
            let weeks = total / 7
            let rest = total % 7
            let text = weeks == 0
                ? format("%lld days", rest)
                : format("%1$lldw %2$lldd", weeks, rest)
            return signed(text, isNegative: elapsed < 0)

        case .months:
            let parts = span(from: start, to: target, components: [.month, .day])
            let text = (parts.month ?? 0) == 0
                ? format("%lld days", parts.day ?? 0)
                : format("%1$lldmo %2$lldd", parts.month ?? 0, parts.day ?? 0)
            return signed(text, isNegative: elapsed < 0)

        case .yearMonthDay:
            let parts = span(from: start, to: target, components: [.year, .month, .day])
            let year = parts.year ?? 0
            let month = parts.month ?? 0
            let day = parts.day ?? 0
            let text: String
            if year > 0 {
                text = format("%1$lldy %2$lldmo %3$lldd", year, month, day)
            } else if month > 0 {
                text = format("%1$lldmo %2$lldd", month, day)
            } else {
                text = format("%lld days", day)
            }
            return signed(text, isNegative: elapsed < 0)
        }
    }

    /// 兩個日期之間的年月日差距，永遠取正值，方向由呼叫端處理。
    private static func span(from start: Date,
                             to target: Date,
                             components: Set<Calendar.Component>) -> DateComponents {
        let a = startOfDay(start)
        let b = startOfDay(target)
        let earlier = min(a, b)
        let later = max(a, b)
        return PhotoGrouping.calendar.dateComponents(components, from: earlier, to: later)
    }

    private static func signed(_ text: String, isNegative: Bool) -> String {
        isNegative ? "-" + text : text
    }

    /// 用固定的 key 取翻譯再套數字，避免字串插值產生不可預期的 key。
    private static func format(_ key: String.LocalizationValue, _ args: CVarArg...) -> String {
        String(format: String(localized: key), arguments: args)
    }
}
