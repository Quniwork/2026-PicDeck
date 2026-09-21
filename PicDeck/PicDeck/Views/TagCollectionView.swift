import SwiftUI
import Photos

/// 首頁釘選的標籤點進來的畫面，當成一個收藏看。
///
/// - 右上角切換顯示模式：單張（大圖加備註加標籤，一張一張往下）或柵欄（縮圖格狀）。
/// - 上面的小標籤是這些照片「同時帶的其他標籤」，例如收藏 #美食，照片有 #燒肉 才會出現 #燒肉；
///   點一下就是二次篩選，可以多選。
/// - 柵欄點縮圖會彈出視窗，格式跟單張一樣，可以左右滑看上一則、下一則。
struct TagCollectionView: View {
    let tag: PhotoTag

    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var tagStore: TagStore
    @EnvironmentObject private var noteStore: NoteStore

    enum DisplayMode: String { case single, grid }

    @AppStorage("picdeck.collectionMode") private var modeRaw = DisplayMode.single.rawValue
    @State private var assets: [PHAsset] = []
    @State private var selectedSubTags: Set<UUID> = []
    @State private var search = ""
    @State private var editingAsset: PHAsset?
    @State private var pager: PagerTarget?

    private struct PagerTarget: Identifiable {
        let startID: String
        var id: String { startID }
    }

    private var mode: DisplayMode { DisplayMode(rawValue: modeRaw) ?? .single }
    private var subTags: [PhotoTag] { tagStore.coTags(of: tag.id) }
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    /// 選了幾個二次標籤就要同時符合（交集），再套搜尋字。
    private var visible: [PHAsset] {
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
        return assets.filter { asset in
            let ids = Set(tagStore.tags(for: asset).map(\.id))
            guard selectedSubTags.isSubset(of: ids) else { return false }
            guard !query.isEmpty else { return true }
            return noteStore.note(for: asset)?.text.localizedCaseInsensitiveContains(query) == true
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if !subTags.isEmpty { filterChips }

                if visible.isEmpty {
                    Text("Nothing matches.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if mode == .single {
                    LazyVStack(spacing: 14) {
                        ForEach(visible, id: \.localIdentifier) { asset in
                            CollectionCard(asset: asset)
                                .onTapGesture { editingAsset = asset }
                                .accessibilityElement(children: .combine)
                                .accessibilityAddTraits(.isButton)
                                .accessibilityIdentifier("collection.item")
                        }
                    }
                    .padding(.horizontal, 16)
                } else {
                    LazyVGrid(columns: gridColumns, spacing: 2) {
                        ForEach(visible, id: \.localIdentifier) { asset in
                            AssetThumbnail(asset: asset, size: 200, showsDuration: false, showsFavorite: true)
                                .onTapGesture { pager = PagerTarget(startID: asset.localIdentifier) }
                                .accessibilityIdentifier("collection.cell")
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(tag.name)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $search, prompt: Text("Search notes"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    modeRaw = (mode == .single ? DisplayMode.grid : DisplayMode.single).rawValue
                } label: {
                    Image(systemName: mode == .single ? "square.grid.2x2" : "rectangle.grid.1x2")
                }
                .accessibilityLabel(Text(mode == .single ? "Grid view" : "Single view"))
                .accessibilityIdentifier("collection.mode")
            }
        }
        .task(id: tagStore.assignments.count) { reload() }
        .sheet(item: $editingAsset) { asset in
            NoteEditorView(asset: asset)
        }
        .sheet(item: $pager) { target in
            CollectionPager(assets: visible, startID: target.startID)
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: String(localized: "All"), symbol: nil, isOn: selectedSubTags.isEmpty)
                    .onTapGesture { selectedSubTags.removeAll() }
                    .accessibilityIdentifier("collection.chip.all")
                ForEach(subTags) { sub in
                    chip(title: sub.name, symbol: sub.symbol, isOn: selectedSubTags.contains(sub.id))
                        .onTapGesture {
                            if selectedSubTags.contains(sub.id) { selectedSubTags.remove(sub.id) }
                            else { selectedSubTags.insert(sub.id) }
                        }
                        .accessibilityIdentifier("collection.chip")
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func chip(title: String, symbol: String?, isOn: Bool) -> some View {
        HStack(spacing: 4) {
            if let symbol { IconLabel(raw: symbol, size: 13) }
            Text(title).font(.subheadline.weight(.medium))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .foregroundStyle(isOn ? Color.white : Color.primary)
        .background(isOn ? Color.accentColor : Color(.secondarySystemFill), in: Capsule())
        .contentShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
    }

    private func reload() {
        let found = library.assets(withIDs: tagStore.assetIDs(withTag: tag.id))
        assets = found.sorted { ($0.creationDate ?? .distantPast) > ($1.creationDate ?? .distantPast) }
        // 標籤被拿掉之後，篩選裡不存在的就丟掉，免得一直空。
        selectedSubTags = selectedSubTags.intersection(Set(subTags.map(\.id)))
    }
}

/// 一則收藏：大圖、備註、標籤。單張顯示與柵欄彈窗共用。
struct CollectionCard: View {
    let asset: PHAsset

    @EnvironmentObject private var tagStore: TagStore
    @EnvironmentObject private var noteStore: NoteStore
    @State private var image: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Rectangle().fill(Color(.tertiarySystemFill))
                if let image {
                    Image(uiImage: image).resizable().scaledToFit()
                } else {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(image.map { $0.size.width / max($0.size.height, 1) } ?? 1, contentMode: .fit)
            // 直的截圖不要撐滿整個螢幕，備註與標籤才看得到。
            .frame(maxHeight: 440)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            TagChipsRow(tags: tagStore.tags(for: asset))

            if let note = noteStore.note(for: asset), !note.text.isEmpty {
                Text(note.text)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("Add a short note")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .contentShape(Rectangle())
        .task(id: asset.localIdentifier) {
            image = await ThumbnailLoader.shared.image(for: asset, size: 900)
        }
    }
}

/// 柵欄點開的彈窗：一則一則的收藏，可以左右滑看上一則、下一則。點備註區可以編輯。
struct CollectionPager: View {
    let assets: [PHAsset]
    @State var currentID: String

    @Environment(\.dismiss) private var dismiss
    @State private var editingAsset: PHAsset?

    init(assets: [PHAsset], startID: String) {
        self.assets = assets
        _currentID = State(initialValue: startID)
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $currentID) {
                ForEach(assets, id: \.localIdentifier) { asset in
                    ScrollView {
                        CollectionCard(asset: asset)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .onTapGesture { editingAsset = asset }
                    }
                    .tag(asset.localIdentifier)
                    .accessibilityIdentifier("collection.page")
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                        .accessibilityLabel(Text("Close"))
                        .accessibilityIdentifier("collection.pager.close")
                }
            }
            .sheet(item: $editingAsset) { NoteEditorView(asset: $0) }
        }
    }

    private var title: String {
        guard let index = assets.firstIndex(where: { $0.localIdentifier == currentID }) else { return "" }
        return "\(index + 1) / \(assets.count)"
    }
}
