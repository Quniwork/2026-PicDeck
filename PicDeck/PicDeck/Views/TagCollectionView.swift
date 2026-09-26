import SwiftUI
import Photos

/// 選集裡點標籤進來的頁面，當成一個收藏看。
///
/// - 單張：一張照片占滿整個畫面，上下滑動換下一張。頁首可回到標籤列表、切換同層標籤與檢視選項，
///   有備註的話備註浮在左下角。
/// - 柵欄：3:4 直式的縮圖格狀，右上角選單多一個「顯示方式選項」（放大縮小）。
/// - 右下角固定一顆搜尋鈕，打開半屏搜尋頁：標題、最新項目、固定在搜尋列上方的標籤與關閉按鈕。
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
        var assets: [PHAsset]? = nil
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
                        .ignoresSafeArea(edges: .top)
                } else {
                    gridContent
                        .ignoresSafeArea(edges: .top)
                }
            }

            // 左下角的備註。
            currentNote
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

            // 右下角固定的搜尋鈕，與左下角標籤的垂直中心對齊。
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
        .borderlessHeaderScrim()
        .overlay(alignment: .top) { headerControls }
        .toolbar(.hidden, for: .tabBar)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
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
            PhotoDetailView(assets: target.assets ?? visible, startID: target.startID)
                .zoomDestination(id: target.startID, in: photoZoom)
        }
        .sheet(item: $editingAsset) { NoteEditorView(asset: $0) }
        .sheet(isPresented: $showSearch) {
            CollectionSearchView { asset, results in
                showSearch = false
                viewer = ViewerTarget(startID: asset.localIdentifier, assets: results)
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
                            .accessibilityIdentifier("collection.tag")
                        }
                    }
                }
            }
            .padding(.leading, PageMetrics.edge)
            .padding(.trailing, 72)
            .padding(.bottom, 25)
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

    private var headerControls: some View {
        ZStack {
            tagChipMenu
                .frame(maxWidth: 170)

            HStack {
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

                Spacer(minLength: 0)

                HStack(spacing: 10) {
                    modeToggleButton
                    optionsMenu
                }
            }
        }
        .padding(.horizontal, PageMetrics.edge)
        .padding(.top, 8)
    }

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
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
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

/// 半屏搜尋涵蓋所有已標籤照片，最新項目依拍攝時間排序；標籤與搜尋列固定在底部。
/// 搜尋文字與標籤篩選只作用於搜尋頁；符合的字詞以系統藍色標示。
struct CollectionSearchView: View {
    let onOpen: (PHAsset, [PHAsset]) -> Void

    @EnvironmentObject private var noteStore: NoteStore
    @EnvironmentObject private var tagStore: TagStore
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool
    @State private var query = ""
    @State private var selectedTags: Set<UUID> = []
    @State private var allTaggedAssets: [PHAsset] = []
    @State private var isLoading = true

    private var matchingResults: [PHAsset] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if needle.isEmpty, selectedTags.isEmpty { return allTaggedAssets }
        let tagNames = Dictionary(uniqueKeysWithValues: tagStore.tags.map { ($0.id, $0.name) })
        return allTaggedAssets.filter { asset in
            let ids = tagStore.tagIDs(for: asset)
            guard selectedTags.isSubset(of: ids) else { return false }
            guard !needle.isEmpty else { return true }
            if noteStore.note(for: asset)?.text.localizedCaseInsensitiveContains(needle) == true { return true }
            return ids.contains { tagNames[$0]?.localizedCaseInsensitiveContains(needle) == true }
        }
    }

    var body: some View {
        let results = matchingResults
        VStack(spacing: 0) {
            Text("搜尋")
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, PageMetrics.edge)
                .padding(.top, 24)
                .padding(.bottom, 12)

            ScrollView {
                LazyVStack(spacing: 0) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                    } else if results.isEmpty {
                        Text("沒有符合的項目")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 18)
                    } else {
                        ForEach(results, id: \.localIdentifier) { asset in
                            latestRow(asset, in: results)
                            if asset.localIdentifier != results.last?.localIdentifier {
                                Divider()
                            }
                        }
                    }
                }
                .padding(.horizontal, PageMetrics.edge)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollDismissesKeyboard(.interactively)

            if !tagStore.tags.isEmpty {
                chips(tagStore.tags.map { ($0.id.uuidString, $0.name, selectedTags.contains($0.id)) }) { id in
                    guard let uuid = UUID(uuidString: id) else { return }
                    if selectedTags.contains(uuid) { selectedTags.remove(uuid) } else { selectedTags.insert(uuid) }
                }
                .padding(.horizontal, PageMetrics.edge)
                .padding(.top, 8)
                .padding(.bottom, 6)
            }

            searchBar
        }
        .background(Color(.systemBackground))
        .presentationDetents([.medium])
        .task { await loadTaggedAssets() }
    }

    private func loadTaggedAssets() async {
        let existingTags = Set(tagStore.tags.map(\.id))
        let ids = tagStore.assignments.values
            .filter { !existingTags.isDisjoint(with: $0.tagIDs) }
            .map(\.localIdentifier)
        let fetchTask = Task.detached(priority: .userInitiated) { () -> [PHAsset] in
            let fetched = PHAsset.fetchAssets(withLocalIdentifiers: ids, options: nil)
            var assets: [PHAsset] = []
            fetched.enumerateObjects { asset, _, _ in assets.append(asset) }
            guard !Task.isCancelled else { return [] }
            return assets.sorted {
                let left = $0.creationDate ?? .distantPast
                let right = $1.creationDate ?? .distantPast
                return left == right ? $0.localIdentifier > $1.localIdentifier : left > right
            }
        }
        let sorted = await withTaskCancellationHandler {
            await fetchTask.value
        } onCancel: {
            fetchTask.cancel()
        }
        guard !Task.isCancelled else { return }
        allTaggedAssets = sorted
        isLoading = false
    }

    private func latestRow(_ asset: PHAsset, in results: [PHAsset]) -> some View {
        let note = noteText(for: asset)
        let parts = note.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let assetTags = tagStore.tags(for: asset)
        let title = parts.first ?? assetTags.map(\.name).joined(separator: "、")
        let date = asset.creationDate.map { DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none) } ?? "照片"
        let continuation = parts.dropFirst().joined(separator: " ")
        let tagSummary = assetTags.map { "#\($0.name)" }.joined(separator: "  ")
        let subtitle = !continuation.isEmpty ? continuation : (!tagSummary.isEmpty ? tagSummary : date)

        return Button { onOpen(asset, results) } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(highlight(title.isEmpty ? date : title))
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(highlight(subtitle, defaultColor: .secondary))
                        .font(.caption)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if !continuation.isEmpty, !assetTags.isEmpty {
                        Text(assetTags.map { "#\($0.name)" }.joined(separator: "  "))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                CoverImage(assetID: asset.localIdentifier, size: 112)
                    .frame(width: 52, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("search.result")
    }

    private func noteText(for asset: PHAsset) -> String {
        noteStore.note(for: asset)?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private func highlight(_ text: String, defaultColor: Color = .primary) -> AttributedString {
        var value = AttributedString(text)
        value.foregroundColor = defaultColor
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return value }

        let source = text as NSString
        let sought = needle as NSString
        var location = 0
        while location < source.length {
            let found = source.range(of: needle,
                                    options: [.caseInsensitive, .widthInsensitive],
                                    range: NSRange(location: location, length: source.length - location))
            guard found.location != NSNotFound, found.length > 0,
                  let stringRange = Range(found, in: text),
                  let attributedRange = Range(stringRange, in: value) else { break }
            value[attributedRange].foregroundColor = .blue
            location = found.location + sought.length
        }
        return value
    }

    /// 底下的搜尋列加關閉鈕。
    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("搜尋備註與標籤", text: $query)
                    .focused($focused)
                    .submitLabel(.search)
                    .onSubmit { focused = false }
                    .accessibilityIdentifier("search.field")
            }
            .padding(.horizontal, 12)
            .frame(height: 46)
            .floatingGlass(in: Capsule())

            GlassCircleButton { dismiss() } label: {
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items, id: \.id) { item in
                    Button { action(item.id) } label: {
                        Text(highlight(item.title, defaultColor: item.isOn ? .white : .primary))
                            .font(.subheadline.weight(.medium))
                            .lineLimit(1)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(item.isOn ? Color.accentColor : Color(.secondarySystemFill), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("search.chip")
                }
            }
        }
    }
}
