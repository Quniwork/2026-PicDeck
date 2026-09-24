import SwiftUI
import Photos

private final class SelectionScrollDirectionTracker {
    var previousOffset: CGFloat?
}

@MainActor
private final class PhotoVisibleDateState: ObservableObject {
    @Published var range: ClosedRange<Date>?
    @Published var hasScrolled = false
}

private struct AllGridSnapshot {
    var assets: [PHAsset] = []
    var scrub = ScrubIndex(anchors: [])
}

private struct GridAssetRecord: @unchecked Sendable {
    let asset: PHAsset
    let date: Date?
    let pixelWidth: Int
    let pixelHeight: Int
    let addedRank: Int?
}

private struct PhotosTitleToolbar: ToolbarContent {
    @ObservedObject var dateState: PhotoVisibleDateState
    let title: String
    let itemCount: String
    let isAllScale: Bool
    let colorScheme: ColorScheme

    private var subtitle: String? {
        if isAllScale, let range = dateState.range {
            return DateTitle.range(from: range.lowerBound, to: range.upperBound)
        }
        return isAllScale || dateState.hasScrolled ? itemCount : nil
    }

    var body: some ToolbarContent {
        LeadingTitleToolbar(title: title,
                            accessibilityIdentifier: "photos.title",
                            font: .largeTitle,
                            subtitle: subtitle,
                            reservesSubtitleAlignment: true,
                            titleColor: colorScheme == .dark ? .white : .black,
                            subtitleColor: colorScheme == .dark ? .white.opacity(0.62) : .black.opacity(0.55))
    }
}

/// 照片分頁：App 的首頁，開啟就直接顯示照片。
///
/// 層級之間不推入新畫面，而是切換子分頁並捲到對應位置，
/// 這樣子分頁列與底部分頁列全程保留，也可以繼續上下滑動看其他年、月、日。
struct PhotosTabView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let appColorScheme: ColorScheme
    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var selectionAccessory: PhotosSelectionAccessory
    @EnvironmentObject private var tagStore: TagStore
    @EnvironmentObject private var journalStore: JournalStore
    @EnvironmentObject private var noteStore: NoteStore

    @State private var selection: PhotoSelection = .filter(.all)
    @State private var taggingAsset: PHAsset?
    @State private var journalDate: JournalDate?
    @State private var isSelecting = false
    @State private var selectedIDs: Set<String> = []
    @State private var selectedFavoriteIDs: Set<String> = []
    @State private var showAlbumPicker = false
    @State private var albumPickerAsset: PHAsset?
    @State private var noteAsset: PHAsset?
    @State private var showBatchTagPicker = false
    @State private var showBatchNote = false
    /// 點一張照片打開的全螢幕檢視。
    @State private var detail: DetailTarget?
    /// 點縮圖打開檢視時，從縮圖的位置展開。
    @Namespace private var photoZoom
    @State private var assets: [PHAsset] = []
    @State private var allGrid = AllGridSnapshot()
    @State private var rebuildGridTask: Task<Void, Never>?
    @State private var allGridScrollRequestID = 0
    /// 依加入時間排的名次，切到「已加入」排序時才取。
    @State private var addedRanks: [String: Int] = [:]
    @State private var visibleDateState = PhotoVisibleDateState()
    @State private var years: [PhotoGrouping.Bucket] = []
    @State private var monthCalendars: [PhotoGrouping.YearOfMonths] = []
    @State private var dayCalendars: [PhotoGrouping.MonthOfDays] = []
    @State private var sections: [PhotoGrouping.DaySection] = []
    @State private var dayIndex = ScrubIndex(anchors: [])
    @State private var timelineIndex = ScrubIndex(anchors: [])
    @State private var preparedScales: Set<PhotoScale> = []
    @State private var assetRevision = 0
    @State private var warmTask: Task<Void, Never>?
    /// 目前這份照片是哪個篩選、哪一版圖庫載入的。切回分頁時沒變就沿用，不重建整個格線。
    @State private var loadedSelection: PhotoSelection?
    @State private var loadedChangeCount = -1
    @State private var isLoading = false
    @State private var showPaywall = false
    @State private var monthCoverMonth: PhotoGrouping.MonthCalendar?
    @State private var yearCoverBucket: PhotoGrouping.Bucket?
    @State private var timelineScrollTracker = SelectionScrollDirectionTracker()

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
        case monthCover(PhotoGrouping.MonthCalendar)
        case yearCover(PhotoGrouping.Bucket)

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
            case .monthCover(let month): return "month-cover-\(month.id)"
            case .yearCover(let bucket): return "year-cover-\(bucket.id)"
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
                if let month = monthCoverMonth { return .monthCover(month) }
                if let bucket = yearCoverBucket { return .yearCover(bucket) }
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
                monthCoverMonth = nil
                yearCoverBucket = nil
            }
        )
    }

    var body: some View {
        NavigationStack {
            content
                .background(Color(.systemBackground))
                .safeAreaInset(edge: .top, spacing: 0) {
                    Color.clear
                        .frame(height: dynamicTypeSize.isAccessibilitySize || scale == .all
                               ? 0 : PageMetrics.largeTitleBodyOffset)
                        .accessibilityHidden(true)
                }
                // 換篩選、排序、縮放時內容淡入淡出，不是一下子跳掉。
                .motionAnimation(.easeInOut(duration: 0.22), value: isLoading)
                .motionAnimation(value: selection)
                .motionAnimation(value: model.gridColumns(for: .year))
                .motionAnimation(value: model.gridColumns(for: .month))
                .motionAnimation(value: model.gridColumns(for: .all))
                .motionAnimation(value: model.gridColumns(for: .timeline))
                .failureToast()
                // 年、全部與時間軸：兩指放大縮小。
                .pinchToZoomGrid { zoomIn in
                    if let context = GridContext(scale) { withMotion { model.zoom(context, in: zoomIn) } }
                }
            // 選取工具固定在底部；iOS 26 的年月日切換器由 TabView 底部配件顯示。
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Group {
                    if #unavailable(iOS 26.0) {
                        if isSelecting {
                            selectionBar
                        } else {
                            scalePicker
                        }
                    }
                }
                .transition(.opacity)
            }
            .animation(.easeInOut(duration: 0.2), value: isSelecting)
            .navigationTitle(displayTitle)
            .navigationBarTitleDisplayMode(dynamicTypeSize.isAccessibilitySize ? .large : .inline)
            .toolbarColorScheme(appColorScheme, for: .navigationBar)
            .toolbar {
                if !dynamicTypeSize.isAccessibilitySize {
                    PhotosTitleToolbar(dateState: visibleDateState,
                                       title: displayTitle,
                                       itemCount: itemCountText,
                                       isAllScale: scale == .all,
                                       colorScheme: appColorScheme)
                }
                trailingToolbar
            }
            .task(id: selection) { await loadIfNeeded() }
            // 首頁的標籤卡片點進來時，切到那個標籤。
            .onAppear(perform: applyRequestedSelection)
            .onChange(of: model.lastPhotoScale) { _, newScale in
                // User-driven navigation takes priority over background prewarming.
                warmTask?.cancel()
                visibleDateState.range = nil
                visibleDateState.hasScrolled = false
                timelineScrollTracker.previousOffset = nil
                model.isTimelineScalePickerCompact = false
                anchorYearID = nil
                anchorMonthID = nil
                anchorDayID = nil
                if isSelecting { exitSelection() }
                if newScale == .all { allGridScrollRequestID &+= 1 }
            }
            .onChange(of: model.requestedSelection) { _ in applyRequestedSelection() }
            .onChange(of: model.gridColumns(for: .all)) { _, _ in rebuildAllGrid() }
            .onChange(of: model.gridFitsAspect(for: .all)) { _, _ in rebuildAllGrid() }
            // 勾選或取消勾選時輕輕震一下。
            .sensoryFeedback(.selection, trigger: selectedIDs.count)
            .onChange(of: selectedIDs) { _, _ in refreshSelectionAccessory() }
            // 系統相簿有變動（例如在別處改了喜愛）就重取，長按選單才不會拿到舊狀態。
            .onChange(of: library.libraryChangeCount) { _ in
                Task { await refreshAssets() }
            }
            .task(id: scale) { await rebuildCurrentScale() }
            // 七個獨立的 .sheet 掛在同一個畫面上，照片分頁在「首頁之後才第一次建立」時整個掛不上去
            // （畫面被求值了，.task 與 onAppear 卻都沒有觸發，結果是一片空白）。所以合併成一個。
            .fullScreenCover(item: $detail) { target in
                PhotoDetailView(assets: target.assets, startID: target.startID)
                    .zoomDestination(id: target.startID, in: photoZoom)
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
                case .monthCover(let month):
                    NavigationStack {
                        PhotoCoverEditorView(title: month.title,
                                             candidates: assets(in: month),
                                             initial: model.monthCover(for: month.year, month: month.month)) { cover in
                            model.setMonthCover(cover, year: month.year, month: month.month)
                        }
                    }
                case .yearCover(let bucket):
                    NavigationStack {
                        PhotoCoverEditorView(title: bucket.title,
                                             candidates: assets(in: bucket),
                                             aspectRatio: model.gridColumns(for: .year) == 1 ? 4.0 / 3.0 : 1,
                                             initial: model.yearCover(for: bucket.year)) { cover in
                            model.setYearCover(cover, year: bucket.year)
                        }
                    }
                }
            }
        }
    }

    // MARK: - 多選

    /// 只有全部與時間軸可以多選。
    private var supportsSelection: Bool {
        scale == .all || scale == .timeline
    }

    /// 選取與篩選是分開的按鈕；篩選固定最右側。
    @ToolbarContentBuilder
    private var trailingToolbar: some ToolbarContent {
        if supportsSelection {
            ToolbarItem(placement: .topBarTrailing) { selectButton }
            if #available(iOS 26.0, *) {
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
            }
        }
        ToolbarItem(placement: .topBarTrailing) { filterMenu }
    }

    private var selectButton: some View {
        Button {
            withMotion {
                isSelecting.toggle()
                model.isSelectingPhotos = isSelecting
                timelineScrollTracker.previousOffset = nil
                model.isTimelineScalePickerCompact = false
                selectionAccessory.content = isSelecting ? AnyView(selectionBar) : nil
                if !isSelecting {
                    selectedIDs.removeAll()
                    selectedFavoriteIDs.removeAll()
                }
            }
        } label: {
            if isSelecting {
                Text("Cancel")
            } else {
                Image(systemName: "checkmark.circle")
            }
        }
        .accessibilityLabel(Text(isSelecting ? "Done selecting" : "Select"))
        .accessibilityIdentifier("photos.select")
    }

    /// 「全部」格狀畫面用的順序：依拍攝時間，或依加入時間。其他子分頁固定依拍攝日期分組。
    private var gridAssets: [PHAsset] { allGrid.assets }

    // MARK: - 右側拖拉軸

    /// 全部：依照片列高分配拖拉軸權重，原比例格線下也能大致對準日期位置。
    nonisolated private static func makeAllScrub(for records: [GridAssetRecord],
                                                 columnCount: Int,
                                                 usesAspectRatio: Bool) -> ScrubIndex {
        guard !records.isEmpty else { return ScrubIndex(anchors: []) }
        let rowCount = (records.count + columnCount - 1) / columnCount
        let sampleStep = max(1, (rowCount + 1499) / 1500)
        var anchors: [ScrubAnchor] = []
        anchors.reserveCapacity((rowCount + sampleStep - 1) / sampleStep)

        for rowIndex in stride(from: 0, to: rowCount, by: sampleStep) {
            let start = rowIndex * columnCount
            let rowsEnd = min(start + sampleStep * columnCount, records.count)
            var weight = 0.0
            var firstDate: Date?
            for rowStart in stride(from: start, to: rowsEnd, by: columnCount) {
                let rowEnd = min(rowStart + columnCount, records.count)
                let row = records[rowStart..<rowEnd]
                let rowHeight = usesAspectRatio
                    ? row.map { $0.pixelWidth > 0 ? Double($0.pixelHeight) / Double($0.pixelWidth) : 1 }.max() ?? 1
                    : 1
                weight += max(rowHeight, 0.1)
                if firstDate == nil { firstDate = row.compactMap(\.date).first }
            }
            // Each coarse anchor represents the total height of its sampled rows.
            if let date = firstDate { anchors.append(ScrubAnchor(date: date, weight: max(weight, 0.0001))) }
        }
        return ScrubIndex(anchors: anchors)
    }

    private func rebuildAllGrid() {
        rebuildGridTask?.cancel()
        let sourceAssets = assets
        let ranks = addedRanks
        let sortsByAdded = model.sortsByAdded
        let hasAddedRanks = !ranks.isEmpty
        let columns = max(model.gridColumns(for: .all), 1)
        let fitsAspect = model.gridFitsAspect(for: .all)
        rebuildGridTask = Task {
            // A pinch can update the grid settings many times per second. Wait for the
            // gesture to settle so canceled requests don't repeatedly scan the library.
            try? await Task.sleep(for: .milliseconds(120))
            guard !Task.isCancelled else { return }
            let worker = Task.detached(priority: .userInitiated) { () -> ([PHAsset], ScrubIndex)? in
                var records: [GridAssetRecord] = []
                records.reserveCapacity(sourceAssets.count)
                for (index, asset) in sourceAssets.enumerated() {
                    if index.isMultiple(of: 256), Task.isCancelled { return nil }
                    records.append(GridAssetRecord(asset: asset, date: asset.creationDate,
                                                   pixelWidth: asset.pixelWidth, pixelHeight: asset.pixelHeight,
                                                   addedRank: ranks[asset.localIdentifier]))
                }
                var ordered = records
                if sortsByAdded, hasAddedRanks {
                    ordered.sort { ($0.addedRank ?? .max) > ($1.addedRank ?? .max) }
                } else {
                    ordered.reverse()
                }
                guard !Task.isCancelled else { return nil }
                return (ordered.map(\.asset), Self.makeAllScrub(for: ordered, columnCount: columns,
                                                                 usesAspectRatio: fitsAspect))
            }
            let result = await withTaskCancellationHandler { await worker.value } onCancel: { worker.cancel() }
            guard !Task.isCancelled, let result else { return }
            allGrid = AllGridSnapshot(assets: result.0, scrub: result.1)
        }
    }

    /// 時間軸：一天一個落點。權重是這一天佔的列數加上標題。
    private func makeTimelineIndex(for sections: [PhotoGrouping.DaySection]) -> ScrubIndex {
        ScrubIndex(anchors: sections.map {
            ScrubAnchor(date: $0.date, weight: (Double($0.count) / 4).rounded(.up) + 0.8)
        })
    }

    /// 日：一個月一個落點，月曆大多是五到六列。
    private func makeDayIndex(for months: [PhotoGrouping.MonthOfDays]) -> ScrubIndex {
        ScrubIndex(anchors: months.compactMap { month -> ScrubAnchor? in
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

    private var allSelectedAreFavorites: Bool {
        !selectedIDs.isEmpty && selectedIDs.isSubset(of: selectedFavoriteIDs)
    }

    private var selectionBar: some View {
        ActionBarRow {
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
        .padding(.vertical, 8)
        // iOS 26 的底部配件已經提供玻璃底板；再加一層會讓內層變實、外側仍透明。
        .modifier(SelectionBarSurface())
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, PageMetrics.edge)
        .padding(.vertical, 6)
    }

    private func selectionAction(_ key: LocalizedStringKey,
                                 icon: String,
                                 id: String,
                                 isDestructive: Bool = false,
                                 action: @escaping () -> Void) -> some View {
        ActionBarButton(key: key, icon: icon, id: id, isDestructive: isDestructive,
                        iconOnly: false, action: action)
    }

    /// 刪除：跟整理一樣先放進待刪清單，不會直接刪掉，之後可以在待刪清單確認或還原。
    private func deleteSelected() {
        for id in selectedIDs { model.markTrashed(id) }
        exitSelection()
    }

    /// 選取的照片都已經是喜愛，按鈕就變成「移出喜愛」。
    /// 加入喜愛：已經是喜愛的照片跳過。全部都已經是喜愛時，改成移出喜愛。
    /// 做完留在選取模式，不跳出去；畫面不重排，照片還在原位。
    private func favoriteSelected() {
        let picked = selectedAssets
        let removing = allSelectedAreFavorites
        let targets = removing ? picked : picked.filter { !$0.isFavorite }
        guard !targets.isEmpty else { return }
        Task {
            for asset in targets {
                let succeeded = await library.attempt(String(localized: "Couldn't change favorites")) {
                    try await library.setFavorite(asset, to: !removing)
                }
                guard succeeded else { continue }
                if removing {
                    selectedFavoriteIDs.remove(asset.localIdentifier)
                } else {
                    selectedFavoriteIDs.insert(asset.localIdentifier)
                }
            }
        }
    }

    private func exitSelection() {
        withMotion {
            isSelecting = false
            model.isSelectingPhotos = false
            selectionAccessory.content = nil
            timelineScrollTracker.previousOffset = nil
            model.isTimelineScalePickerCompact = false
            selectedIDs.removeAll()
            selectedFavoriteIDs.removeAll()
        }
    }

    private func refreshSelectionAccessory() {
        guard isSelecting else { return }
        selectionAccessory.content = AnyView(selectionBar)
    }

    /// 長按照片的操作，與整理的審核畫面一致。
    @ViewBuilder
    private func photoActions(for staleAsset: PHAsset) -> some View {
        // 不在建立格子時同步查 PhotoKit：上萬張照片時會讓主執行緒被 watchdog 終止。
        // 外部相簿更新會由 libraryChangeCount 刷新這份 PHAsset 快照。
        PhotoActionsMenu(asset: staleAsset,
                         editedAt: editedDate(for: staleAsset),
                         showsJournal: !journalStore.isInJournal(staleAsset),
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
        Task {
            await library.attempt(String(localized: "Couldn't change favorites")) {
                try await library.setFavorite(current, to: !current.isFavorite)
            }
        }
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

    /// 只有離開列表頂端後才在標題下顯示項目數；回到頂端再隱藏。
    private func updateCountVisibility(_ offset: CGFloat) {
        updateTimelineScalePicker(for: offset)
        let hasScrolled = offset > 12
        if visibleDateState.hasScrolled != hasScrolled {
            visibleDateState.hasScrolled = hasScrolled
        }
    }

    private func updateTimelineScalePicker(for offset: CGFloat) {
        guard scale == .timeline, !isSelecting else { return }
        let previous = timelineScrollTracker.previousOffset
        timelineScrollTracker.previousOffset = offset
        guard let previous else { return }

        if offset > previous + 4, offset > 24 {
            if !model.isTimelineScalePickerCompact {
                model.isTimelineScalePickerCompact = true
            }
        } else if offset < previous - 4 || offset <= 12 {
            if model.isTimelineScalePickerCompact {
                model.isTimelineScalePickerCompact = false
            }
        }
    }

    // MARK: - 內容

    @ViewBuilder
    private var content: some View {
        if isLoading {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if assets.isEmpty {
            AppEmptyState(icon: "photo.on.rectangle",
                          title: String(localized: "No photos"),
                          message: String(localized: "This filter has nothing to show."))
        } else {
            Group {
                if scale == .all {
                    allGridContent
                } else {
                    otherScaleContent
                }
            }
        }
    }

    @ViewBuilder
    private var otherScaleContent: some View {
            switch scale {
            case .year:
                BucketGridView(buckets: years,
                               columns: model.gridColumns(for: .year),
                               onScrollOffsetChange: updateCountVisibility,
                               coverForBucket: { model.yearCover(for: $0.year) },
                               onEditCover: { yearCoverBucket = $0 }) { bucket in
                    // 點年份 → 切到月，並捲到該年。
                    anchorYearID = "yr\(bucket.year)"
                    switchScale(to: .month, keepAnchors: true)
                }

            case .month:
                MonthCalendarGridView(years: monthCalendars, focusYearID: anchorYearID,
                                      onScrollOffsetChange: updateCountVisibility,
                                      columnsPerRow: model.gridColumns(for: .month),
                                      coverForMonth: { model.monthCover(for: $0.year, month: $0.month) },
                                      onEditCover: { monthCoverMonth = $0 }) { month in
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
                                    scrub: dayIndex,
                                    onScrollOffsetChange: updateCountVisibility)

            case .timeline:
                TimelineView(sections: sections,
                             focusSectionID: anchorDayID,
                             actions: { AnyView(photoActions(for: $0)) },
                             isSelecting: isSelecting,
                             selectedIDs: $selectedIDs,
                             selectedFavoriteIDs: $selectedFavoriteIDs,
                             anniversaryTag: filteredAnniversaryTag,
                             scrub: timelineIndex,
                             columnCount: model.gridColumns(for: .timeline),
                             fitsAspect: model.gridFitsAspect(for: .timeline),
                             onScrollOffsetChange: updateCountVisibility,
                             onOpen: { open($0, in: assets) },
                             zoomNamespace: photoZoom)

            case .all:
                EmptyView()
            }
    }

    private var allGridContent: some View {
                                CompactGridView(assets: gridAssets,
                                columns: model.gridColumns(for: .all),
                                fitsAspect: model.gridFitsAspect(for: .all),
                                onOpen: { open($0, in: gridAssets) },
                                actions: { AnyView(photoActions(for: $0)) },
                                isSelecting: isSelecting,
                                selectedIDs: $selectedIDs,
                                selectedFavoriteIDs: $selectedFavoriteIDs,
                                scrub: allGrid.scrub,
                                onVisibleDateRangeChange: { offset, start, end in
                                    let nextRange: ClosedRange<Date>?
                                    if offset > 24, let start, let end {
                                        nextRange = min(start, end)...max(start, end)
                                    } else {
                                        nextRange = nil
                                    }
                                    if let old = visibleDateState.range, let nextRange,
                                       PhotoGrouping.calendar.isDate(old.lowerBound, inSameDayAs: nextRange.lowerBound),
                                       PhotoGrouping.calendar.isDate(old.upperBound, inSameDayAs: nextRange.upperBound) { return }
                                    if visibleDateState.range == nil, nextRange == nil { return }
                                    visibleDateState.range = nextRange
                                },
                                scrollRequestID: allGridScrollRequestID,
                                zoomNamespace: photoZoom,
                                thumbnailsActive: scale == .all)
                    .id(model.sortsByAdded)
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

    /// 標籤與照片條件都由這個篩選選單管理；排序放前面，日期曆維持時間順序。
    private var hasActiveFilter: Bool {
        !selection.isAll || !model.showsScreenshots ||
            ((scale == .all || scale == .timeline) && model.sortsByAdded)
    }

    /// 快速點兩下：全部恢復預設。
    private func resetFilters() {
        selection = .filter(.all)
        model.showsScreenshots = true
        model.sortsByAdded = false
    }

    private var filterMenu: some View {
        Menu {
            if scale == .all || scale == .timeline {
                PhotoSortMenuSection(sortsByAdded: $model.sortsByAdded)
                Divider()
            }

            Menu(String(localized: "Tag Filter")) {
                if tagStore.tags.isEmpty {
                    Text(String(localized: "No tags"))
                } else {
                    ForEach(tagStore.tags) { tag in tagButton(tag) }
                }
            }

            Menu(String(localized: "Filter Criteria")) {
                PhotoFilterMenuSection(isSelected: { selection == .filter($0) },
                                       onSelect: { choose(.filter($0)) },
                                       showsSectionTitle: false)
            }

            // 跟系統照片一樣，這個子選單的標題沒有圖示。
            // 年、月、全部、時間軸都有顯示方式；排序只在全部與時間軸提供。
            if let context = GridContext(scale) {
                Menu(String(localized: "View Options")) {
                    Button {
                        model.zoom(context, in: true)
                    } label: {
                        Label(String(localized: "Zoom In"), systemImage: "plus.magnifyingglass")
                    }
                    .disabled(model.gridColumns(for: context) <= AppModel.columnRange(for: context).lowerBound)

                    Button {
                        model.zoom(context, in: false)
                    } label: {
                        Label(String(localized: "Zoom Out"), systemImage: "minus.magnifyingglass")
                    }
                    .disabled(model.gridColumns(for: context) >= AppModel.columnRange(for: context).upperBound)

                    if context == .all || context == .timeline {
                        Picker(String(localized: "Grid Ratio"), selection: Binding(
                            get: { model.gridFitsAspect(for: context) },
                            set: { model.setGridFitsAspect($0, for: context) }
                        )) {
                            Text("Square (1:1)").tag(false)
                            Text("Original Ratio").tag(true)
                        }
                    }
                    Section(String(localized: "Show:")) {
                        Toggle(isOn: $model.showsScreenshots) {
                            Label(String(localized: "Screenshots"), systemImage: "camera.viewfinder")
                        }
                    }
                }
            }

            Divider()
            ResetFiltersButton(isActive: hasActiveFilter) { resetFilters() }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .filterIndicator(isActive: hasActiveFilter) { resetFilters() }
        }
        .accessibilityLabel(Text("Filter"))
        .accessibilityIdentifier("photos.filter")
        .onChange(of: model.showsScreenshots) { _ in Task { await reload() } }
        .onChange(of: model.sortsByAdded) { newValue in
            visibleDateState.range = nil
            Task {
                if newValue, addedRanks.isEmpty { addedRanks = await library.addedRanks() }
                rebuildAllGrid()
                preparedScales.remove(.timeline)
                await rebuildCurrentScale()
            }
        }
    }

    private func assets(in month: PhotoGrouping.MonthCalendar) -> [PHAsset] {
        assets.filter { asset in
            guard let date = asset.creationDate else { return false }
            let parts = PhotoGrouping.calendar.dateComponents([.year, .month], from: date)
            return parts.year == month.year && parts.month == month.month
        }
    }

    private func assets(in bucket: PhotoGrouping.Bucket) -> [PHAsset] {
        assets.filter { asset in
            guard let date = asset.creationDate else { return false }
            return PhotoGrouping.calendar.component(.year, from: date) == bucket.year
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
        let scale = model.requestedScale
        model.requestedScale = nil

        // 從別的分頁或小工具跳進來：畫面同時在換分頁，內容不要再做淡入淡出，才不會一頓一頓。
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            // 沒解鎖不能用的篩選：只跳付費頁，其他一律不動，關掉付費頁之後也看不到那個標籤的內容。
            guard choose(requested) else { return }
            // 有指定子分頁（小工具指定時間軸）就切過去，蓋過標籤預設的子分頁。
            if let scale, model.canUse(scale) { switchScale(to: scale, keepAnchors: false) }
        }
    }

    @discardableResult
    private func choose(_ newSelection: PhotoSelection) -> Bool {
        guard model.canUse(newSelection) else {
            showPaywall = true
            return false
        }
        selection = newSelection
        // 有日子的標籤看時間軸（每天顯示過了多久），沒有的看全部。
        if case .tag(let id) = newSelection, let tag = tagStore.tag(withID: id) {
            switchScale(to: tag.hasAnniversary ? .timeline : .all, keepAnchors: false)
        }
        return true
    }

    // MARK: - 子分頁

    private var scalePicker: some View {
        PhotoScalePickerContent(isCompact: false, usesLegacyGlass: true, appColorScheme: appColorScheme)
    }

    // MARK: - 載入

    /// 只重取照片與相簿清單，不動位置也不顯示載入中，變動很頻繁時畫面才不會閃。
    private func refreshAssets() async {
        replaceAssets(with: await loadAssets())
        await loadAddedRanksIfNeeded()
        rebuildAllGrid()
        await rebuildCurrentScale()
        scheduleWarmScales()
    }

    /// 分頁每次出現都會跑。只有換了篩選才整個重載；圖庫變過就安靜更新；其餘沿用現有畫面。
    /// 上萬張照片時每次切回來都重建格線，主執行緒會卡到被 watchdog 終止。
    private func loadIfNeeded() async {
        guard loadedSelection == selection else { return await reload() }
        // 標籤是 App 端資料，可能在別的分頁改過，所以標籤篩選一律安靜更新。
        if case .tag = selection {
            await refreshAssets()
        } else if loadedChangeCount != library.libraryChangeCount {
            await refreshAssets()
        }
    }

    private func reload() async {
        isLoading = true
        defer { isLoading = false }

        visibleDateState.range = nil
        visibleDateState.hasScrolled = false
        anchorYearID = nil
        anchorMonthID = nil
        anchorDayID = nil
        replaceAssets(with: await loadAssets())
        await loadAddedRanksIfNeeded()
        rebuildAllGrid()
        await rebuildCurrentScale()
        scheduleWarmScales()
    }

    private func replaceAssets(with loaded: [PHAsset]) {
        loadedSelection = selection
        loadedChangeCount = library.libraryChangeCount
        warmTask?.cancel()
        assetRevision &+= 1
        preparedScales.removeAll()
        assets = loaded
    }

    /// 「全部」先顯示目前畫面的縮圖，再用較低優先序準備其他層級。
    private func scheduleWarmScales() {
        warmTask?.cancel()
        let revision = assetRevision
        warmTask = Task(priority: .utility) {
            try? await Task.sleep(for: .milliseconds(350))
            for nextScale in [PhotoScale.year, .month, .day, .timeline] {
                guard !Task.isCancelled, revision == assetRevision else { return }
                await prepareScale(nextScale, priority: .utility)
            }
        }
    }

    private func loadAddedRanksIfNeeded() async {
        guard model.sortsByAdded, addedRanks.isEmpty else { return }
        addedRanks = await library.addedRanks()
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

    /// 每批照片的每個層級只分組一次；切回已看過的層級直接沿用結果。
    private func rebuildCurrentScale() async {
        await prepareScale(scale, priority: .userInitiated)
    }

    private func prepareScale(_ requestedScale: PhotoScale, priority: TaskPriority) async {
        guard !assets.isEmpty else { return }
        if preparedScales.contains(requestedScale) { return }
        guard !Task.isCancelled else { return }

        let revision = assetRevision
        let source = assets
        let sortsByAdded = model.sortsByAdded
        let ranks = addedRanks

        switch requestedScale {
        case .year:
            let result = await PhotoGrouping.years(from: source, priority: priority)
            guard revision == assetRevision, !Task.isCancelled else { return }
            years = result
        case .month:
            let result = await PhotoGrouping.monthCalendars(from: source, priority: priority)
            guard revision == assetRevision, !Task.isCancelled else { return }
            monthCalendars = result
        case .day:
            let result = await PhotoGrouping.dayCalendars(from: source, priority: priority)
            guard revision == assetRevision, !Task.isCancelled else { return }
            dayCalendars = result
            dayIndex = makeDayIndex(for: result)
        case .timeline:
            let result = await PhotoGrouping.daySections(from: source,
                                                         priority: priority,
                                                         addedRanks: sortsByAdded ? ranks : nil)
            guard revision == assetRevision, sortsByAdded == model.sortsByAdded,
                  !Task.isCancelled else { return }
            sections = result
            timelineIndex = makeTimelineIndex(for: result)
        case .all:
            break
        }
        preparedScales.insert(requestedScale)
    }
}


/// 照片檢視切換器：在底部配件展開時使用膠囊，收合時縮成單列按鈕。
struct PhotoScalePickerContent: View {
    @EnvironmentObject private var model: AppModel
    let isCompact: Bool
    var usesLegacyGlass = false
    let appColorScheme: ColorScheme

    private var inactiveColor: Color {
        appColorScheme == .dark ? .white.opacity(0.78) : .black.opacity(0.72)
    }

    var body: some View {
        HStack(spacing: isCompact ? 2 : 0) {
            ForEach(PhotoScale.allCases) { option in
                Button {
                    guard model.canUse(option) else { return }
                    model.setLastPhotoScale(option)
                } label: {
                    HStack(spacing: 2) {
                        Text(option.title)
                        if !model.canUse(option) {
                            Image(systemName: "lock.fill").font(.system(size: 8))
                        }
                    }
                    .font((isCompact ? Font.caption : .footnote).weight(model.lastPhotoScale == option ? .semibold : .regular))
                    .foregroundStyle(model.lastPhotoScale == option ? Color.accentColor : inactiveColor)
                    .frame(maxWidth: .infinity, minHeight: isCompact ? 30 : 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("scale.\(option.rawValue)")
            }
        }
        .padding(.horizontal, usesLegacyGlass ? 8 : (isCompact ? 2 : 0))
        .modifier(LegacyPhotoScaleGlass(isEnabled: usesLegacyGlass))
    }
}

@available(iOS 26.0, *)
struct PhotosTabAccessory: View {
    @Environment(\.tabViewBottomAccessoryPlacement) private var placement
    @EnvironmentObject private var model: AppModel
    let appColorScheme: ColorScheme

    var body: some View {
        PhotoScalePickerContent(isCompact: placement == .inline ||
                                (model.lastPhotoScale == .timeline && model.isTimelineScalePickerCompact),
                                appColorScheme: appColorScheme)
    }
}

private struct LegacyPhotoScaleGlass: ViewModifier {
    let isEnabled: Bool

    func body(content: Content) -> some View {
        if isEnabled {
            content
                .floatingGlass(in: Capsule())
                .padding(.horizontal, PageMetrics.edge)
                .padding(.vertical, 6)
        } else {
            content
        }
    }
}

private struct SelectionBarSurface: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
        } else {
            content.floatingGlass(in: RoundedRectangle(cornerRadius: 26, style: .continuous))
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
