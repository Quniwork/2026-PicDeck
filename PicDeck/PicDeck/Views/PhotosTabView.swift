import SwiftUI
import Photos

/// 照片分頁：App 的首頁，開啟就直接顯示照片。
///
/// 層級之間不推入新畫面，而是切換子分頁並捲到對應位置，
/// 這樣子分頁列與底部分頁列全程保留，也可以繼續上下滑動看其他年、月、日。
struct PhotosTabView: View {
    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var tagStore: TagStore
    @EnvironmentObject private var journalStore: JournalStore
    @EnvironmentObject private var noteStore: NoteStore

    @State private var selection: PhotoSelection = .filter(.all)
    @State private var taggingAsset: PHAsset?
    @State private var journalDate: JournalDate?
    @State private var isSelecting = false
    @State private var selectedIDs: Set<String> = []
    @State private var showAlbumPicker = false
    @State private var albumPickerAsset: PHAsset?
    @State private var noteAsset: PHAsset?
    @State private var showBatchTagPicker = false
    @State private var showBatchNote = false
    /// 點一張照片打開的全螢幕檢視。
    @State private var detail: DetailTarget?
    @State private var albums: [AlbumSummary] = []
    @State private var assets: [PHAsset] = []
    /// 依加入時間排的名次，切到「已加入」排序時才取。
    @State private var addedRanks: [String: Int] = [:]
    @State private var years: [PhotoGrouping.Bucket] = []
    @State private var monthCalendars: [PhotoGrouping.YearOfMonths] = []
    @State private var dayCalendars: [PhotoGrouping.MonthOfDays] = []
    @State private var sections: [PhotoGrouping.DaySection] = []
    @State private var isLoading = false
    @State private var showPaywall = false

    /// 從上一層點進來時要捲到的位置，手動切子分頁時會清掉。
    @State private var anchorYearID: String?
    @State private var anchorMonthID: String?
    @State private var anchorDayID: String?

    private var scale: PhotoScale { model.lastPhotoScale }

    /// 檢視要翻的照片清單與起點。
    struct DetailTarget: Identifiable {
        let assets: [PHAsset]
        let startID: String
        var id: String { startID }
    }

    private func open(_ asset: PHAsset, in list: [PHAsset]) {
        detail = DetailTarget(assets: list, startID: asset.localIdentifier)
    }

    /// 這個畫面會跳出的所有表單。
    private enum ActiveSheet: Identifiable {
        case paywall
        case tags(PHAsset)
        case journal(JournalDate)
        case batchTags
        case batchNote
        case batchAlbum
        case album(PHAsset)
        case note(PHAsset)

        var id: String {
            switch self {
            case .paywall: return "paywall"
            case .tags(let asset): return "tags-\(asset.localIdentifier)"
            case .journal(let date): return "journal-\(date.id)"
            case .batchTags: return "batchTags"
            case .batchNote: return "batchNote"
            case .batchAlbum: return "batchAlbum"
            case .album(let asset): return "album-\(asset.localIdentifier)"
            case .note(let asset): return "note-\(asset.localIdentifier)"
            }
        }
    }

    /// 由既有的幾個狀態合成一個綁定，其他程式碼不用改。
    private var activeSheet: Binding<ActiveSheet?> {
        Binding(
            get: {
                if showPaywall { return .paywall }
                if let asset = taggingAsset { return .tags(asset) }
                if let date = journalDate { return .journal(date) }
                if showBatchTagPicker { return .batchTags }
                if showBatchNote { return .batchNote }
                if showAlbumPicker { return .batchAlbum }
                if let asset = albumPickerAsset { return .album(asset) }
                if let asset = noteAsset { return .note(asset) }
                return nil
            },
            set: { newValue in
                guard newValue == nil else { return }
                showPaywall = false
                taggingAsset = nil
                journalDate = nil
                showBatchTagPicker = false
                showBatchNote = false
                showAlbumPicker = false
                albumPickerAsset = nil
                noteAsset = nil
            }
        )
    }

    var body: some View {
        NavigationStack {
            content
                // 每個分頁的背景統一用系統的分組灰底（首頁、日記、整理、更多也是）。
                .background(Color(.systemGroupedBackground))
            // 子分類與選取列都是浮在內容上面的玻璃膠囊，內容會捲到它們後面，跟頂部一樣看得穿。
            // 選取中不需要切換年月日，所以換成選取列。
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Group {
                    if isSelecting {
                        selectionBar
                    } else {
                        scalePicker
                    }
                }
                .transition(.opacity)
            }
            .animation(.easeInOut(duration: 0.2), value: isSelecting)
            // 標題就是標籤切換器：靠左的大字標題加小箭頭，點了直接選「所有項目」或某個標籤。
            // 系統的大標題不能點，所以標題自己畫在工具列左邊，系統標題留空。
            .navigationTitle(displayTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) { Text("").accessibilityHidden(true) }
                titleToolbarItem
                trailingToolbar
            }
            .task(id: selection) { await reload() }
            // 首頁的標籤卡片點進來時，切到那個標籤。
            .onAppear(perform: applyRequestedSelection)
            .onChange(of: model.requestedSelection) { _ in applyRequestedSelection() }
            // 勾選或取消勾選時輕輕震一下。
            .sensoryFeedback(.selection, trigger: selectedIDs.count)
            // 系統相簿有變動（例如在別處改了喜愛）就重取，長按選單才不會拿到舊狀態。
            .onChange(of: library.libraryChangeCount) { _ in
                Task { await refreshAssets() }
            }
            .task(id: scale) { await rebuildCurrentScale() }
            // 七個獨立的 .sheet 掛在同一個畫面上，照片分頁在「首頁之後才第一次建立」時整個掛不上去
            // （畫面被求值了，.task 與 onAppear 卻都沒有觸發，結果是一片空白）。所以合併成一個。
            .fullScreenCover(item: $detail) { target in
                PhotoDetailView(assets: target.assets, startID: target.startID)
            }
            .sheet(item: activeSheet) { sheet in
                switch sheet {
                case .paywall:
                    PaywallView()
                case .tags(let asset):
                    TagPickerView(assets: [asset])
                case .journal(let date):
                    JournalEditorView(year: date.year, month: date.month, day: date.day,
                                      preselectedIDs: date.photoIDs)
                case .batchTags:
                    TagPickerView(assets: selectedAssets)
                case .batchNote:
                    BatchNoteView(assets: selectedAssets) { exitSelection() }
                case .batchAlbum:
                    AlbumPickerView(assets: selectedAssets)
                case .album(let asset):
                    AlbumPickerView(assets: [asset])
                case .note(let asset):
                    NoteEditorView(asset: asset)
                }
            }
        }
    }

    // MARK: - 多選

    /// 只有全部與時間軸可以多選。
    private var supportsSelection: Bool {
        scale == .all || scale == .timeline
    }

    /// 右上角跟系統照片一樣：圓形的篩選鈕、文字的「選取」，各自一塊玻璃，中間隔開。
    @ToolbarContentBuilder
    private var trailingToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) { filterMenu }
        if supportsSelection {
            if isSelecting {
                // 選取中：篩選旁多一個「…」放全選，最右邊是 X 退出。
                ToolbarItem(placement: .topBarTrailing) { selectionMoreMenu }
            }
            if #available(iOS 26.0, *) {
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
            }
            ToolbarItem(placement: .topBarTrailing) { selectButton }
        }
    }

    private var selectionMoreMenu: some View {
        Menu {
            Button {
                selectedIDs = Set(gridAssets.map(\.localIdentifier))
            } label: {
                Label(String(localized: "Select All"), systemImage: "checkmark.circle")
            }
            Button {
                selectedIDs.removeAll()
            } label: {
                Label(String(localized: "Deselect All"), systemImage: "circle")
            }
        } label: {
            Image(systemName: "ellipsis")
        }
        .accessibilityLabel(Text("More"))
        .accessibilityIdentifier("photos.selectionMore")
    }

    private var selectButton: some View {
        Button {
            withMotion {
                isSelecting.toggle()
                if !isSelecting { selectedIDs.removeAll() }
            }
        } label: {
            if isSelecting {
                Image(systemName: "xmark")
            } else {
                Text("Select")
            }
        }
        .accessibilityLabel(Text(isSelecting ? "Done selecting" : "Select"))
        .accessibilityIdentifier("photos.select")
    }

    /// 「全部」格狀畫面用的順序：依拍攝時間，或依加入時間。其他子分頁固定依拍攝日期分組。
    private var gridAssets: [PHAsset] {
        guard model.sortsByAdded, !addedRanks.isEmpty else { return assets }
        return assets.sorted { (addedRanks[$0.localIdentifier] ?? .max) < (addedRanks[$1.localIdentifier] ?? .max) }
    }

    // MARK: - 右側拖拉軸

    /// 全部：每張照片各一個落點，格子高度一致所以權重都是 1。
    private var allScrub: ScrubIndex {
        ScrubIndex(anchors: gridAssets.compactMap { asset in
            guard let date = asset.creationDate else { return nil }
            return ScrubAnchor(date: date, weight: 1)
        })
    }

    /// 時間軸：一天一個落點。權重是這一天佔的列數加上標題。
    private var timelineScrub: ScrubIndex {
        ScrubIndex(anchors: sections.map {
            ScrubAnchor(date: $0.date, weight: (Double($0.count) / 4).rounded(.up) + 0.8)
        })
    }

    /// 日：一個月一個落點，月曆大多是五到六列。
    private var dayScrub: ScrubIndex {
        ScrubIndex(anchors: dayCalendars.compactMap { month -> ScrubAnchor? in
            var parts = DateComponents()
            parts.year = month.year
            parts.month = month.month
            parts.day = 1
            guard let date = PhotoGrouping.calendar.date(from: parts) else { return nil }
            return ScrubAnchor(date: date, weight: 1)
        })
    }

    /// 目前篩選到的標籤，而且那個標籤有設日期。
    /// 只有這種情況才在日期旁邊顯示年月日，平常瀏覽維持原本的樣子。
    private var filteredAnniversaryTag: PhotoTag? {
        guard case .tag(let id) = selection,
              let tag = tagStore.tag(withID: id),
              tag.hasAnniversary else { return nil }
        return tag
    }

    private var selectedAssets: [PHAsset] {
        library.assets(withIDs: Array(selectedIDs))
    }

    /// 選取的照片依拍攝時間由早到晚。
    private var selectedAssetsByDate: [PHAsset] {
        selectedAssets.sorted { ($0.creationDate ?? .distantFuture) < ($1.creationDate ?? .distantFuture) }
    }

    /// 多選寫日記的日期：選取的照片裡最早那張的拍攝日。不限同一天，沒有任何拍攝日期才不能寫。
    private var earliestSelectedDay: (year: Int, month: Int, day: Int)? {
        guard let date = selectedAssetsByDate.compactMap(\.creationDate).first else { return nil }
        let parts = PhotoGrouping.calendar.dateComponents([.year, .month, .day], from: date)
        guard let y = parts.year, let m = parts.month, let d = parts.day else { return nil }
        return (y, m, d)
    }

    private var selectionBar: some View {
        VStack(spacing: 6) {
            Text("\(selectedIDs.count) selected")
                .font(.footnote)
                .foregroundStyle(.secondary)

            // 兩端內縮一樣，按鈕依內容寬度，中間的空隙平均分配。
            ActionBarRow {
                // 日期用最早那張的拍攝日。全部都已經在日記裡的話不顯示。
                if let day = earliestSelectedDay,
                   !selectedAssets.allSatisfy(journalStore.isInJournal) {
                    selectionAction("Journal", icon: "book.closed", id: "batch.journal") {
                        journalDate = JournalDate(year: day.year, month: day.month, day: day.day,
                                                  photoIDs: selectedAssetsByDate.map(\.localIdentifier))
                        exitSelection()
                    }
                    Spacer(minLength: 4)
                }

                selectionAction("Note", icon: "note.text", id: "batch.note") {
                    showBatchNote = true
                }
                Spacer(minLength: 4)

                selectionAction("Tags", icon: "tag", id: "batch.tags") {
                    showBatchTagPicker = true
                }
                Spacer(minLength: 4)

                selectionAction("Album", icon: "rectangle.stack.badge.plus", id: "batch.album") {
                    showAlbumPicker = true
                }
                Spacer(minLength: 4)

                selectionAction(allSelectedAreFavorites ? "Remove from favorites" : "Favorite",
                                icon: allSelectedAreFavorites ? "heart.slash" : "heart",
                                id: "batch.favorite") {
                    favoriteSelected()
                }
                Spacer(minLength: 4)

                selectionAction("Delete", icon: "xmark", id: "batch.delete", isDestructive: true) {
                    deleteSelected()
                }
            }
            .disabled(selectedIDs.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .floatingGlass(in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    private func selectionAction(_ key: LocalizedStringKey,
                                 icon: String,
                                 id: String,
                                 isDestructive: Bool = false,
                                 action: @escaping () -> Void) -> some View {
        ActionBarButton(key: key, icon: icon, id: id, isDestructive: isDestructive, action: action)
    }

    /// 刪除：跟整理一樣先放進待刪清單，不會直接刪掉，之後可以在待刪清單確認或還原。
    private func deleteSelected() {
        for id in selectedIDs { model.markTrashed(id) }
        exitSelection()
    }

    /// 選取的照片都已經是喜愛，按鈕就變成「移出喜愛」。
    private var allSelectedAreFavorites: Bool {
        let picked = selectedAssets
        return !picked.isEmpty && picked.allSatisfy(\.isFavorite)
    }

    /// 加入喜愛：已經是喜愛的照片跳過。全部都已經是喜愛時，改成移出喜愛。
    /// 做完留在選取模式，不跳出去；畫面不重排，照片還在原位。
    private func favoriteSelected() {
        let picked = selectedAssets
        let removing = allSelectedAreFavorites
        let targets = removing ? picked : picked.filter { !$0.isFavorite }
        guard !targets.isEmpty else { return }
        Task {
            for asset in targets {
                try? await library.setFavorite(asset, to: !removing)
            }
        }
    }

    private func exitSelection() {
        withMotion {
            isSelecting = false
            selectedIDs.removeAll()
        }
    }

    /// 長按照片的操作，與整理的審核畫面一致。
    @ViewBuilder
    private func photoActions(for staleAsset: PHAsset) -> some View {
        // 照片是載入時抓的快照。在系統相簿或別處改過喜愛，這裡的 isFavorite 會是舊的，
        // 所以每次叫出選單都重新取一次，才能正確顯示成「移出喜愛」。
        let asset = library.asset(withID: staleAsset.localIdentifier) ?? staleAsset
        PhotoActionsMenu(asset: asset,
                         editedAt: editedDate(for: asset),
                         showsJournal: !journalStore.isInJournal(asset),
                         onJournal: { openJournal(for: $0) },
                         onTag: { taggingAsset = $0 },
                         onNote: { noteAsset = $0 },
                         onFavorite: { toggleFavorite($0) },
                         onAddToAlbum: { albumPickerAsset = $0 },
                         onDelete: { model.markTrashed($0.localIdentifier) })
    }

    /// 這張照片最近一次被改的時間：備註、標籤，或系統照片的修改時間（比拍攝時間晚一分鐘以上才算）。
    private func editedDate(for asset: PHAsset) -> Date? {
        var dates: [Date] = []
        if let note = noteStore.note(for: asset)?.updatedAt { dates.append(note) }
        if let tags = tagStore.lastEdited(for: asset) { dates.append(tags) }
        if let modified = asset.modificationDate, let created = asset.creationDate,
           modified.timeIntervalSince(created) > 60 { dates.append(modified) }
        return dates.max()
    }

    private func toggleFavorite(_ asset: PHAsset) {
        let current = library.asset(withID: asset.localIdentifier) ?? asset
        Task { try? await library.setFavorite(current, to: !current.isFavorite) }
    }

    private func openJournal(for asset: PHAsset) {
        guard let date = asset.creationDate else { return }
        let parts = PhotoGrouping.calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = parts.year, let month = parts.month, let day = parts.day else { return }
        // 長按進來時，預設先選好這張照片。
        journalDate = JournalDate(year: year, month: month, day: day,
                                  photoIDs: [asset.localIdentifier])
    }

    private var selectionTitle: String {
        switch selection {
        case .filter(let filter):
            return filter == .all ? String(localized: "All Items") : filter.title
        case .tag(let id):
            guard let tag = tagStore.tag(withID: id) else { return String(localized: "All Items") }
            return tag.name
        }
    }

    /// 標題只放名稱；標籤的圖示留在選單裡。
    private var displayTitle: String { selectionTitle }

    /// 標題下面的項目數。
    private var itemCountText: String {
        String(format: String(localized: "%lld items"), assets.count)
    }

    /// 標題選單放在工具列左邊。iOS 26 以後工具列項目預設有玻璃底，標題不需要，所以關掉。
    @ToolbarContentBuilder
    private var titleToolbarItem: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: .topBarLeading) { titleMenu }
                .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: .topBarLeading) { titleMenu }
        }
    }

    /// 點標題切換標籤：所有項目、每一個標籤（照管理頁排的順序）、最後是管理標籤。
    private var titleMenu: some View {
        Menu {
            Toggle(isOn: Binding(get: { selection.isAll },
                                 set: { _ in choose(.filter(.all)) })) {
                Label(String(localized: "All Items"), systemImage: "square.grid.2x2")
            }

            if !tagStore.tags.isEmpty {
                Section(String(localized: "Tags")) {
                    ForEach(tagStore.tags) { tag in
                        tagButton(tag)
                    }
                }
            }

            Divider()
            Button {
                // 管理標籤在整理分頁的「標籤」子層。
                model.organizeSection = .tags
                model.selectedTab = 3
            } label: {
                Label("Manage tags", systemImage: "gearshape")
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    // 篩選到標籤時，名稱前面顯示它的表情或圖示；所有項目不需要。
                    if case .tag(let id) = selection, let tag = tagStore.tag(withID: id) {
                        IconLabel(raw: tag.symbol, size: 22)
                    }
                    Text(displayTitle)
                        .font(TypeScale.titleWithActions.weight(.bold))
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                Text(itemCountText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
            .contentShape(Rectangle())
            // 跟右邊的按鈕視覺置中，不要偏上。
            .offset(y: 4)
        }
        .accessibilityLabel(Text(displayTitle))
        .accessibilityHint(Text("Switch tag"))
        .accessibilityIdentifier("photos.title")
    }

    // MARK: - 內容

    @ViewBuilder
    private var content: some View {
        if isLoading {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if assets.isEmpty {
            ContentUnavailableView {
                Label("No photos", systemImage: "photo.on.rectangle")
            } description: {
                Text("This filter has nothing to show.")
            }
        } else {
            switch scale {
            case .year:
                BucketGridView(buckets: years, minimum: 100) { bucket in
                    // 點年份 → 切到月，並捲到該年。
                    anchorYearID = "yr\(bucket.year)"
                    switchScale(to: .month, keepAnchors: true)
                }

            case .month:
                MonthCalendarGridView(years: monthCalendars, focusYearID: anchorYearID) { month in
                    // 點月份 → 切到日，並捲到該月。
                    anchorMonthID = "md\(month.year)-\(month.month)"
                    switchScale(to: .day, keepAnchors: true)
                }

            case .day:
                DayCalendarGridView(months: dayCalendars,
                                    focusMonthID: anchorMonthID,
                                    onSelect: { year, month, day in
                                        // 點某一天 → 切到時間軸，並捲到那天。
                                        anchorDayID = "s\(year)-\(month)-\(day)"
                                        switchScale(to: .timeline, keepAnchors: true)
                                    },
                                    scrub: dayScrub)

            case .timeline:
                TimelineView(sections: sections,
                             focusSectionID: anchorDayID,
                             actions: { AnyView(photoActions(for: $0)) },
                             isSelecting: isSelecting,
                             selectedIDs: $selectedIDs,
                             anniversaryTag: filteredAnniversaryTag,
                             scrub: timelineScrub,
                             columnCount: model.gridColumns(for: .timeline),
                             fitsAspect: model.gridFitsAspect(for: .timeline),
                             onOpen: { open($0, in: assets) })

            case .all:
                CompactGridView(assets: gridAssets,
                                columns: model.gridColumns(for: .all),
                                fitsAspect: model.gridFitsAspect(for: .all),
                                onOpen: { open($0, in: gridAssets) },
                                actions: { AnyView(photoActions(for: $0)) },
                                isSelecting: isSelecting,
                                selectedIDs: $selectedIDs,
                                scrub: allScrub)

            }
        }
    }

    /// 切換子分頁。手動點子分頁列時清掉錨點，從卡片點進來時保留。
    private func switchScale(to newScale: PhotoScale, keepAnchors: Bool) {
        if isSelecting { exitSelection() }
        if !keepAnchors {
            anchorYearID = nil
            anchorMonthID = nil
            anchorDayID = nil
        }
        model.setLastPhotoScale(newScale)
    }

    // MARK: - 篩選

    /// 跟系統照片的篩選選單同一套：排序、過濾條件、媒體類型、顯示方式選項。
    private var filterMenu: some View {
        Menu {
            // 排序：上面一排兩個「圖示加文字」，選中的有底色，跟系統一樣。
            ControlGroup {
                Toggle(isOn: Binding(get: { model.sortsByAdded }, set: { _ in model.sortsByAdded = true })) {
                    Label(String(localized: "Date Added"), systemImage: "clock")
                }
                Toggle(isOn: Binding(get: { !model.sortsByAdded }, set: { _ in model.sortsByAdded = false })) {
                    Label(String(localized: "Capture Date"), systemImage: "camera")
                }
            }

            PhotoFilterMenuSection(isSelected: { selection == .filter($0) },
                                   onSelect: { choose(.filter($0)) })

            // 跟系統照片一樣，這個子選單的標題沒有圖示。
            // 全部、時間軸、日記各自設定；年、月、日沒有這個選項。
            if let context = GridContext(scale) {
                Menu(String(localized: "View Options")) {
                    Button {
                        model.zoom(context, in: true)
                    } label: {
                        Label(String(localized: "Zoom In"), systemImage: "plus.magnifyingglass")
                    }
                    .disabled(model.gridColumns(for: context) <= Self.columnRange.lowerBound)

                    Button {
                        model.zoom(context, in: false)
                    } label: {
                        Label(String(localized: "Zoom Out"), systemImage: "minus.magnifyingglass")
                    }
                    .disabled(model.gridColumns(for: context) >= Self.columnRange.upperBound)

                    Toggle(isOn: Binding(get: { model.gridFitsAspect(for: context) },
                                         set: { model.setGridFitsAspect($0, for: context) })) {
                        Label(String(localized: "Aspect Ratio Grid"),
                              systemImage: "rectangle.arrowtriangle.2.outward")
                    }

                    Section(String(localized: "Show:")) {
                        Toggle(isOn: $model.showsScreenshots) {
                            Label(String(localized: "Screenshots"), systemImage: "camera.viewfinder")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .overlay(alignment: .topTrailing) {
                    if case .filter(let current) = selection, current != .all {
                        Circle().fill(.red).frame(width: 7, height: 7).offset(x: 4, y: -3)
                    }
                }
        }
        .accessibilityLabel(Text("Filter"))
        .accessibilityIdentifier("photos.filter")
        .onChange(of: model.showsScreenshots) { _ in Task { await reload() } }
        .onChange(of: model.sortsByAdded) { newValue in
            guard newValue, addedRanks.isEmpty else { return }
            Task { addedRanks = await library.addedRanks() }
        }
    }

    private static var columnRange: ClosedRange<Int> { AppModel.gridColumnRange }

    private func filterButton(_ option: PhotoFilter) -> some View {
        Toggle(isOn: Binding(get: { selection == .filter(option) },
                             set: { _ in choose(.filter(option)) })) {
            Label(option.title, systemImage: option.systemImage)
        }
    }

    /// 選單裡每個標籤：左邊是它自己的圖示（表情或圖示都一樣放在圖示位置），右邊只有名稱。
    /// 選單只吃圖片，所以把圖示先畫成圖片。
    @ViewBuilder
    private func tagButton(_ tag: PhotoTag) -> some View {
        Toggle(isOn: Binding(get: { selection == .tag(tag.id) },
                             set: { _ in choose(.tag(tag.id)) })) {
            Label {
                Text(tag.name)
            } icon: {
                TagMenuIcon(tag: tag, isLocked: !model.isUnlocked)
            }
        }
        .accessibilityLabel(tag.name)
    }

    /// 選篩選條件，沒解鎖就導到付費頁。
    private func applyRequestedSelection() {
        guard let requested = model.requestedSelection else { return }
        model.requestedSelection = nil
        choose(requested)
    }

    private func choose(_ newSelection: PhotoSelection) {
        if model.canUse(newSelection) {
            selection = newSelection
            // 有日子的標籤看時間軸（每天顯示過了多久），沒有的看全部。
            if case .tag(let id) = newSelection, let tag = tagStore.tag(withID: id) {
                switchScale(to: tag.hasAnniversary ? .timeline : .all, keepAnchors: false)
            }
        } else {
            showPaywall = true
        }
    }

    // MARK: - 子分頁

    private var scalePicker: some View {
        HStack(spacing: 0) {
            ForEach(PhotoScale.allCases) { option in
                Button {
                    if model.canUse(option) {
                        switchScale(to: option, keepAnchors: false)
                    } else {
                        showPaywall = true
                    }
                } label: {
                    HStack(spacing: 2) {
                        Text(option.title)
                        if !model.canUse(option) {
                            Image(systemName: "lock.fill").font(.system(size: 8))
                        }
                    }
                    .font(.footnote.weight(scale == option ? .semibold : .regular))
                    .foregroundStyle(scale == option ? Color.accentColor : Color.primary.opacity(0.78))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("scale.\(option.rawValue)")
            }
        }
        .padding(.horizontal, 8)
        .floatingGlass(in: Capsule())
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }

    // MARK: - 載入

    /// 只重取照片與相簿清單，不動位置也不顯示載入中，變動很頻繁時畫面才不會閃。
    private func refreshAssets() async {
        assets = await loadAssets()
        albums = await library.userAlbums()
        await rebuildCurrentScale()
    }

    private func reload() async {
        isLoading = true
        defer { isLoading = false }

        anchorYearID = nil
        anchorMonthID = nil
        anchorDayID = nil
        assets = await loadAssets()
        albums = await library.userAlbums()
        await rebuildCurrentScale()
    }

    private func loadAssets() async -> [PHAsset] {
        let loaded: [PHAsset]
        switch selection {
        case .filter(let filter):
            loaded = await library.assets(matching: filter)
            // 選「截圖」就是要看截圖，不受顯示開關影響。
            if filter == .screenshots || model.showsScreenshots { return loaded }
            return loaded.filter { !$0.mediaSubtypes.contains(.photoScreenshot) }
        case .tag(let tagID):
            // 標籤是 App 端資料，先取全部照片再依標籤過濾。
            let all = await library.assets(matching: .all)
            loaded = all.filter { tagStore.tagIDs(for: $0).contains(tagID) }
            return model.showsScreenshots ? loaded : loaded.filter { !$0.mediaSubtypes.contains(.photoScreenshot) }
        }
    }

    /// 只算目前子分頁需要的分組，切換時才重算。
    private func rebuildCurrentScale() async {
        guard !assets.isEmpty else { return }

        switch scale {
        case .year:
            years = await PhotoGrouping.years(from: assets)
        case .month:
            monthCalendars = await PhotoGrouping.monthCalendars(from: assets)
        case .day:
            dayCalendars = await PhotoGrouping.dayCalendars(from: assets)
        case .timeline:
            sections = await PhotoGrouping.daySections(from: assets)
        case .all:
            break
        }
    }
}


/// 日記要開哪一天，以及要預先選好的照片。
struct JournalDate: Identifiable, Hashable {
    let year: Int
    let month: Int
    let day: Int
    var photoIDs: [String] = []
    /// 從日記分頁的「＋」新增的，編輯畫面可以改日期。
    var isNew = false
    var id: String { JournalStore.key(year: year, month: month, day: day) }
}
