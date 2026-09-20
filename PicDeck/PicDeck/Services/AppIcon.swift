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

    var body: some View {
        switch AppIcon.decode(raw) {
        case .emoji(let value):
            Text(value)
                .font(.system(size: size))
        case .symbol(let name, let tint):
            Image(systemName: name)
                .font(.system(size: size * 0.86))
                .foregroundStyle(IconPalette.color(for: tint) ?? Color.primary)
        case .none:
            if let placeholder {
                Image(systemName: placeholder)
                    .font(.system(size: size * 0.7))
                    .foregroundStyle(.secondary)
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

    static let emojiGroups: [Group] = [
        Group(id: "smileys", title: String(localized: "Smileys & people"), items: [
            "😀", "😃", "😄", "😁", "😆", "😅", "🤣", "😂", "🙂", "🙃",
            "😉", "😊", "😇", "🥰", "😍", "🤩", "😘", "😗", "😚", "😙",
            "😋", "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔",
            "🤐", "🤨", "😐", "😑", "😶", "😏", "😒", "🙄", "😬", "😮‍💨",
            "😌", "😔", "😪", "🤤", "😴", "😷", "🤒", "🤕", "🤢", "🤮",
            "🥵", "🥶", "😵", "🤯", "🤠", "🥳", "😎", "🤓", "🧐", "😕",
            "😟", "🙁", "😮", "😯", "😲", "😳", "🥺", "😦", "😧", "😨",
            "😰", "😥", "😢", "😭", "😱", "😖", "😣", "😞", "😓", "😩",
            "😫", "🥱", "😤", "😡", "😠", "🤬", "😈", "💀", "👻", "👽",
            "👋", "👌", "✌️", "🤞", "🤟", "👍", "👎", "👏", "🙌", "🙏",
            "💪", "🧒", "👶", "👦", "👧", "👨", "👩", "🧑", "👴", "👵",
            "👨‍👩‍👧", "👨‍👩‍👦", "🐣", "❤️", "🧡", "💛", "💚", "💙", "💜", "🖤",
            "🤍", "💔", "💕", "💖", "💯"
        ]),
        Group(id: "nature", title: String(localized: "Animals & nature"), items: [
            "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯",
            "🦁", "🐮", "🐷", "🐸", "🐵", "🐔", "🐧", "🐦", "🦆", "🦉",
            "🦄", "🐝", "🦋", "🐌", "🐞", "🐢", "🐍", "🐙", "🦀", "🐬",
            "🐳", "🐟", "🐊", "🐘", "🦒", "🦓", "🐄", "🐑", "🐎", "🐕",
            "🐈", "🌵", "🌲", "🌳", "🌴", "🌱", "🌿", "☘️", "🍀", "🍁",
            "🍂", "🍃", "🌷", "🌹", "🌺", "🌸", "🌼", "🌻", "🌞", "🌝",
            "🌙", "⭐️", "🌟", "✨", "⚡️", "🔥", "🌈", "☀️", "⛅️", "☁️",
            "🌧", "⛈", "❄️", "☃️", "💧", "🌊"
        ]),
        Group(id: "food", title: String(localized: "Food & drink"), items: [
            "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍒",
            "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🥑", "🥦", "🥕", "🌽",
            "🥔", "🍠", "🥐", "🍞", "🥖", "🧀", "🥚", "🍳", "🥞", "🧇",
            "🥓", "🍔", "🍟", "🍕", "🌭", "🥪", "🌮", "🌯", "🥗", "🍝",
            "🍜", "🍲", "🍛", "🍣", "🍱", "🥟", "🍤", "🍚", "🍙", "🍥",
            "🥠", "🍦", "🍰", "🎂", "🧁", "🥧", "🍫", "🍬", "🍭", "🍮",
            "🍯", "🍼", "☕️", "🍵", "🧋", "🥤", "🍺", "🍷", "🥂", "🍾"
        ]),
        Group(id: "activity", title: String(localized: "Activity"), items: [
            "⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐", "🏉", "🎱", "🏓", "🏸",
            "🥅", "⛳️", "🏹", "🎣", "🥊", "🥋", "⛸", "🎿", "⛷", "🏂",
            "🏋️", "🤸", "🤼", "🤽", "🚴", "🚵", "🏆", "🥇", "🥈", "🥉",
            "🎖", "🏅", "🎪", "🎭", "🎨", "🎬", "🎤", "🎧", "🎼", "🎹",
            "🥁", "🎷", "🎺", "🎸", "🪕", "🎻", "🎲", "🎯", "🎳", "🎮",
            "🧩", "🪁", "🎈", "🎉", "🎊", "🎁", "🎀", "🎄", "🎃", "🧧"
        ]),
        Group(id: "travel", title: String(localized: "Travel & places"), items: [
            "🚗", "🚕", "🚙", "🚌", "🚎", "🏎", "🚓", "🚑", "🚒", "🚐",
            "🛻", "🚚", "🚛", "🚜", "🛵", "🏍", "🚲", "🛴", "🚂", "🚆",
            "🚊", "🚉", "✈️", "🛫", "🛬", "🚀", "🛸", "🚁", "⛵️", "🚤",
            "🛳", "⛴", "🗺", "🧭", "🏔", "⛰", "🌋", "🏕", "🏖", "🏝",
            "🏜", "🏟", "🏛", "🏗", "🏘", "🏠", "🏡", "🏢", "🏥", "🏦",
            "🏨", "🏩", "🏪", "🏫", "🏬", "🏭", "⛩", "🗼", "🗽", "🎡",
            "🎢", "🎠", "⛲️", "🌉", "🌃", "🌆", "🌇", "🌌"
        ]),
        Group(id: "objects", title: String(localized: "Objects"), items: [
            "⌚️", "📱", "💻", "⌨️", "🖥", "🖨", "🖱", "💽", "💾", "📷",
            "📸", "📹", "🎥", "📺", "📻", "🎙", "⏰", "⏱", "⌛️", "🔋",
            "🔌", "💡", "🔦", "🕯", "🧯", "🛢", "💸", "💰", "💳", "🧾",
            "⚖️", "🔧", "🔨", "⚒", "🛠", "⛏", "🔩", "⚙️", "🧰", "🧲",
            "🔬", "🔭", "📡", "💊", "🩹", "🩺", "🚪", "🛏", "🛋", "🚿",
            "🛁", "🧴", "🧷", "🧹", "🧺", "🧻", "🔑", "🗝", "🔒", "🔓",
            "📦", "📫", "📮", "📝", "✏️", "🖊", "🖍", "📒", "📓", "📔",
            "📕", "📗", "📘", "📙", "📚", "📖", "🔖", "🏷️", "📅", "📆",
            "📇", "📈", "📉", "📊", "📋", "📌", "📍", "📎", "🗂", "🗃",
            "🗄", "🗑"
        ]),
        Group(id: "symbols", title: String(localized: "Symbols"), items: [
            "✅", "❌", "⭕️", "❗️", "❓", "💤", "💢", "💬", "🗯", "💭",
            "♻️", "🔱", "⚜️", "🔰", "✳️", "❇️", "🆗", "🆕", "🆙", "🔝",
            "🔜", "🔙", "🔛", "🔚", "🔄", "🔃", "➕", "➖", "➗", "✖️",
            "💲", "〽️", "⚠️", "🚸", "🔞", "📵", "🚭", "❤️‍🔥", "🩷", "🤎",
            "🔴", "🟠", "🟡", "🟢", "🔵", "🟣", "🟤", "⚫️", "⚪️", "🟥",
            "🟧", "🟨", "🟩", "🟦", "🟪", "⬛️", "⬜️", "🔶", "🔷", "🔸",
            "🔹", "🔺", "🔻", "💠", "🔘", "🔳", "🔲"
        ])
    ]

    /// 全部表情符號，給隨機挑選用。
    static let allEmoji: [String] = emojiGroups.flatMap(\.items)

    /// 表情符號的英文名稱，用來搜尋。系統轉出來的是 `\N{GRINNING FACE}`，去掉外框就好。
    static func searchName(forEmoji emoji: String) -> String {
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

    // MARK: - 系統圖示

    static let symbolGroups: [Group] = [
        Group(id: "people", title: String(localized: "People"), items: [
            "person", "person.fill", "person.2.fill", "person.3.fill", "figure.walk",
            "figure.run", "figure.and.child.holdinghands", "figure.2.and.child.holdinghands",
            "hand.wave.fill", "hand.thumbsup.fill", "hand.raised.fill", "face.smiling",
            "brain.head.profile", "eye.fill", "ear.fill", "mouth.fill"
        ]),
        Group(id: "nature", title: String(localized: "Nature"), items: [
            "leaf.fill", "tree.fill", "camera.macro", "pawprint.fill", "bird.fill",
            "fish.fill", "ant.fill", "ladybug.fill", "tortoise.fill", "hare.fill",
            "sun.max.fill", "moon.fill", "moon.stars.fill", "sparkles", "cloud.fill",
            "cloud.rain.fill", "cloud.bolt.fill", "snowflake", "wind", "flame.fill",
            "drop.fill", "water.waves", "mountain.2.fill", "globe.asia.australia.fill"
        ]),
        Group(id: "objects", title: String(localized: "Objects"), items: [
            "house.fill", "building.2.fill", "car.fill", "bus.fill", "tram.fill",
            "airplane", "bicycle", "sailboat.fill", "ferry.fill", "fuelpump.fill",
            "bed.double.fill", "sofa.fill", "lamp.desk.fill", "cup.and.saucer.fill",
            "fork.knife", "birthday.cake.fill", "gift.fill", "bag.fill", "cart.fill",
            "creditcard.fill", "banknote.fill", "briefcase.fill", "suitcase.fill",
            "backpack.fill", "book.fill", "books.vertical.fill", "graduationcap.fill",
            "pencil", "paintbrush.fill", "hammer.fill", "wrench.and.screwdriver.fill",
            "paperclip", "scissors", "key.fill", "lock.fill", "trash.fill"
        ]),
        Group(id: "media", title: String(localized: "Media"), items: [
            "camera.fill", "photo.fill", "photo.stack.fill", "video.fill", "film.fill",
            "music.note", "headphones", "mic.fill", "speaker.wave.2.fill", "tv.fill",
            "gamecontroller.fill", "display", "iphone", "ipad", "applewatch",
            "desktopcomputer", "printer.fill", "externaldrive.fill"
        ]),
        Group(id: "symbols", title: String(localized: "Symbols"), items: [
            "heart.fill", "star.fill", "bolt.fill", "crown.fill", "flag.fill",
            "bookmark.fill", "tag.fill", "bell.fill", "pin.fill", "mappin",
            "map.fill", "location.fill", "calendar", "clock.fill", "alarm.fill",
            "hourglass", "checkmark.circle.fill", "xmark.circle.fill",
            "exclamationmark.triangle.fill", "questionmark.circle.fill",
            "info.circle.fill", "plus.circle.fill", "minus.circle.fill",
            "magnifyingglass", "gearshape.fill", "wand.and.stars", "target",
            "chart.bar.fill", "list.bullet", "square.grid.2x2.fill", "folder.fill",
            "doc.fill", "envelope.fill", "phone.fill", "message.fill", "link"
        ])
    ]

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
