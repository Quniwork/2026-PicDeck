import SwiftUI
import Photos

/// 選集裡點標籤進來的頁面，當成一個收藏看。
///
/// - 單張：一張照片占滿整個畫面，上下滑動換下一張。頁首可回到標籤列表、切換同層標籤與檢視選項，
///   有備註的話備註浮在左下角。
/// - 柵欄：3:4 直式的縮圖格狀，右上角選單多一個「顯示方式選項」（放大縮小）。
/// - 右下角固定一顆搜尋鈕，打開跟系統相簿一樣的搜尋畫面：標籤快選、最近搜尋、搜尋列。
/// - 點照片打開詳細資訊（只有照片與備註，沒有下面那排功能按鈕）。
struct TagCollectionView: View {
    let tag: PhotoTag?
    var titleOverride: String? = nil
    var customAssets: [PHAsset]? = nil

    init(tag: PhotoTag? = nil, titleOverride: String? = nil, customAssets: [PHAsset]? = nil) {
        self.tag = tag
        self.titleOverride = titleOverride
        self.customAssets = customAssets
        _selectedCollectionTagID = State(initialValue: tag?.id)
    }

    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var tagStore: TagStore
    @EnvironmentObject private var noteStore: NoteStore
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    enum DisplayMode: String { case single, grid }

    @AppStorage("picdeck.collectionMode") private var modeRaw = DisplayMode.grid.rawValue
    @State private var selectedCollectionTagID: UUID?
    @State private var assets: [PHAsset] = []
    @State private var selectedSubTags: Set<UUID> = []
    @State private var search = ""
    @State private var sortsByAdded = false
    @State private var filterType: PhotoFilter = .all
    @State private var gridFitAspect: Bool = false
    @State private var addedRanks: [String: Int] = [:]
    @State private var editingAsset: PHAsset?
    @State private var viewer: ViewerTarget?
    @State private var showSearch = false
    /// 單張模式目前看的是哪一張。
    @State private var currentPageID: String?
    /// 點照片打開檢視時，從照片的位置展開。
    @Namespace private var photoZoom

    private struct ViewerTarget: Identifiable {
        let startID: String
        var id: String { startID }
    }

    private var mode: DisplayMode { DisplayMode(rawValue: modeRaw) ?? .grid }
    private var activeTag: PhotoTag? {
        selectedCollectionTagID.flatMap { tagStore.tag(withID: $0) } ?? tag
    }
    private var subTags: [PhotoTag] {
        guard let activeTag else { return [] }
        return tagStore.coTags(of: activeTag.id)
    }

    private var displayTitle: String {
        if let titleOverride { return titleOverride }
        if let activeTag { return activeTag.name }
        return "選集"
    }

    /// 選了幾個標籤務必同時符合（交集），再套媒體類別與搜尋字。
    private var visible: [PHAsset] {
        let filtered = assets.filter(matches)
        guard sortsByAdded, !addedRanks.isEmpty else { return filtered }
        return filtered.sorted { (addedRanks[$0.localIdentifier] ?? .min) > (addedRanks[$1.localIdentifier] ?? .min) }
    }

    private func matches(_ asset: PHAsset) -> Bool {
        if let activeTag {
            let ids = Set(tagStore.tags(for: asset).map(\.id))
            guard ids.contains(activeTag.id), selectedSubTags.isSubset(of: ids) else { return false }
        }

        switch filterType {
        case .all: break
        case .photos: if asset.mediaType != .image { return false }
        case .videos: if asset.mediaType != .video { return false }
        case .screenshots: if !asset.mediaSubtypes.contains(.photoScreenshot) { return false }
        case .favorites: if !asset.isFavorite { return false }
        case .edited, .notInAlbum: break
        }

        let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }
        if noteStore.note(for: asset)?.text.localizedCaseInsensitiveContains(query) == true { return true }
        return tagStore.tags(for: asset).contains { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if visible.isEmpty {
                    emptyState
                } else if mode == .single {
                    singleContent
                } else {
                    gridContent
                }
            }

            // 左下角的備註。
            currentNote
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

            // 右下角固定的搜尋鈕（y 軸向下微調）。
            GlassCircleButton { showSearch = true } label: {
                Image(systemName: "magnifyingglass")
            }
            .frame(width: 52, height: 52)
            .padding(.trailing, 16)
            .padding(.bottom, 12)
            .accessibilityLabel(Text("Search"))
            .accessibilityIdentifier("collection.search")
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .borderlessHeaderScrim()
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .floatingGlass(in: Circle(), interactive: true)
                .accessibilityLabel(Text("Back"))
                .accessibilityIdentifier("collection.back")
            }
            ToolbarItem(placement: .principal) { tagChipMenu }
            ToolbarItem(placement: .topBarTrailing) { modeToggleButton }
            ToolbarItem(placement: .topBarTrailing) { optionsMenu }
        }
        .task(id: "\(selectedCollectionTagID?.uuidString ?? "-")-\(tagStore.assignments.count)-\(tagStore.tags.count)") { reload() }
        .task(id: sortsByAdded) {
            if sortsByAdded { addedRanks = await library.addedRanks() }
        }
        .motionAnimation(value: visible.map(\.localIdentifier))
        .motionAnimation(value: modeRaw)
        .motionAnimation(value: model.gridColumns(for: .collection))
        .pinchToZoomGrid { zoomIn in
            if mode == .grid { withMotion { model.zoom(.collection, in: zoomIn) } }
        }
        .fullScreenCover(item: $viewer) { target in
            PhotoDetailView(assets: visible, startID: target.startID)
                .zoomDestination(id: target.startID, in: photoZoom)
        }
        .sheet(item: $editingAsset) { NoteEditorView(asset: $0) }
        .sheet(isPresented: $showSearch) {
            CollectionSearchView(query: $search,
                                 selectedTags: $selectedSubTags,
                                 subTags: subTags,
                                 results: visible) { asset in
                showSearch = false
                viewer = ViewerTarget(startID: asset.localIdentifier)
            }
        }
    }

    // MARK: - 單張 (左右滑動切換，參考 IG Reels 水平切換)

    private var singleContent: some View {
        GeometryReader { proxy in
            let pageHeight = proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(visible, id: \.localIdentifier) { asset in
                        singlePage(asset)
                            .frame(width: proxy.size.width, height: pageHeight)
                            .id(asset.localIdentifier)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $currentPageID)
            .scrollTargetBehavior(.paging)
            .ignoresSafeArea()
        }
    }

    private func singlePage(_ asset: PHAsset) -> some View {
        FullBleedPhoto(asset: asset)
            .zoomSource(id: asset.localIdentifier, in: photoZoom)
            .contentShape(Rectangle())
            .onTapGesture { viewer = ViewerTarget(startID: asset.localIdentifier) }
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(asset.accessibilitySummary)
            .accessibilityValue(Text(noteText(for: asset) ?? ""))
            .accessibilityIdentifier("collection.item")
    }

    /// 左下角的備註與標籤/喜愛標示：固定在畫面上，內容跟著目前看的那一張換。
    @ViewBuilder
    private var currentNote: some View {
        let id = currentPageID ?? visible.first?.localIdentifier
        if mode == .single, let asset = visible.first(where: { $0.localIdentifier == id }) {
            let note = noteText(for: asset)
            let assetTags = tagStore.tags(for: asset)
            let isFavorite = asset.isFavorite

            VStack(alignment: .leading, spacing: 6) {
                if let note, !note.isEmpty {
                    ExpandableNoteText(text: note, color: .white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .floatingGlass(in: RoundedRectangle(cornerRadius: 18, style: .continuous), interactive: true)
                    .onTapGesture { editingAsset = asset }
                }

                if isFavorite || !assetTags.isEmpty {
                    HStack(spacing: 6) {
                        if isFavorite {
                            HStack(spacing: 4) {
                                Image(systemName: "heart.fill")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.red)
                                Text("喜愛")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.white)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .floatingGlass(in: Capsule())
                        }

                        ForEach(assetTags) { tag in
                            HStack(spacing: 4) {
                                IconLabel(raw: tag.symbol, size: 12)
                                Text(tag.name)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.white)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .floatingGlass(in: Capsule())
                        }
                    }
                }
            }
            .padding(.leading, PageMetrics.edge)
            .padding(.trailing, 72)
            .padding(.bottom, 12)
            .accessibilityIdentifier("collection.note")
        }
    }

    private func noteText(for asset: PHAsset) -> String? {
        guard let text = noteStore.note(for: asset)?.text, !text.isEmpty else { return nil }
        return text
    }

    // MARK: - 柵欄

    private var gridContent: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: model.gridColumns(for: .collection))
        return ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(visible, id: \.localIdentifier) { asset in
                    // 3:4 直式。
                    Color.clear
                        .aspectRatio(3.0 / 4.0, contentMode: .fit)
                        .overlay { CoverImage(assetID: asset.localIdentifier, size: 300) }
                        .clipped()
                        .zoomSource(id: asset.localIdentifier, in: photoZoom)
                        .contentShape(Rectangle())
                        .onTapGesture { viewer = ViewerTarget(startID: asset.localIdentifier) }
                        .accessibilityElement(children: .ignore)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityIdentifier("collection.cell")
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, PageMetrics.edge)
            .padding(.bottom, 90)
        }
    }

    private var emptyState: some View {
        AppEmptyState(icon: "photo.on.rectangle", title: String(localized: "Nothing matches."))
    }

    // MARK: - 右上角與標頭按鈕

    /// 切換單圖與柵欄檢視的快捷按鈕（44x44 獨立圓形玻璃按鈕，尺寸完全參考整理頁面）
    private var modeToggleButton: some View {
        Button {
            withMotion(.easeInOut(duration: 0.2)) {
                modeRaw = (mode == .single ? DisplayMode.grid : DisplayMode.single).rawValue
            }
        } label: {
            Image(systemName: mode == .grid ? "square.grid.3x3.fill" : "rectangle.portrait.fill")
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .floatingGlass(in: Circle(), interactive: true)
        .accessibilityLabel(mode == .single ? Text("切換至柵欄檢視") : Text("切換至單圖檢視"))
        .accessibilityIdentifier("collection.toggleMode")
    }

    /// 標頭中央的標籤選單晶片（如圖 2、3、4 所示，就算只有一個選項也保持可下拉功能）
    private var tagChipMenu: some View {
        Menu {
            if activeTag != nil {
                Section("標籤") {
                    ForEach(tagStore.tags) { sibling in
                        Button {
                            selectedCollectionTagID = sibling.id
                            selectedSubTags.removeAll()
                            currentPageID = nil
                            reload()
                        } label: {
                            HStack {
                                Label { Text(sibling.name) } icon: { TagMenuIcon(tag: sibling) }
                                if sibling.id == activeTag?.id { Image(systemName: "checkmark") }
                            }
                        }
                    }
                }
            } else {
                Text(displayTitle)
            }
        } label: {
            HStack(spacing: 4) {
                Text(displayTitle)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color.accentColor)
            }
            .padding(.horizontal, 18)
            .frame(height: 44)
            .floatingGlass(in: Capsule(), interactive: true)
        }
    }

    /// 右上角篩選與顯示選項選單（44x44 獨立圓形玻璃按鈕，完整提供「照片」Tab 的篩選功能）
    private var optionsMenu: some View {
        Menu {
            PhotoSortMenuSection(sortsByAdded: $sortsByAdded)
            Divider()

            Menu("篩選條件") {
                PhotoFilterMenuSection(isSelected: { filterType == $0 },
                                       onSelect: { filterType = $0 },
                                       showsSectionTitle: false)
            }

            if !subTags.isEmpty {
                Menu("標籤篩選") {
                    ForEach(subTags) { sub in
                        Toggle(isOn: Binding(get: { selectedSubTags.contains(sub.id) },
                                             set: { on in
                                                 if on { selectedSubTags.insert(sub.id) } else { selectedSubTags.remove(sub.id) }
                                             })) {
                            Label { Text(sub.name) } icon: { TagMenuIcon(tag: sub) }
                        }
                    }
                }
            }

            if mode == .grid {
                Menu("顯示選項") {
                    Button { model.zoom(.collection, in: true) } label: {
                        Label("放大檢視", systemImage: "plus.magnifyingglass")
                    }
                    .disabled(model.gridColumns(for: .collection) <= AppModel.gridColumnRange.lowerBound)

                    Button { model.zoom(.collection, in: false) } label: {
                        Label("縮小檢視", systemImage: "minus.magnifyingglass")
                    }
                    .disabled(model.gridColumns(for: .collection) >= AppModel.gridColumnRange.upperBound)
                }
            }

            Divider()
            ResetFiltersButton(isActive: !selectedSubTags.isEmpty || !search.isEmpty || sortsByAdded || filterType != .all) {
                selectedSubTags.removeAll()
                search = ""
                sortsByAdded = false
                filterType = .all
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 16, weight: .semibold))
                .filterIndicator(isActive: !selectedSubTags.isEmpty || !search.isEmpty || sortsByAdded || filterType != .all) {
                    selectedSubTags.removeAll()
                    search = ""
                    sortsByAdded = false
                    filterType = .all
                }
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .floatingGlass(in: Circle(), interactive: true)
        .accessibilityLabel(Text("Filter"))
        .accessibilityIdentifier("collection.options")
    }

    private func reload() {
        if let customAssets {
            assets = customAssets
        } else if let tag {
            let found = library.assets(withIDs: tagStore.assetIDs(withTag: tag.id))
            assets = found.sorted { ($0.creationDate ?? .distantPast) > ($1.creationDate ?? .distantPast) }
            selectedSubTags = selectedSubTags.intersection(Set(subTags.map(\.id)))
        } else {
            assets = []
        }
    }
}

/// 滿版照片：後面是同一張照片放大模糊當背景，前面完整顯示，不裁掉。
struct FullBleedPhoto: View {
    let asset: PHAsset
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            Color(.systemBackground)
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 40)
                    .opacity(0.55)
                    .clipped()
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
            }
        }
        .clipped()
        .task(id: asset.localIdentifier) {
            image = await ThumbnailLoader.shared.image(for: asset, size: 1400)
        }
    }
}

/// 收藏裡的搜尋，參考系統相簿：標題、標籤快選、最近搜尋，搜尋列固定在最下面，右邊一顆 ✕ 關閉。
/// 輸入的字與選的標籤會直接套用到收藏頁；有結果時在畫面上列出縮圖，點一張打開。
struct CollectionSearchView: View {
    @Binding var query: String
    @Binding var selectedTags: Set<UUID>
    let subTags: [PhotoTag]
    let results: [PHAsset]
    let onOpen: (PHAsset) -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool
    @State private var recents: [String] = Self.loadRecents()

    private static let recentsKey = "picdeck.collectionRecentSearches"

    private static func loadRecents() -> [String] {
        (UserDefaults.standard.stringArray(forKey: recentsKey)) ?? []
    }

    private var isFiltering: Bool {
        !query.trimmingCharacters(in: .whitespaces).isEmpty || !selectedTags.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Search").font(.largeTitle.weight(.bold)).padding(.top, PageMetrics.contentTopGap)

                    if !subTags.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Tags").font(.title3.weight(.bold))
                            chips(subTags.map { ($0.id.uuidString, $0.name, selectedTags.contains($0.id)) }) { id in
                                guard let uuid = UUID(uuidString: id) else { return }
                                if selectedTags.contains(uuid) { selectedTags.remove(uuid) } else { selectedTags.insert(uuid) }
                            }
                        }
                    }

                    if !recents.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Recent searches").font(.title3.weight(.bold))
                                Spacer()
                                Button("Clear") { recents = []; UserDefaults.standard.removeObject(forKey: Self.recentsKey) }
                                    .font(.subheadline.weight(.semibold))
                            }
                            chips(recents.map { ($0, $0, false) }) { text in query = text }
                        }
                    }

                    if isFiltering {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(String(format: String(localized: "%lld results"), results.count))
                                .font(.title3.weight(.bold))
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
                                ForEach(results, id: \.localIdentifier) { asset in
                                    Color.clear
                                        .aspectRatio(3.0 / 4.0, contentMode: .fit)
                                        .overlay { CoverImage(assetID: asset.localIdentifier, size: 240) }
                                        .clipped()
                                        .contentShape(Rectangle())
                                        .onTapGesture { rememberQuery(); onOpen(asset) }
                                        .accessibilityIdentifier("search.result")
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, PageMetrics.edge)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollDismissesKeyboard(.interactively)

            searchBar
        }
        .background(Color(.systemBackground))
        .presentationDetents([.large])
        .onAppear { focused = true }
    }

    /// 底下的搜尋列加關閉鈕。
    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("搜尋備註與標籤", text: $query)
                    .focused($focused)
                    .submitLabel(.search)
                    .onSubmit { rememberQuery() }
                    .accessibilityIdentifier("search.field")
                if !query.isEmpty {
                    Button { query = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }
                        .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 46)
            .floatingGlass(in: Capsule())

            GlassCircleButton { rememberQuery(); dismiss() } label: {
                Image(systemName: "xmark")
            }
            .accessibilityLabel(Text("Close"))
            .accessibilityIdentifier("search.close")
        }
        .padding(.horizontal, PageMetrics.edge)
        .padding(.vertical, 8)
    }

    /// 一排一排的小膠囊，放不下就換行。
    private func chips(_ items: [(id: String, title: String, isOn: Bool)], action: @escaping (String) -> Void) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8, alignment: .leading)], alignment: .leading, spacing: 8) {
            ForEach(items, id: \.id) { item in
                Button { action(item.id) } label: {
                    Text(item.title)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .foregroundStyle(item.isOn ? Color.white : Color.primary)
                        .background(item.isOn ? Color.accentColor : Color(.secondarySystemFill), in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("search.chip")
            }
        }
    }

    private func rememberQuery() {
        let text = query.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        recents.removeAll { $0 == text }
        recents.insert(text, at: 0)
        recents = Array(recents.prefix(8))
        UserDefaults.standard.set(recents, forKey: Self.recentsKey)
    }
}
