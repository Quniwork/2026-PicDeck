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

    @State private var selection: PhotoSelection = .filter(.all)
    @State private var taggingAsset: PHAsset?
    @State private var journalDate: JournalDate?
    @State private var isSelecting = false
    @State private var selectedIDs: Set<String> = []
    @State private var showAlbumPicker = false
    @State private var showBatchTagPicker = false
    @State private var showTagFilterSheet = false
    @State private var albums: [AlbumSummary] = []
    @State private var assets: [PHAsset] = []
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

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 依標籤篩選時，上面列出所有標籤方便快速換一個看。
                if selectedTagID != nil {
                    TagSwitcherBar(selected: selectedTagID,
                                   onPick: { choose(.tag($0.id)) },
                                   onClear: { choose(.filter(.all)) })
                }
                content
                scalePicker
            }
            .navigationTitle(selectionTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) { titleView }
                if supportsSelection {
                    ToolbarItem(placement: .topBarLeading) { selectButton }
                }
                ToolbarItem(placement: .topBarTrailing) { filterMenu }
            }
            .safeAreaInset(edge: .bottom) {
                if isSelecting { selectionBar }
            }
            .task(id: selection) { await reload() }
            .task(id: scale) { await rebuildCurrentScale() }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .sheet(item: $taggingAsset) { asset in
                TagPickerView(assets: [asset])
            }
            .sheet(item: $journalDate) { date in
                JournalEditorView(year: date.year, month: date.month, day: date.day,
                                  preselectedIDs: date.photoIDs)
            }
            .sheet(isPresented: $showBatchTagPicker) {
                TagPickerView(assets: selectedAssets)
            }
            .sheet(isPresented: $showTagFilterSheet) {
                TagFilterSheet(selected: selectedTagID) { tag in
                    choose(.tag(tag.id))
                }
            }
            .sheet(isPresented: $showAlbumPicker) {
                AlbumQuickPicker(albums: albums) { album in
                    addSelectedToAlbum(album)
                }
            }
        }
    }

    // MARK: - 多選

    /// 只有全部與時間軸可以多選。
    private var supportsSelection: Bool {
        scale == .all || scale == .timeline
    }

    private var selectButton: some View {
        Button {
            withAnimation {
                isSelecting.toggle()
                if !isSelecting { selectedIDs.removeAll() }
            }
        } label: {
            Image(systemName: isSelecting ? "checkmark.circle.fill" : "checkmark.circle")
        }
        .accessibilityIdentifier("photos.select")
    }

    // MARK: - 右側拖拉軸

    /// 全部：每張照片各一個落點。
    private var allScrub: ScrubIndex {
        ScrubIndex(anchors: assets.compactMap { asset in
            guard let date = asset.creationDate else { return nil }
            return ScrubAnchor(id: asset.localIdentifier, date: date, count: 1)
        }, itemsPerScreen: 28)
    }

    /// 時間軸：一天一個落點，帶上當天張數。
    private var timelineScrub: ScrubIndex {
        ScrubIndex(anchors: sections.map {
            ScrubAnchor(id: $0.id, date: $0.date, count: $0.count)
        }, itemsPerScreen: 28)
    }

    /// 日：一個月一個落點。
    private var dayScrub: ScrubIndex {
        let anchors = dayCalendars.compactMap { month -> ScrubAnchor? in
            var parts = DateComponents()
            parts.year = month.year
            parts.month = month.month
            parts.day = 1
            guard let date = PhotoGrouping.calendar.date(from: parts) else { return nil }
            return ScrubAnchor(id: month.id, date: date, count: 1)
        }
        return ScrubIndex(anchors: anchors, itemsPerScreen: 2)
    }

    /// 日記要顯示哪些篇。沒篩選就全部顯示，有篩選就只留照片落在篩選結果裡的。
    private var journalPhotoFilter: Set<String>? {
        guard !selection.isAll else { return nil }
        return Set(assets.map(\.localIdentifier))
    }

    /// 目前篩選到的標籤，而且那個標籤有設起算日。
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

    /// 選取的照片是否全部同一天，只有同一天才能寫日記。
    private var singleSelectedDay: (year: Int, month: Int, day: Int)? {
        let assets = selectedAssets
        guard !assets.isEmpty else { return nil }

        var found: (Int, Int, Int)?
        for asset in assets {
            guard let date = asset.creationDate else { return nil }
            let parts = PhotoGrouping.calendar.dateComponents([.year, .month, .day], from: date)
            guard let y = parts.year, let m = parts.month, let d = parts.day else { return nil }
            if let found {
                if found != (y, m, d) { return nil }
            } else {
                found = (y, m, d)
            }
        }
        return found
    }

    private var selectionBar: some View {
        VStack(spacing: 8) {
            Text("\(selectedIDs.count) selected")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                // 只有選同一天的照片才出現寫日記。
                if let day = singleSelectedDay {
                    selectionAction("Write journal", icon: "square.and.pencil", id: "batch.journal") {
                        journalDate = JournalDate(year: day.year, month: day.month, day: day.day,
                                                  photoIDs: Array(selectedIDs))
                        exitSelection()
                    }
                }

                selectionAction("Tags", icon: "tag", id: "batch.tags") {
                    showBatchTagPicker = true
                }

                selectionAction("Favorite", icon: "heart", id: "batch.favorite") {
                    favoriteSelected()
                }

                selectionAction("Add to album", icon: "rectangle.stack.badge.plus", id: "batch.album") {
                    showAlbumPicker = true
                }
            }
            .disabled(selectedIDs.isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private func selectionAction(_ key: LocalizedStringKey,
                                 icon: String,
                                 id: String,
                                 action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.title3)
                Text(key).font(.caption2)
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityIdentifier(id)
    }

    /// 加入喜愛：已經是喜愛的照片跳過不處理。
    private func favoriteSelected() {
        let targets = selectedAssets.filter { !$0.isFavorite }
        guard !targets.isEmpty else {
            exitSelection()
            return
        }
        Task {
            for asset in targets {
                try? await library.setFavorite(asset, to: true)
            }
            exitSelection()
        }
    }

    private func addSelectedToAlbum(_ album: AlbumSummary) {
        let targets = selectedAssets
        Task {
            for asset in targets {
                try? await library.addAsset(asset, toAlbumWithID: album.id)
            }
            albums = await library.userAlbums()
            exitSelection()
        }
    }

    private func exitSelection() {
        withAnimation {
            isSelecting = false
            selectedIDs.removeAll()
        }
    }

    /// 長按照片的操作，與整理的審核畫面一致。
    @ViewBuilder
    private func photoActions(for asset: PHAsset) -> some View {
        PhotoActionsMenu(asset: asset,
                         albums: albums,
                         onJournal: { openJournal(for: $0) },
                         onTag: { taggingAsset = $0 },
                         onFavorite: { toggleFavorite($0) },
                         onAddToAlbum: { addToAlbum($0, album: $1) })
    }

    private func toggleFavorite(_ asset: PHAsset) {
        Task { try? await library.setFavorite(asset, to: !asset.isFavorite) }
    }

    private func addToAlbum(_ asset: PHAsset, album: AlbumSummary) {
        Task {
            try? await library.addAsset(asset, toAlbumWithID: album.id)
            albums = await library.userAlbums()
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

    /// 篩選到標籤時，標題前面帶上那個標籤的圖示。
    @ViewBuilder
    private var titleView: some View {
        HStack(spacing: 5) {
            if case .tag(let id) = selection, let tag = tagStore.tag(withID: id) {
                IconLabel(raw: tag.symbol, size: 15)
            }
            Text(selectionTitle).font(.headline)
        }
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
                .safeAreaInset(edge: .bottom) { countFooter("\(years.count) years") }

            case .month:
                MonthCalendarGridView(years: monthCalendars, focusYearID: anchorYearID) { month in
                    // 點月份 → 切到日，並捲到該月。
                    anchorMonthID = "md\(month.year)-\(month.month)"
                    switchScale(to: .day, keepAnchors: true)
                }
                .safeAreaInset(edge: .bottom) { countFooter("\(totalMonthCount) months") }

            case .day:
                DayCalendarGridView(months: dayCalendars,
                                    focusMonthID: anchorMonthID,
                                    onSelect: { year, month, day in
                                        // 點某一天 → 切到時間軸，並捲到那天。
                                        anchorDayID = "s\(year)-\(month)-\(day)"
                                        switchScale(to: .timeline, keepAnchors: true)
                                    },
                                    scrub: dayScrub)
                .safeAreaInset(edge: .bottom) { countFooter("\(totalDayCount) days") }

            case .timeline:
                TimelineView(sections: sections,
                             focusSectionID: anchorDayID,
                             actions: { AnyView(photoActions(for: $0)) },
                             isSelecting: isSelecting,
                             selectedIDs: $selectedIDs,
                             anniversaryTag: filteredAnniversaryTag,
                             scrub: timelineScrub)

            case .all:
                CompactGridView(assets: assets,
                                actions: { AnyView(photoActions(for: $0)) },
                                isSelecting: isSelecting,
                                selectedIDs: $selectedIDs,
                                scrub: allScrub)

            case .journal:
                JournalEntriesView(onEdit: { year, month, day in
                    journalDate = JournalDate(year: year, month: month, day: day)
                },
                                   anniversaryTag: filteredAnniversaryTag,
                                   allowedPhotoIDs: journalPhotoFilter)
            }
        }
    }

    private var totalMonthCount: Int {
        monthCalendars.reduce(0) { $0 + $1.months.count }
    }

    private var totalDayCount: Int {
        dayCalendars.reduce(0) { $0 + $1.cells.count }
    }

    private func countFooter(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
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

    private var filterMenu: some View {
        Menu {
            Section(String(localized: "Filter")) {
                ForEach(PhotoFilter.allCases) { option in
                    Button {
                        choose(.filter(option))
                    } label: {
                        Label {
                            Text(option.title)
                        } icon: {
                            Image(systemName: selection == .filter(option) ? "checkmark" : option.systemImage)
                        }
                    }
                }
            }

            if !tagStore.tags.isEmpty {
                // 標籤收成下一層，標籤變多時上面那層才不會被灌爆。
                Menu {
                    ForEach(shortcutTags) { tag in
                        tagButton(tag)
                    }
                    if tagStore.tags.count > shortcutTagLimit {
                        Divider()
                        Button {
                            showTagFilterSheet = true
                        } label: {
                            Label("All tags…", systemImage: "ellipsis")
                        }
                    }
                } label: {
                    Label(selectedTagName ?? String(localized: "Tags"), systemImage: "tag")
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .overlay(alignment: .topTrailing) {
                    if !selection.isAll {
                        Circle().fill(.red).frame(width: 7, height: 7).offset(x: 4, y: -3)
                    }
                }
        }
        .accessibilityIdentifier("photos.filter")
    }

    /// 下一層直接列出來的標籤數量上限。超過就只列常用的，其餘進「全部標籤」。
    private let shortcutTagLimit = 10

    /// 選中的那個永遠在，其餘依使用次數排，取前幾個。
    private var shortcutTags: [PhotoTag] {
        let tags = tagStore.tags
        guard tags.count > shortcutTagLimit else { return tags }

        var picked: [PhotoTag] = []
        if case .tag(let id) = selection, let current = tagStore.tag(withID: id) {
            picked.append(current)
        }
        // 順序由使用者在管理頁排好，這裡就照那個順序取前幾個。
        let rest = tags.filter { tag in !picked.contains(where: { $0.id == tag.id }) }
        picked.append(contentsOf: rest.prefix(shortcutTagLimit - picked.count))
        return picked
    }

    private var selectedTagID: UUID? {
        if case .tag(let id) = selection { return id }
        return nil
    }

    private var selectedTagName: String? {
        guard case .tag(let id) = selection else { return nil }
        return tagStore.tag(withID: id)?.name
    }

    @ViewBuilder
    private func tagButton(_ tag: PhotoTag) -> some View {
        Button {
            choose(.tag(tag.id))
        } label: {
            Label {
                HStack(spacing: 4) {
                    IconLabel(raw: tag.symbol, size: 15)
                    Text(tag.name)
                }
            } icon: {
                if selection == .tag(tag.id) {
                    Image(systemName: "checkmark")
                } else if !model.isUnlocked {
                    Image(systemName: "lock.fill")
                } else {
                    Image(systemName: "tag")
                }
            }
        }
        .accessibilityLabel(tag.name)
    }

    /// 選篩選條件，沒解鎖就導到付費頁。
    private func choose(_ newSelection: PhotoSelection) {
        if model.canUse(newSelection) {
            selection = newSelection
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
                    .foregroundStyle(scale == option ? Color.accentColor : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .accessibilityIdentifier("scale.\(option.rawValue)")
            }
        }
        .background(.bar)
    }

    // MARK: - 載入

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
        switch selection {
        case .filter(let filter):
            return await library.assets(matching: filter)
        case .tag(let tagID):
            // 標籤是 App 端資料，先取全部照片再依標籤過濾。
            let all = await library.assets(matching: .all)
            return all.filter { tagStore.tagIDs(for: $0).contains(tagID) }
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
        case .journal:
            break
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
    var id: String { JournalStore.key(year: year, month: month, day: day) }
}
