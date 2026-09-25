import SwiftUI
import Photos

/// 寫日記：選心情、分類、寫文字，並挑選要附上的照片。
/// 同一天可以有好幾篇，新增永遠是新的一篇；只有從列表點開既有的那篇才是編輯。
struct JournalEditorView: View {
    /// 新增一篇（一定是新的，就算當天已經有別篇了）；或編輯指定的那一篇。
    enum Target {
        case new(year: Int, month: Int, day: Int, preselectedIDs: [String] = [], allowsDateChange: Bool = false)
        case edit(JournalEntry)
    }

    let target: Target

    init(target: Target) {
        self.target = target
        switch target {
        case .new(let year, let month, let day, _, _):
            var parts = DateComponents()
            parts.year = year; parts.month = month; parts.day = day
            _date = State(initialValue: PhotoGrouping.calendar.date(from: parts) ?? Date())
        case .edit(let entry):
            let comps = JournalStore.components(fromKey: entry.dateKey)
            var parts = DateComponents()
            parts.year = comps?.year; parts.month = comps?.month; parts.day = comps?.day
            _date = State(initialValue: PhotoGrouping.calendar.date(from: parts) ?? Date())
            _mood = State(initialValue: entry.mood)
            _text = State(initialValue: entry.text)
            _selectedIDs = State(initialValue: entry.photoIDs)
            _categoryID = State(initialValue: entry.categoryID)
        }
    }

    /// 新增時，方便的建構子。
    init(year: Int, month: Int, day: Int, preselectedIDs: [String] = [], allowsDateChange: Bool = false) {
        self.init(target: .new(year: year, month: month, day: day,
                               preselectedIDs: preselectedIDs, allowsDateChange: allowsDateChange))
    }

    /// 編輯既有那篇的建構子。
    init(entry: JournalEntry) {
        self.init(target: .edit(entry))
    }

    @EnvironmentObject private var journalStore: JournalStore
    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var mood = ""
    @State private var text = ""
    @State private var categoryID: JournalCategory.ID?
    @State private var selectedIDs: [String] = []
    @State private var dayAssets: [PHAsset] = []
    /// 已選、但不是當天拍的照片（從「加入照片」挑的）。
    @State private var otherAssets: [PHAsset] = []
    @State private var editorSheet: EditorSheet?
    @State private var showLimitAlert = false

    private enum EditorSheet: Identifiable {
        case picker, paywall, categories
        var id: Int { hashValue }
    }
    @State private var isLoading = true

    private let photoColumns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 4)

    private var existingEntry: JournalEntry? {
        if case .edit(let entry) = target { return entry }
        return nil
    }
    /// 新增時可以改日期；編輯既有的那篇，日期就固定在它原本那天。
    private var allowsDateChange: Bool {
        if case .new(_, _, _, _, let allows) = target { return allows }
        return false
    }
    private var preselectedIDs: [String] {
        if case .new(_, _, _, let ids, _) = target { return ids }
        return []
    }

    private var parts: DateComponents {
        PhotoGrouping.calendar.dateComponents([.year, .month, .day], from: date)
    }
    private var year: Int { parts.year ?? 1970 }
    private var month: Int { parts.month ?? 1 }
    private var day: Int { parts.day ?? 1 }

    private var dateKey: String { JournalStore.key(year: year, month: month, day: day) }
    private var dateTitle: String { DateTitle.day(year: year, month: month, day: day) }

    var body: some View {
        NavigationStack {
            Form {
                if allowsDateChange {
                    Section {
                        DatePicker(String(localized: "Date"), selection: $date,
                                   in: ...Date(), displayedComponents: .date)
                            .accessibilityIdentifier("journal.date")
                    }
                }

                Section {
                    HStack(spacing: 12) {
                        IconPickerButton(raw: $mood,
                                         size: 44,
                                         removedValue: "",
                                         identifier: "journal.mood")
                        Text(mood.isEmpty ? "點擊選擇心情" : "點擊更換心情")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.vertical, 2)
                } header: {
                    Text("心情")
                }

                Section {
                    categoryChips
                } header: {
                    Text("分類")
                }

                Section("日記內文") {
                    TextField("今天發生了什麼事？",
                              text: $text, axis: .vertical)
                        .lineLimit(4...10)
                        .accessibilityIdentifier("journal.text")
                }

                Section {
                    if isLoading {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        // 當天的照片排前面，接著是從別天挑來的。
                        if !gridAssets.isEmpty {
                            LazyVGrid(columns: photoColumns, spacing: 4) {
                                ForEach(gridAssets, id: \.localIdentifier) { asset in
                                    selectableThumbnail(asset)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        Button {
                            editorSheet = .picker
                        } label: {
                            Label(dayAssets.isEmpty ? "加入照片" : "加入更多照片",
                                  systemImage: "photo.badge.plus")
                                .frame(maxWidth: .infinity)
                        }
                        .accessibilityIdentifier("journal.addPhotos")
                    }
                } header: {
                    Text("照片 (\(selectedIDs.count))")
                } footer: {
                    Text(dayAssets.isEmpty ? "這一天沒有照片。" : "挑選這篇日記要呈現的照片。")
                }

                if existingEntry != nil {
                    Section {
                        DestructiveRowButton(title: "刪除日記",
                                             identifier: "journal.delete") {
                            if let id = existingEntry?.id { journalStore.delete(id: id) }
                            dismiss()
                        }
                    }
                }
            }
            // 新增時標題是「新增日記」；編輯既有的顯示那篇的日期。
            .appCanvas()
            .navigationTitle(existingEntry == nil ? "新增日記" : dateTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") { save() }
                    .accessibilityIdentifier("journal.save")
                }
            }
            .task { await load() }
            .sheet(item: $editorSheet) { which in
                switch which {
                case .picker: JournalPhotoPicker(selectedIDs: $selectedIDs)
                case .paywall: PaywallView()
                case .categories: JournalCategoryManagerView()
                }
            }
            .alert("免費版：每日可新增 1 篇日記", isPresented: $showLimitAlert) {
                Button("解鎖完整版") { editorSheet = .paywall }
                Button("取消", role: .cancel) {}
            } message: {
                Text("訂閱解鎖即可無限制記錄生活日記，您仍可隨時編輯既有日記。")
            }
            .onChange(of: selectedIDs) { _ in refreshOthers() }
            .onChange(of: date) { _ in
                // 換日期：新增時只是換照片來源那天，不會去載入那天既有的日記（同一天可以有好幾篇）。
                Task { dayAssets = await library.assets(onYear: year, month: month, day: day); refreshOthers() }
            }
        }
        .accessibilityIdentifier("journal.editor")
    }

    /// 分類：一排膠囊，「沒有分類」固定在最前面，最後一顆是管理分類。
    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(nil, name: "無分類", symbol: nil)
                ForEach(journalStore.categories) { category in
                    categoryChip(category.id, name: category.name, symbol: category.symbol)
                }
                Button { editorSheet = .categories } label: {
                    Label("管理", systemImage: "slider.horizontal.3")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .foregroundStyle(.secondary)
                        .background(Color(.secondarySystemFill), in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("journal.category.manage")
            }
            .padding(.vertical, 2)
        }
    }

    private func categoryChip(_ id: JournalCategory.ID?, name: String, symbol: String?) -> some View {
        let isOn = categoryID == id
        return Button { categoryID = id } label: {
            HStack(spacing: 4) {
                if let symbol { IconLabel(raw: symbol, size: 13) }
                Text(name).font(.subheadline.weight(.medium)).lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(isOn ? Color.white : Color.primary)
            .background(isOn ? Color.accentColor : Color(.secondarySystemFill), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("journal.category.chip")
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
    }

    private func save() {
        if let entry = existingEntry {
            journalStore.update(id: entry.id, mood: mood, text: text,
                                photoIDs: selectedIDs, categoryID: categoryID)
        } else {
            // 免費版每天只能新增 1 則；編輯已有的日記不受限。
            guard model.canCreateJournal else {
                showLimitAlert = true
                return
            }
            let created = journalStore.create(mood: mood, text: text, photoIDs: selectedIDs,
                                              dateKey: dateKey, categoryID: categoryID)
            if created != nil { model.noteJournalCreated() }
        }
        dismiss()
    }

    /// 格子裡的照片：當天的在前，其餘已選的在後。
    private var gridAssets: [PHAsset] { dayAssets + otherAssets }

    /// 已選但不是當天拍的照片，照選的順序。
    private func refreshOthers() {
        let dayIDs = Set(dayAssets.map(\.localIdentifier))
        let ids = selectedIDs.filter { !dayIDs.contains($0) }
        otherAssets = library.assets(withIDs: ids)
    }

    private func selectableThumbnail(_ asset: PHAsset) -> some View {
        let isSelected = selectedIDs.contains(asset.localIdentifier)
        return Button {
            toggle(asset)
        } label: {
            AssetThumbnail(asset: asset, size: 90, showsDuration: false)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.accentColor, lineWidth: 3)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color.accentColor)
                            .padding(3)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(asset.accessibilitySummary)
        .accessibilityValue(Text(isSelected ? "Selected" : "Not selected"))
    }

    private func toggle(_ asset: PHAsset) {
        let id = asset.localIdentifier
        if let index = selectedIDs.firstIndex(of: id) {
            selectedIDs.remove(at: index)
        } else {
            selectedIDs.append(id)
        }
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }

        // 帶進來的照片一律補上，且不重複。
        for id in preselectedIDs where !selectedIDs.contains(id) {
            selectedIDs.append(id)
        }
        dayAssets = await library.assets(onYear: year, month: month, day: day)
        refreshOthers()
    }
}

/// 長按照片跳出的操作，與整理的審核畫面一致。
struct PhotoActionsMenu: View {
    let asset: PHAsset
    /// 備註、標籤、加入相簿等異動的最後時間。沒有異動就是 nil，不顯示。
    var editedAt: Date? = nil
    /// 已經放進日記的照片不再顯示寫日記。
    var showsJournal: Bool = true
    let onJournal: (PHAsset) -> Void
    let onTag: (PHAsset) -> Void
    let onNote: (PHAsset) -> Void
    let onFavorite: (PHAsset) -> Void
    let onAddToAlbum: (PHAsset) -> Void
    let onDelete: (PHAsset) -> Void

    /// 選單一列放得下的短格式：今天只有時間，昨天加「昨天」，更早是「月/日 時間」。
    private static func editedText(_ date: Date) -> String {
        let calendar = Calendar.current
        let time = DateFormatter()
        time.dateFormat = "HH:mm"
        let clock = time.string(from: date)
        if calendar.isDateInToday(date) { return String(localized: "Today (date)") + " " + clock }
        if calendar.isDateInYesterday(date) { return String(localized: "Yesterday") + " " + clock }
        let day = DateFormatter()
        day.setLocalizedDateFormatFromTemplate("Md")
        return day.string(from: date) + " " + clock
    }

    var body: some View {
        // 編輯時間放在選單分組的標題：字比下面的項目小一級，也不能點。
        if let editedAt {
            Section(String(format: String(localized: "Edited %@"), Self.editedText(editedAt))) {
                items
            }
        } else {
            items
        }
    }

    @ViewBuilder
    private var items: some View {
        if showsJournal {
            Button {
                onJournal(asset)
            } label: {
                Label("撰寫日記", systemImage: "book.closed")
            }
        }

        Button {
            onNote(asset)
        } label: {
            Label("相片備註", systemImage: "note.text")
        }

        Button {
            onTag(asset)
        } label: {
            Label("加入標籤", systemImage: "tag")
        }

        Button {
            onFavorite(asset)
        } label: {
            Label(asset.isFavorite ? "取消喜愛" : "加入喜愛",
                  systemImage: asset.isFavorite ? "heart.slash" : "heart")
        }

        // 跟標籤一樣，點了開一張表單：可以建立相簿，也看得到所有相簿。
        Button {
            onAddToAlbum(asset)
        } label: {
            Label("加入相簿", systemImage: "rectangle.stack.badge.plus")
        }

        Divider()

        // 圖示跟整理畫面的刪除一樣用 X。
        Button(role: .destructive) {
            onDelete(asset)
        } label: {
            Label("刪除", systemImage: "xmark")
        }
    }
}

/// 從整個相簿挑照片放進日記。不限當天，一次可以挑很多張。
/// 跟照片分頁一樣：時間軸與全部可以切換，右上角可以篩選（喜好項目、已編輯、不在相簿中、媒體類型）。
struct JournalPhotoPicker: View {
    @Binding var selectedIDs: [String]

    @EnvironmentObject private var library: PhotoLibraryService
    @Environment(\.dismiss) private var dismiss

    private enum Mode: String, CaseIterable, Identifiable {
        case timeline, all
        var id: String { rawValue }
        var title: String {
            self == .timeline ? "時間軸" : "全部"
        }
    }

    @State private var mode: Mode = .all
    @State private var filter: PhotoFilter = .all
    @State private var sortsByAdded = false
    @State private var addedRanks: [String: Int] = [:]
    @State private var assets: [PHAsset] = []
    @State private var sections: [PhotoGrouping.DaySection] = []
    @State private var isLoading = true

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 4)

    private var orderedAssets: [PHAsset] {
        guard sortsByAdded, !addedRanks.isEmpty else { return assets }
        return assets.sorted { (addedRanks[$0.localIdentifier] ?? .min) > (addedRanks[$1.localIdentifier] ?? .min) }
    }

    var body: some View {
        NavigationStack {
            content
            // 時間軸、全部放在頁尾，跟照片分頁的子分頁列同一種玻璃膠囊。
            .safeAreaInset(edge: .bottom, spacing: 0) { modePicker }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 已選張數靠左。
                ToolbarItem(placement: .topBarLeading) {
                    Text(String(format: "已選擇 %lld 張", selectedIDs.count))
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                        .fixedSize()
                        .accessibilityIdentifier("journal.picker.count")
                }
                .sharedBackgroundVisibilityHidden()
                ToolbarItem(placement: .topBarTrailing) { filterMenu }
                // 篩選跟完成各自一塊玻璃，中間隔開，跟照片分頁右上角一樣。
                if #available(iOS 26.0, *) {
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                        .accessibilityIdentifier("journal.picker.done")
                }
            }
            .task(id: filter) { await load() }
            .task(id: mode) { await buildSections() }
            .task(id: sortsByAdded) {
                if sortsByAdded { addedRanks = await library.addedRanks() }
                await buildSections()
            }
        }
        .accessibilityIdentifier("journal.picker")
    }

    private var modePicker: some View {
        HStack(spacing: 0) {
            ForEach(Mode.allCases) { option in
                Button {
                    mode = option
                } label: {
                    Text(option.title)
                        .font(.caption.weight(mode == option ? .semibold : .regular))
                        .foregroundStyle(mode == option ? Color.accentColor : Color.primary.opacity(0.78))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("journal.picker.mode.\(option.rawValue)")
            }
        }
        .padding(.horizontal, 8)
        .floatingGlass(in: Capsule())
        .padding(.horizontal, PageMetrics.edge)
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            ProgressView().frame(maxHeight: .infinity)
        } else if assets.isEmpty {
            Text("此篩選條件下沒有任何照片")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxHeight: .infinity)
        } else {
            ScrollView {
                if mode == .timeline {
                    LazyVStack(alignment: .leading, spacing: 14) {
                        ForEach(sections) { section in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text(section.title).font(.subheadline.weight(.semibold))
                                    Text(section.weekday).font(.caption).foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 12)
                                LazyVGrid(columns: columns, spacing: 2) {
                                    ForEach(section.assets, id: \.localIdentifier) { cell($0) }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)
                } else {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(orderedAssets, id: \.localIdentifier) { cell($0) }
                    }
                }
            }
        }
    }

    /// 跟照片分頁右上角同一組過濾條件。
    private var filterMenu: some View {
        Menu {
            PhotoSortMenuSection(sortsByAdded: $sortsByAdded)
            Divider()
            PhotoFilterMenuSection(isSelected: { filter == $0 }, onSelect: { filter = $0 })
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .overlay(alignment: .topTrailing) {
                    if filter != .all {
                        Circle().fill(.red).frame(width: 7, height: 7).offset(x: 4, y: -3)
                    }
                }
        }
        .accessibilityLabel(Text("篩選"))
        .accessibilityIdentifier("journal.picker.filter")
    }

    private func load() async {
        isLoading = true
        assets = await library.assets(matching: filter)
        await buildSections()
        isLoading = false
    }

    private func buildSections() async {
        guard mode == .timeline else { return }
        sections = await PhotoGrouping.daySections(from: orderedAssets)
        if sortsByAdded {
            sections.sort {
                let firstRank = $0.assets.last.flatMap { addedRanks[$0.localIdentifier] } ?? .min
                let secondRank = $1.assets.last.flatMap { addedRanks[$0.localIdentifier] } ?? .min
                return firstRank > secondRank
            }
        }
    }

    private func cell(_ asset: PHAsset) -> some View {
        let id = asset.localIdentifier
        let isSelected = selectedIDs.contains(id)
        return AssetThumbnail(asset: asset, size: 130, showsDuration: false)
            .overlay {
                if isSelected { Rectangle().fill(Color.accentColor.opacity(0.25)) }
            }
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.subheadline)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.9),
                                     isSelected ? Color.accentColor : .black.opacity(0.25))
                    .padding(4)
            }
            .onTapGesture {
                if let index = selectedIDs.firstIndex(of: id) {
                    selectedIDs.remove(at: index)
                } else {
                    selectedIDs.append(id)
                }
            }
    }
}

private extension ToolbarContent {
    /// iOS 26 以後工具列項目預設有玻璃底，純文字的張數不需要。
    @ToolbarContentBuilder
    func sharedBackgroundVisibilityHidden() -> some ToolbarContent {
        if #available(iOS 26.0, *) {
            self.sharedBackgroundVisibility(.hidden)
        } else {
            self
        }
    }
}
