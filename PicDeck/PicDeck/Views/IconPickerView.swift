import SwiftUI

/// 選圖示。分成表情符號與圖示兩頁，上面有搜尋、隨機與移除，
/// 圖示那頁可以挑顏色。標籤符號與日記心情都用這一個。
struct IconPickerView: View {
    /// 存起來的字串，格式見 AppIcon。
    @Binding var raw: String
    /// 要不要提供「移除」。
    var allowsRemove: Bool = true
    /// 按移除之後寫回的值。標籤會換回預設符號，日記心情則是清空。
    var removedValue: String = ""

    @Environment(\.dismiss) private var dismiss

    /// 最近用過的圖示，逗號分隔。表情符號本身不含逗號，SF 名稱也不含。
    @AppStorage("icon.recents") private var recentsRaw = ""

    @State private var tab: Tab = .emoji
    @State private var query = ""
    /// 正在挑變體的那個表情符號。
    @State private var variantBase: String?
    @State private var tint: String?
    @State private var showColorPalette = false
    @State private var customColor = Color.orange

    private enum Tab: String, CaseIterable, Identifiable {
        case emoji, symbol
        var id: String { rawValue }
        var title: String {
            switch self {
            case .emoji: return "表情符號"
            case .symbol: return "符號圖示"
            }
        }
    }

    private let columns = [GridItem(.adaptive(minimum: 44), spacing: 6)]
    private let maxRecents = 16

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Picker("", selection: $tab) {
                    ForEach(Tab.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("icon.tab")

                controls

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 14, pinnedViews: [.sectionHeaders]) {
                            if query.isEmpty, !recents.isEmpty {
                                section(title: "最近使用", items: recents, isRaw: true)
                                    .id("recent")
                            }
                            ForEach(visibleGroups) { group in
                                section(title: group.title, items: group.items, isRaw: false)
                                    .id(group.id)
                            }
                            if isSearching && visibleGroups.isEmpty {
                                Text("查無符合圖示")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 20)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    // 底下一排分類快速鍵，點一下跳過去，不用慢慢滑——跟系統表情符號鍵盤那排一樣。
                    // 搜尋中看到的是篩選過的結果，跳分類沒有意義，這時候不顯示。
                    if !isSearching {
                        quickJumpBar(proxy: proxy)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .navigationTitle("選擇圖示")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .accessibilityIdentifier("icon.cancel")
                }
                if allowsRemove {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("移除圖示", role: .destructive) {
                            raw = removedValue
                            dismiss()
                        }
                        .accessibilityIdentifier("icon.remove")
                    }
                }
            }
            .onAppear(perform: syncTabWithCurrentIcon)
        }
    }

    // MARK: - 上方控制列

    private var controls: some View {
        HStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                TextField("搜尋圖示…", text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("icon.search")
                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("清除"))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 9))

            Button(action: pickRandom) {
                Image(systemName: "shuffle")
                    .frame(width: 44, height: 44)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 9))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("隨機"))
            .accessibilityIdentifier("icon.shuffle")

            if tab == .symbol {
                Button {
                    showColorPalette.toggle()
                } label: {
                    Circle()
                        .fill(IconPalette.color(for: tint) ?? Color(.systemGray3))
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.primary.opacity(0.15)))
                        .frame(width: 44, height: 44)
                        .background(Color(.secondarySystemBackground),
                                    in: RoundedRectangle(cornerRadius: 9))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("顏色"))
                .accessibilityIdentifier("icon.color")
                .popover(isPresented: $showColorPalette) {
                    colorPalette
                        .presentationCompactAdaptation(.popover)
                }
            }
        }
    }

    // MARK: - 底部分類快速鍵

    /// 一排小圖示，一個分類一顆，點下去滑到那一段。用分類裡的第一個項目當代表圖示，
    /// 不用另外對每個分類手動配一個 SF Symbol，分類增減也不用跟著改。
    private func quickJumpBar(proxy: ScrollViewProxy) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                if query.isEmpty, !recents.isEmpty {
                    quickJumpButton(targetID: "recent", proxy: proxy) {
                        Image(systemName: "clock")
                            .font(.system(size: 17))
                    }
                }
                ForEach(groups) { group in
                    if let first = group.items.first {
                        quickJumpButton(targetID: group.id, proxy: proxy) {
                            IconLabel(raw: tab == .emoji ? first : AppIcon.symbol(name: first, tint: nil).encoded,
                                      size: 17)
                        }
                        .accessibilityLabel(Text(group.title))
                    }
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 4)
        }
        .frame(height: 48)
    }

    private func quickJumpButton<Content: View>(targetID: String, proxy: ScrollViewProxy,
                                                 @ViewBuilder content: () -> Content) -> some View {
        Button {
            proxy.scrollTo(targetID, anchor: .top)
        } label: {
            content()
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("icon.quickJump")
    }

    /// 配色盤。直接顯示顏色，最後一格可以自己挑。
    private var colorPalette: some View {
        let columns = Array(repeating: GridItem(.fixed(44), spacing: 8), count: 4)

        return VStack(spacing: 12) {
            LazyVGrid(columns: columns, spacing: 10) {
                swatch(token: nil, color: Color(.systemGray3))
                ForEach(IconPalette.presets, id: \.self) { token in
                    swatch(token: token, color: IconPalette.color(for: token) ?? .gray)
                }
            }

            Divider()

            HStack(spacing: 10) {
                ColorPicker(selection: $customColor, supportsOpacity: false) {
                    Text("自訂顏色")
                        .font(.footnote)
                }
                .labelsHidden()
                .accessibilityIdentifier("icon.color.custom")

                Button {
                    tint = IconPalette.token(for: customColor)
                    showColorPalette = false
                } label: {
                    Text("使用此顏色")
                        .font(.footnote.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("icon.color.useCustom")
            }
        }
        .padding(14)
        .frame(width: 250)
    }

    private func swatch(token: String?, color: Color) -> some View {
        let isSelected = token == tint
        return Button {
            tint = token
            showColorPalette = false
        } label: {
            Circle()
                .fill(color)
                .frame(width: 30, height: 30)
                .overlay {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
                .overlay(Circle().stroke(Color.primary.opacity(0.12)))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(token ?? "default"))
        .accessibilityIdentifier("icon.swatch")
    }

    // MARK: - 格狀

    private func section(title: String, items: [String], isRaw: Bool) -> some View {
        Section {
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(items, id: \.self) { item in
                    let value = isRaw ? item : encoded(for: item)
                    Button {
                        if tab == .emoji, !isRaw, !IconCatalog.variants(of: item).isEmpty {
                            variantBase = item
                        } else {
                            choose(value)
                        }
                    } label: {
                        IconLabel(raw: value, size: 24)
                            .frame(width: 44, height: 44)
                            .background(raw == value ? Color.accentColor.opacity(0.18) : Color.clear,
                                        in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(item)
                    .accessibilityIdentifier("icon.item")
                    .popover(isPresented: variantBinding(for: item)) {
                        variantPicker(for: item)
                            .presentationCompactAdaptation(.popover)
                    }
                }
            }
        } header: {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
                .background(Color(.systemBackground))
        }
    }

    // MARK: - 資料

    /// 最近使用只列目前這一頁的類型，表情符號那頁就不要混進系統圖示。
    private var recents: [String] {
        recentsRaw
            .split(separator: ",")
            .map(String.init)
            .filter { value in
                guard !value.isEmpty else { return false }
                switch AppIcon.decode(value) {
                case .emoji: return tab == .emoji
                case .symbol: return tab == .symbol
                case .none: return false
                }
            }
    }

    private var groups: [IconCatalog.Group] {
        tab == .emoji ? IconCatalog.emojiGroups : IconCatalog.symbolGroups
    }

    private var visibleGroups: [IconCatalog.Group] {
        let needle = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !needle.isEmpty else { return groups }

        return groups.compactMap { group in
            let hits = group.items.filter { matches($0, needle: needle) }
            guard !hits.isEmpty else { return nil }
            return IconCatalog.Group(id: group.id, title: group.title, items: hits)
        }
    }

    private var isSearching: Bool {
        !query.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func matches(_ item: String, needle: String) -> Bool {
        if tab == .symbol {
            return IconCatalog.searchText(forSymbol: item).contains(needle)
        }
        // 表情符號沒有中文名稱，用系統的 Unicode 英文名稱來找。
        return IconCatalog.searchName(forEmoji: item).contains(needle)
    }

    /// 目錄裡放的是原始項目，圖示要再套上目前選的顏色。
    private func encoded(for item: String) -> String {
        tab == .emoji
            ? AppIcon.emoji(item).encoded
            : AppIcon.symbol(name: item, tint: tint).encoded
    }

    // MARK: - 變體

    private func variantBinding(for item: String) -> Binding<Bool> {
        Binding(get: { variantBase == item },
                set: { if !$0, variantBase == item { variantBase = nil } })
    }

    /// 點了有變體的表情符號之後跳出來的選單：原本的、膚色，成人另有髮色。
    private func variantPicker(for item: String) -> some View {
        let rows = IconCatalog.variants(of: item)

        // 不用 LazyVGrid：彈出選單量不出它的高度，只會畫第一排。項目最多三十個，直接全畫。
        return VStack(spacing: 6) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 6) {
                    ForEach(row, id: \.self) { variant in
                        Button {
                            variantBase = nil
                            choose(variant)
                        } label: {
                            Text(variant)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(variant)
                        .accessibilityIdentifier("icon.variant")
                    }
                }
            }
        }
        .padding(12)
        .frame(width: 320)
    }

    // MARK: - 動作

    private func choose(_ value: String) {
        raw = value
        remember(value)
        dismiss()
    }

    private func pickRandom() {
        let pool = tab == .emoji ? IconCatalog.allEmoji : IconCatalog.allSymbols
        guard let item = pool.randomElement() else { return }
        raw = encoded(for: item)
        remember(raw)
        dismiss()
    }

    private func remember(_ value: String) {
        guard !value.isEmpty else { return }
        var list = recents.filter { $0 != value }
        list.insert(value, at: 0)
        recentsRaw = list.prefix(maxRecents).joined(separator: ",")
    }

    /// 打開時停在目前圖示所屬的那一頁，順便帶出它的顏色。
    private func syncTabWithCurrentIcon() {
        if case .symbol(_, let current) = AppIcon.decode(raw) {
            tab = .symbol
            tint = current
            if let current, !IconPalette.isPreset(current),
               let color = IconPalette.color(for: current) {
                customColor = color
            }
        }
    }
}

/// 一顆可以點開選擇器的圖示按鈕。
struct IconPickerButton: View {
    @Binding var raw: String
    var size: CGFloat = 34
    var allowsRemove: Bool = true
    var removedValue: String = ""
    var identifier: String = "icon.button"

    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            IconLabel(raw: raw, size: size * 0.6, placeholder: "face.smiling")
                .frame(width: size + 10, height: size)
                .frame(minWidth: 44, minHeight: 44)
                .background(Color(.secondarySystemBackground),
                            in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Choose icon"))
        .accessibilityIdentifier(identifier)
        .sheet(isPresented: $isPresented) {
            IconPickerView(raw: $raw, allowsRemove: allowsRemove, removedValue: removedValue)
        }
    }
}
