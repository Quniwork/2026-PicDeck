import SwiftUI
import Photos

/// 寫日記：選心情、寫文字，並挑選當天要附上的照片。
/// 以「日」為單位，同一天共用一篇。
struct JournalEditorView: View {
    let initialYear: Int
    let initialMonth: Int
    let initialDay: Int
    /// 從長按或多選進來時，預設先選好這些照片。
    var preselectedIDs: [String] = []
    /// 從「＋」新增時可以改日期。從照片進來的日期由照片決定，不能改。
    var allowsDateChange = false

    init(year: Int, month: Int, day: Int,
         preselectedIDs: [String] = [], allowsDateChange: Bool = false) {
        initialYear = year
        initialMonth = month
        initialDay = day
        self.preselectedIDs = preselectedIDs
        self.allowsDateChange = allowsDateChange
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        _date = State(initialValue: PhotoGrouping.calendar.date(from: parts) ?? Date())
    }

    @EnvironmentObject private var journalStore: JournalStore
    @EnvironmentObject private var library: PhotoLibraryService
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var mood = ""
    @State private var text = ""
    @State private var selectedIDs: [String] = []
    @State private var dayAssets: [PHAsset] = []
    /// 已選、但不是當天拍的照片（從「加入照片」挑的）。
    @State private var otherAssets: [PHAsset] = []
    @State private var showPicker = false
    @State private var isLoading = true

    private let photoColumns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 4)

    private var parts: DateComponents {
        PhotoGrouping.calendar.dateComponents([.year, .month, .day], from: date)
    }
    private var year: Int { parts.year ?? initialYear }
    private var month: Int { parts.month ?? initialMonth }
    private var day: Int { parts.day ?? initialDay }

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
                    } footer: {
                        if journalStore.entry(forKey: dateKey) != nil {
                            Text("This day already has an entry. Saving will replace it.")
                        }
                    }
                }

                Section {
                    HStack(spacing: 12) {
                        IconPickerButton(raw: $mood,
                                         size: 44,
                                         removedValue: "",
                                         identifier: "journal.mood")
                        Text(mood.isEmpty ? "Tap to pick a mood" : "Tap to change")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.vertical, 2)
                } header: {
                    Text("Mood")
                }

                Section(String(localized: "Journal")) {
                    TextField(String(localized: "What happened today?"),
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
                            showPicker = true
                        } label: {
                            Label(dayAssets.isEmpty ? String(localized: "Add photos")
                                                    : String(localized: "Add more photos"),
                                  systemImage: "photo.badge.plus")
                                .frame(maxWidth: .infinity)
                        }
                        .accessibilityIdentifier("journal.addPhotos")
                    }
                } header: {
                    Text("Photos  (\(selectedIDs.count))")
                } footer: {
                    Text(dayAssets.isEmpty ? "No photos on this day." : "Pick the photos to show with this entry.")
                }

                if journalStore.entry(forKey: dateKey) != nil {
                    Section {
                        DestructiveRowButton(title: String(localized: "Delete entry"),
                                             identifier: "journal.delete") {
                            journalStore.delete(forKey: dateKey)
                            dismiss()
                        }
                    }
                }
            }
            // 新增時標題就是「新增日記」，日期在下面的欄位改；編輯既有的才顯示日期。
            .navigationTitle(allowsDateChange ? String(localized: "New journal entry") : dateTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        journalStore.save(mood: mood, text: text,
                                          photoIDs: selectedIDs, forKey: dateKey)
                        dismiss()
                    }
                    .accessibilityIdentifier("journal.save")
                }
            }
            .task { await load() }
            .sheet(isPresented: $showPicker) {
                JournalPhotoPicker(selectedIDs: $selectedIDs)
            }
            .onChange(of: selectedIDs) { _ in refreshOthers() }
            .onChange(of: date) { _ in
                // 換日期：那天已經有日記就載入它來編輯（一天只有一篇），並重取那天的照片。
                Task { await dateChanged() }
            }
        }
        .accessibilityIdentifier("journal.editor")
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
        return AssetThumbnail(asset: asset, size: 90, showsDuration: false)
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
            .onTapGesture { toggle(asset) }
    }

    private func toggle(_ asset: PHAsset) {
        let id = asset.localIdentifier
        if let index = selectedIDs.firstIndex(of: id) {
            selectedIDs.remove(at: index)
        } else {
            selectedIDs.append(id)
        }
    }

    private func dateChanged() async {
        if let existing = journalStore.entry(forKey: dateKey) {
            mood = existing.mood
            text = existing.text
            selectedIDs = existing.photoIDs
        }
        dayAssets = await library.assets(onYear: year, month: month, day: day)
        refreshOthers()
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }

        if let existing = journalStore.entry(forKey: dateKey) {
            mood = existing.mood
            text = existing.text
            selectedIDs = existing.photoIDs
        }
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
                Label("Write journal", systemImage: "book.closed")
            }
        }

        Button {
            onNote(asset)
        } label: {
            Label("Write note", systemImage: "note.text")
        }

        Button {
            onTag(asset)
        } label: {
            Label("Add tag", systemImage: "tag")
        }

        Button {
            onFavorite(asset)
        } label: {
            Label(asset.isFavorite ? "Remove from favorites" : "Add to favorites",
                  systemImage: asset.isFavorite ? "heart.slash" : "heart")
        }

        // 跟標籤一樣，點了開一張表單：可以建立相簿，也看得到所有相簿。
        Button {
            onAddToAlbum(asset)
        } label: {
            Label("Add to album", systemImage: "rectangle.stack.badge.plus")
        }

        Divider()

        // 圖示跟整理畫面的刪除一樣用 X。
        Button(role: .destructive) {
            onDelete(asset)
        } label: {
            Label("Delete", systemImage: "xmark")
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
            self == .timeline ? String(localized: "Timeline") : String(localized: "All")
        }
    }

    @State private var mode: Mode = .all
    @State private var filter: PhotoFilter = .all
    @State private var assets: [PHAsset] = []
    @State private var sections: [PhotoGrouping.DaySection] = []
    @State private var isLoading = true

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 4)

    var body: some View {
        NavigationStack {
            content
            // 時間軸、全部放在頁尾，跟照片分頁的子分頁列同一種玻璃膠囊。
            .safeAreaInset(edge: .bottom, spacing: 0) { modePicker }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 已選張數靠左。
                ToolbarItem(placement: .topBarLeading) {
                    Text(String(format: String(localized: "Selected %lld"), selectedIDs.count))
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
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("journal.picker.done")
                }
            }
            .task(id: filter) { await load() }
            .task(id: mode) { await buildSections() }
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
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            ProgressView().frame(maxHeight: .infinity)
        } else if assets.isEmpty {
            Text("This filter has nothing to show.")
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
                        ForEach(assets, id: \.localIdentifier) { cell($0) }
                    }
                }
            }
        }
    }

    /// 跟照片分頁右上角同一組過濾條件。
    private var filterMenu: some View {
        Menu {
            PhotoFilterMenuSection(isSelected: { filter == $0 }, onSelect: { filter = $0 })
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .overlay(alignment: .topTrailing) {
                    if filter != .all {
                        Circle().fill(.red).frame(width: 7, height: 7).offset(x: 4, y: -3)
                    }
                }
        }
        .accessibilityLabel(Text("Filter"))
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
        sections = await PhotoGrouping.daySections(from: assets)
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
