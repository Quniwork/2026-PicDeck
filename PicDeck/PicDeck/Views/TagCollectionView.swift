import SwiftUI
import Photos

/// 選集裡點標籤進來的頁面，當成一個收藏看。
///
/// - 單張：一張照片占滿整個畫面，上下滑動換下一張。左上角回上一層、右上角篩選選單（顯示方式、標籤），
///   有備註的話備註浮在左下角。
/// - 柵欄：3:4 直式的縮圖格狀，右上角選單多一個「顯示方式選項」（放大縮小）。
/// - 右下角固定一顆搜尋鈕，打開跟系統相簿一樣的搜尋畫面：標籤快選、最近搜尋、搜尋列。
/// - 點照片打開詳細資訊（只有照片與備註，沒有下面那排功能按鈕）。
struct TagCollectionView: View {
    let tag: PhotoTag

    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var tagStore: TagStore
    @EnvironmentObject private var noteStore: NoteStore
    @EnvironmentObject private var model: AppModel

    enum DisplayMode: String { case single, grid }

    @AppStorage("picdeck.collectionMode") private var modeRaw = DisplayMode.single.rawValue
    @State private var assets: [PHAsset] = []
    @State private var selectedSubTags: Set<UUID> = []
    @State private var search = ""
    @State private var sortsByAdded = false
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

    private var mode: DisplayMode { DisplayMode(rawValue: modeRaw) ?? .single }
    private var subTags: [PhotoTag] { tagStore.coTags(of: tag.id) }

    /// 選了幾個標籤就要同時符合（交集），再套搜尋字（備註與標籤名稱）。
    private var visible: [PHAsset] {
        let filtered = assets.filter(matches)
        guard sortsByAdded, !addedRanks.isEmpty else { return filtered }
        return filtered.sorted { (addedRanks[$0.localIdentifier] ?? .min) > (addedRanks[$1.localIdentifier] ?? .min) }
    }

    private func matches(_ asset: PHAsset) -> Bool {
        let ids = Set(tagStore.tags(for: asset).map(\.id))
        guard selectedSubTags.isSubset(of: ids) else { return false }
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

            // 右下角固定的搜尋鈕。
            GlassCircleButton { showSearch = true } label: {
                Image(systemName: "magnifyingglass")
            }
            .frame(width: 52, height: 52)
            .padding(.trailing, 16)
            .padding(.bottom, 24)
            .accessibilityLabel(Text("Search"))
            .accessibilityIdentifier("collection.search")
        }
        .background(mode == .single ? Color.black : Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        // 內容延伸到導覽列後面，返回鈕與選單浮在照片上。
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { optionsMenu }
        }
        .task(id: tagStore.assignments.count) { reload() }
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
            PhotoDetailView(assets: visible, startID: target.startID, showsActions: false)
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

    // MARK: - 單張

    private var singleContent: some View {
        GeometryReader { proxy in
            let pageHeight = proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
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

    /// 左下角的備註：固定在畫面上，內容跟著目前看的那一張換；沒寫備註就不顯示。
    @ViewBuilder
    private var currentNote: some View {
        let id = currentPageID ?? visible.first?.localIdentifier
        if mode == .single, let asset = visible.first(where: { $0.localIdentifier == id }),
           let text = noteText(for: asset) {
            Button { editingAsset = asset } label: {
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .floatingGlass(in: RoundedRectangle(cornerRadius: 18, style: .continuous), interactive: true)
            }
            .buttonStyle(.plain)
            .padding(.leading, PageMetrics.edge)
            .padding(.trailing, 84)
            .padding(.bottom, 28)
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

    // MARK: - 右上角選單

    /// 顯示方式、標籤（篩選這個標籤裡同時帶有的其他標籤），柵欄還有顯示方式選項。
    private var optionsMenu: some View {
        Menu {
            PhotoSortMenuSection(sortsByAdded: $sortsByAdded)
            Divider()

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

            Section("顯示方式") {
                Toggle(isOn: Binding(get: { mode == .single }, set: { _ in modeRaw = DisplayMode.single.rawValue })) {
                    Label("單圖檢視", systemImage: "rectangle.grid.1x2")
                }
                Toggle(isOn: Binding(get: { mode == .grid }, set: { _ in modeRaw = DisplayMode.grid.rawValue })) {
                    Label("網格檢視", systemImage: "square.grid.2x2")
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
            ResetFiltersButton(isActive: !selectedSubTags.isEmpty || !search.isEmpty || sortsByAdded) {
                selectedSubTags.removeAll()
                search = ""
                sortsByAdded = false
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .filterIndicator(isActive: !selectedSubTags.isEmpty || !search.isEmpty || sortsByAdded) {
                    selectedSubTags.removeAll()
                    search = ""
                    sortsByAdded = false
                }
        }
        .accessibilityLabel(Text("Filter"))
        .accessibilityIdentifier("collection.options")
    }

    private func reload() {
        let found = library.assets(withIDs: tagStore.assetIDs(withTag: tag.id))
        assets = found.sorted { ($0.creationDate ?? .distantPast) > ($1.creationDate ?? .distantPast) }
        // 標籤被拿掉之後，篩選裡不存在的就丟掉，免得一直空。
        selectedSubTags = selectedSubTags.intersection(Set(subTags.map(\.id)))
    }
}

/// 滿版照片：後面是同一張照片放大模糊當背景，前面完整顯示，不裁掉。
struct FullBleedPhoto: View {
    let asset: PHAsset
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            Color.black
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
                ProgressView().tint(.white)
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
