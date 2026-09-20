import SwiftUI
import Photos

/// 首頁釘選的標籤點進來的畫面，當成一個收藏看。
///
/// 例：釘了 #美食，裡面是存下來的餐廳截圖，每張帶著備註；
/// 上面的小標籤（#燒肉、#拉麵…）是這些照片同時帶的其他標籤，點一下就是二次篩選。
struct TagCollectionView: View {
    let tag: PhotoTag

    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var tagStore: TagStore
    @EnvironmentObject private var noteStore: NoteStore

    @State private var assets: [PHAsset] = []
    @State private var selectedSubTags: Set<UUID> = []
    @State private var search = ""
    @State private var editingAsset: PHAsset?

    private var subTags: [PhotoTag] { tagStore.coTags(of: tag.id) }

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
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(visible, id: \.localIdentifier) { asset in
                            row(asset)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 8)
        }
        .navigationTitle(tag.name)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $search, prompt: Text("Search notes"))
        .task(id: tagStore.assignments.count) { reload() }
        .sheet(item: $editingAsset) { asset in
            NoteEditorView(asset: asset)
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

    private func row(_ asset: PHAsset) -> some View {
        let others = tagStore.tags(for: asset).filter { $0.id != tag.id }
        return HStack(alignment: .top, spacing: 12) {
            AssetThumbnail(asset: asset, size: 200, showsDuration: false)
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                TagChipsRow(tags: others)
                if let note = noteStore.note(for: asset), !note.text.isEmpty {
                    Text(note.text)
                        .font(.subheadline)
                        .lineLimit(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("Add a short note")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture { editingAsset = asset }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("collection.item")
    }

    private func reload() {
        let found = library.assets(withIDs: tagStore.assetIDs(withTag: tag.id))
        assets = found.sorted { ($0.creationDate ?? .distantPast) > ($1.creationDate ?? .distantPast) }
        // 標籤被拿掉之後，篩選裡不存在的就丟掉，免得一直空。
        selectedSubTags = selectedSubTags.intersection(Set(subTags.map(\.id)))
    }
}
