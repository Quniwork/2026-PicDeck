import SwiftUI
import UIKit

/// 標籤符號與日記心情共用的圖示。
///
/// 存的還是一個字串，所以舊資料不用搬：
/// 表情符號就存表情符號本身，系統圖示存成 `sf:heart.fill#red`。
/// 空字串代表沒有圖示。
enum AppIcon: Hashable {
    case none
    case emoji(String)
    /// SF Symbol 名稱加上顏色。顏色是 nil 就跟著文字色。
    /// 顏色存成 token：內建色存名字（如 red），自訂色存六碼十六進位（如 FF6B00）。
    case symbol(name: String, tint: String?)

    // MARK: - 編碼

    private static let symbolPrefix = "sf:"

    /// 從存起來的字串還原。認不得的一律當成表情符號。
    static func decode(_ raw: String) -> AppIcon {
        if raw.isEmpty { return .none }
        guard raw.hasPrefix(symbolPrefix) else { return .emoji(raw) }

        let body = String(raw.dropFirst(symbolPrefix.count))
        let parts = body.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)
        let name = String(parts.first ?? "")
        guard !name.isEmpty else { return .none }
        let tint = parts.count > 1 && !parts[1].isEmpty ? String(parts[1]) : nil
        return .symbol(name: name, tint: tint)
    }

    /// 存進 JSON 的字串。
    var encoded: String {
        switch self {
        case .none:
            return ""
        case .emoji(let value):
            return value
        case .symbol(let name, let tint):
            guard let tint, !tint.isEmpty else { return Self.symbolPrefix + name }
            return Self.symbolPrefix + name + "#" + tint
        }
    }

    var isEmpty: Bool {
        if case .none = self { return true }
        return false
    }
}

/// 系統圖示的配色。前面是內建色，使用者也可以自己挑一個。
enum IconPalette {

    /// 內建色的 token，順序就是選色盤的排列。
    static let presets = ["red", "orange", "yellow", "green", "mint", "teal",
                          "blue", "indigo", "purple", "pink", "brown", "gray"]

    /// token 轉顏色。認不得就回 nil，畫的時候會退回文字色。
    static func color(for token: String?) -> Color? {
        guard let token, !token.isEmpty else { return nil }
        switch token {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "mint": return .mint
        case "teal": return .teal
        case "blue": return .blue
        case "indigo": return .indigo
        case "purple": return .purple
        case "pink": return .pink
        case "brown": return .brown
        case "gray": return .gray
        default: return color(fromHex: token)
        }
    }

    /// 自訂色存成六碼十六進位。
    static func token(for color: Color) -> String {
        let components = UIColor(color).cgColor.components ?? []
        let red: CGFloat, green: CGFloat, blue: CGFloat
        switch components.count {
        case 2:
            red = components[0]; green = components[0]; blue = components[0]
        case 4...:
            red = components[0]; green = components[1]; blue = components[2]
        default:
            return "gray"
        }
        return String(format: "%02X%02X%02X",
                      Int((red * 255).rounded()),
                      Int((green * 255).rounded()),
                      Int((blue * 255).rounded()))
    }

    static func isPreset(_ token: String?) -> Bool {
        guard let token else { return false }
        return presets.contains(token)
    }

    private static func color(fromHex hex: String) -> Color? {
        let cleaned = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard cleaned.count == 6, let value = Int(cleaned, radix: 16) else { return nil }
        return Color(red: Double((value >> 16) & 0xFF) / 255,
                     green: Double((value >> 8) & 0xFF) / 255,
                     blue: Double(value & 0xFF) / 255)
    }
}

/// 畫一個圖示。表情符號用文字畫，系統圖示用 SF Symbol 畫。
struct IconLabel: View {
    let raw: String
    var size: CGFloat = 20
    /// 沒有圖示時要不要畫一個淡淡的預設圖示。
    var placeholder: String? = nil
    /// 強制指定圖示顏色（例如選中狀態跟隨文字變成白色）。
    var tintOverride: Color? = nil

    var body: some View {
        content
            // 表情符號與系統圖示的字形大小和留白都不同，統一放進固定大小的方框並置中，
            // 不同圖示排在一起時中心才會對齊。
            .frame(width: size * 1.35, height: size * 1.35, alignment: .center)
    }

    @ViewBuilder
    private var content: some View {
        switch AppIcon.decode(raw) {
        case .emoji(let value):
            Text(value)
                .font(.system(size: size))
        case .symbol(let name, let tint):
            let color = tintOverride ?? IconPalette.color(for: tint)
            if let color {
                Image(systemName: name)
                    .font(.system(size: size * 0.86))
                    .foregroundStyle(color)
            } else {
                Image(systemName: name)
                    .font(.system(size: size * 0.86))
            }
        case .none:
            if let placeholder {
                Image(systemName: placeholder)
                    .font(.system(size: size * 0.7))
                    .foregroundStyle(tintOverride ?? Color.secondary)
            }
        }
    }
}

/// 選擇器用的資料。表情符號的名稱由系統的 Unicode 名稱推出來，不用自己維護字典。
enum IconCatalog {

    struct Group: Identifiable {
        let id: String
        let title: String
        let items: [String]
    }

    // MARK: - 表情符號

    /// 系統內建的全部表情符號（Unicode emoji-test，目前系統畫得出來的）。
    /// 膚色與髮色變體不在這裡，點人物或手勢時由 `variants(of:)` 展開。
    static let emojiGroups: [Group] = {
        var order: [String] = []
        var buckets: [String: [String]] = [:]
        var names: [String: String] = [:]
        let supported = EmojiSupport.maxVersion

        for line in EmojiData.raw.split(separator: "\n") {
            let parts = line.split(separator: "|", maxSplits: 4, omittingEmptySubsequences: false)
            guard parts.count >= 4, let version = Double(parts[2]) else { continue }
            let emoji = String(parts[1])
            // 太新的表情，這個系統版本畫不出來（會變成方框），不列出。
            guard version <= supported || EmojiSupport.canRender(emoji) else { continue }
            let group = String(parts[0])
            if buckets[group] == nil { order.append(group) }
            buckets[group, default: []].append(emoji)
            // 英文名稱加中文關鍵字（CLDR），搜尋兩種語言都找得到。
            names[emoji] = (String(parts[3]) + " " + (parts.count > 4 ? String(parts[4]) : "")).lowercased()
        }
        emojiNameIndex = names
        return order.map { Group(id: "emoji." + $0, title: emojiGroupTitle($0), items: buckets[$0] ?? []) }
    }()

    fileprivate nonisolated(unsafe) static var emojiNameIndex: [String: String] = [:]

    private static func emojiGroupTitle(_ id: String) -> String {
        switch id {
        case "Smileys & Emotion": return String(localized: "Smileys & Emotion")
        case "People & Body": return String(localized: "People & Body")
        case "Animals & Nature": return String(localized: "Animals & Nature")
        case "Food & Drink": return String(localized: "Food & Drink")
        case "Travel & Places": return String(localized: "Travel & Places")
        case "Activities": return String(localized: "Activities")
        case "Objects": return String(localized: "Objects")
        case "Symbols": return String(localized: "Symbols")
        case "Flags": return String(localized: "Flags")
        default: return id
        }
    }

    // MARK: - 變體（膚色與髮色）

    private static let skinTones: [UInt32] = [0x1F3FB, 0x1F3FC, 0x1F3FD, 0x1F3FE, 0x1F3FF]
    /// 紅髮、捲髮、白髮、光頭。Unicode 只有成人的 🧑 👨 👩 支援。
    private static let hairComponents: [UInt32] = [0x1F9B0, 0x1F9B1, 0x1F9B3, 0x1F9B2]
    private static let hairCapableBases: Set<UInt32> = [0x1F9D1, 0x1F468, 0x1F469]

    /// 這個表情符號的所有變體，一列一列排好。沒有變體就回空陣列。
    ///
    /// 第一列是原本的加上五種膚色。成人人物後面再接四種髮色，每種也都有六個膚色。
    static func variants(of emoji: String) -> [[String]] {
        let scalars = Array(emoji.unicodeScalars).filter { $0.value != 0xFE0F }
        // 只處理單一字元的人物與手勢。多人組合、動物、食物這類沒有變體。
        guard scalars.count == 1, let base = scalars.first,
              base.properties.isEmojiModifierBase else { return [] }

        func make(tone: UInt32?, hair: UInt32?) -> String {
            var view = String.UnicodeScalarView()
            view.append(base)
            if let tone, let scalar = Unicode.Scalar(tone) { view.append(scalar) }
            if let hair, let zwj = Unicode.Scalar(0x200D), let scalar = Unicode.Scalar(hair) {
                view.append(zwj)
                view.append(scalar)
            }
            return String(view)
        }

        var rows: [[String]] = []
        rows.append([emoji] + skinTones.map { make(tone: $0, hair: nil) })

        if hairCapableBases.contains(base.value) {
            for hair in hairComponents {
                rows.append([make(tone: nil, hair: hair)] + skinTones.map { make(tone: $0, hair: hair) })
            }
        }
        return rows
    }

    /// 全部表情符號，給隨機挑選用。
    static let allEmoji: [String] = emojiGroups.flatMap(\.items)

    /// 表情符號的英文名稱，用來搜尋。系統轉出來的是 `\N{GRINNING FACE}`，去掉外框就好。
    static func searchName(forEmoji emoji: String) -> String {
        _ = emojiGroups
        if let known = emojiNameIndex[emoji] { return known }
        if let cached = emojiNameCache.value(for: emoji) { return cached }
        let transformed = emoji.applyingTransform(.toUnicodeName, reverse: false) ?? emoji
        let cleaned = transformed
            .replacingOccurrences(of: "\\N{", with: " ")
            .replacingOccurrences(of: "}", with: " ")
            .lowercased()
        emojiNameCache.store(cleaned, for: emoji)
        return cleaned
    }

    private static let emojiNameCache = IconNameCache()

    // MARK: - 圖標（SF Symbols）

    /// 系統 SF Symbols 的全部圖標，依分類排。目前系統沒有的會濾掉。
    static let symbolGroups: [Group] = {
        var order: [String] = []
        var buckets: [String: [String]] = [:]
        for line in SymbolData.raw.split(separator: "\n") {
            let parts = line.split(separator: "|", maxSplits: 2, omittingEmptySubsequences: false)
            guard parts.count >= 2 else { continue }
            let name = String(parts[1])
            guard UIImage(systemName: name) != nil else { continue }
            if parts.count > 2, !parts[2].isEmpty { symbolZhIndex[name] = String(parts[2]) }
            let category = String(parts[0])
            if buckets[category] == nil { order.append(category) }
            buckets[category, default: []].append(name)
        }
        // 「其他」（沒有分類的）放最後。
        let sorted = order.filter { $0 != "other" } + order.filter { $0 == "other" }
        return sorted.map { Group(id: "symbol." + $0, title: symbolGroupTitle($0), items: buckets[$0] ?? []) }
    }()

    /// 圖標的中文關鍵字（由英文名稱的字對照出來），給中文搜尋用。
    nonisolated(unsafe) static var symbolZhIndex: [String: String] = [:]

    /// 圖標的搜尋文字：英文名稱加中文關鍵字。
    static func searchText(forSymbol name: String) -> String {
        _ = symbolGroups
        return name.lowercased() + " " + (symbolZhIndex[name] ?? "")
    }

    private static func symbolGroupTitle(_ id: String) -> String {
        switch id {
        case "communication": return String(localized: "Communication")
        case "weather": return String(localized: "Weather")
        case "maps": return String(localized: "Maps")
        case "objectsandtools": return String(localized: "Objects & Tools")
        case "devices": return String(localized: "Devices")
        case "cameraandphotos": return String(localized: "Camera & Photos")
        case "gaming": return String(localized: "Gaming")
        case "connectivity": return String(localized: "Connectivity")
        case "transportation": return String(localized: "Transportation")
        case "automotive": return String(localized: "Automotive")
        case "accessibility": return String(localized: "Accessibility")
        case "privacyandsecurity": return String(localized: "Privacy & Security")
        case "human": return String(localized: "Human")
        case "home": return String(localized: "Home")
        case "fitness": return String(localized: "Fitness")
        case "nature": return String(localized: "Nature")
        case "editing": return String(localized: "Editing")
        case "textformatting": return String(localized: "Text Formatting")
        case "media": return String(localized: "Media")
        case "keyboard": return String(localized: "Keyboard")
        case "commerce": return String(localized: "Commerce")
        case "time": return String(localized: "Time")
        case "health": return String(localized: "Health")
        case "shapes": return String(localized: "Shapes")
        case "arrows": return String(localized: "Arrows")
        case "indices": return String(localized: "Indices")
        case "math": return String(localized: "Math")
        default: return String(localized: "Other")
        }
    }

    static let allSymbols: [String] = symbolGroups.flatMap(\.items)
}

/// 表情符號名稱的小快取。轉換不便宜，捲動時會一直問同一批。
private final class IconNameCache: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String: String] = [:]

    func value(for key: String) -> String? {
        lock.lock(); defer { lock.unlock() }
        return storage[key]
    }

    func store(_ value: String, for key: String) {
        lock.lock(); defer { lock.unlock() }
        storage[key] = value
    }
}


/// 目前系統畫得出哪些表情符號。
enum EmojiSupport {
    /// 這個系統版本確定支援的最高 Emoji 版本。更新的表情再逐個檢查字型有沒有對應字形。
    static var maxVersion: Double {
        if #available(iOS 18.4, *) { return 16.0 }
        if #available(iOS 17.4, *) { return 15.1 }
        return 15.0
    }

    private static let font = CTFontCreateWithName("AppleColorEmoji" as CFString, 20, nil)

    /// 每個字元（不含連接符與變體選擇符）字型裡都有字形才算畫得出來。
    static func canRender(_ emoji: String) -> Bool {
        for scalar in emoji.unicodeScalars where scalar.value != 0x200D && scalar.value != 0xFE0F {
            var utf16 = Array(String(scalar).utf16)
            var glyphs = [CGGlyph](repeating: 0, count: utf16.count)
            guard CTFontGetGlyphsForCharacters(font, &utf16, &glyphs, utf16.count),
                  glyphs.allSatisfy({ $0 != 0 }) else { return false }
        }
        return true
    }
}
