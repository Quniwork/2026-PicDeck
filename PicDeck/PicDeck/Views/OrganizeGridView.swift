import SwiftUI
import Photos

/// 整理分頁專屬的「柵欄 / 網格模式」
/// 支援手指滑動連選整排照片，勾選狀態維持在右下角，
/// 並提供批次「標籤、相簿、喜愛、保留、刪除」快速整理功能。
struct OrganizeGridView: View {
    let assets: [PHAsset]
    @Binding var selectedIDs: Set<String>
    let onToggleSelect: (PHAsset) -> Void
    let onToggleSelectAll: () -> Void
    let onBatchKeep: () -> Void
    let onBatchDelete: () -> Void
    let onBatchFavorite: () -> Void
    let onBatchTags: () -> Void
    let onBatchAlbums: () -> Void
    let onOpenAsset: (PHAsset) -> Void
    let isFavorite: (PHAsset) -> Bool

    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var tagStore: TagStore
    @EnvironmentObject private var organized: OrganizedStore
    @EnvironmentObject private var model: AppModel

    private enum QuickMode {
        case tags
        case albums
    }

    @State private var quickMode: QuickMode?
    @State private var columnsCount: Int = 3

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 2), count: columnsCount)
    }

    private var selectedAssets: [PHAsset] {
        assets.filter { selectedIDs.contains($0.localIdentifier) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 上方狀態與全選列
            topSubBar

            // 中間網格
            if assets.isEmpty {
                emptyPlaceholder
            } else {
                gridContent
            }

            // 快速標籤 / 相簿列（仿單張照片檢視，水平展開不跳出彈窗）
            quickChipsBar

            // 下方批次操作列
            batchActionBar
        }
        .background(Color(.systemBackground))
        .onChange(of: selectedIDs) { _, newIDs in
            if newIDs.isEmpty {
                quickMode = nil
            }
        }
    }

    @ViewBuilder
    private var quickChipsBar: some View {
        let targets = selectedAssets
        if let mode = quickMode, !targets.isEmpty {
            QuickAssetChipsBar(
                mode: mode == .tags ? .tags : .albums,
                assets: targets,
                onManage: {
                    if mode == .tags {
                        onBatchTags()
                    } else {
                        onBatchAlbums()
                    }
                }
            )
            .padding(.top, 8)
            .padding(.bottom, 6)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - 上方狀態列

    private var unorganizedCount: Int {
        assets.filter { asset in
            !organized.isOrganized(asset) && !model.trashedAssetIDs.contains(asset.localIdentifier)
        }.count
    }

    private var topSubBar: some View {
        HStack {
            Text(selectedIDs.isEmpty ? "共 \(unorganizedCount) 張未整理" : "已選取 \(selectedIDs.count) / \(assets.count) 張")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(selectedIDs.isEmpty ? .secondary : Color.accentColor)

            Spacer()

            Button {
                onToggleSelectAll()
            } label: {
                Text(selectedIDs.count == assets.count && !assets.isEmpty ? "取消全選" : "全選")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.12), in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(assets.isEmpty)
        }
        .padding(.horizontal, PageMetrics.edge)
        .padding(.vertical, 8)
    }

    // MARK: - 網格內容

    private var gridContent: some View {
        GeometryReader { proxy in
            let safeColumns = max(columnsCount, 1)
            let cellWidth = max(1, (proxy.size.width - CGFloat(safeColumns - 1) * 2) / CGFloat(safeColumns))

            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(assets, id: \.localIdentifier) { asset in
                        let tagCount = tagStore.tagIDs(for: asset).count
                        let albumCount = library.albumIDs(for: asset).count
                        let favorite = isFavorite(asset)
                        let isTrashed = model.trashedAssetIDs.contains(asset.localIdentifier)
                        let isKept = organized.isOrganized(asset)

                        SelectableThumbnail(
                            asset: asset,
                            size: cellWidth,
                            isSelecting: true,
                            isSelected: selectedIDs.contains(asset.localIdentifier),
                            onToggle: { onToggleSelect(asset) },
                            fitsAspect: false,
                            onOpen: { onOpenAsset(asset) }
                        )
                        // #1 Top-Left: 愛心 (Favorite)
                        .overlay(alignment: .topLeading) {
                            if favorite {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.pink)
                                    .padding(4)
                                    .background(.black.opacity(0.55), in: Circle())
                                    .padding(4)
                                    .allowsHitTesting(false)
                            }
                        }
                        // #2 Top-Right: 已保留 / 待刪除 狀態徽章
                        .overlay(alignment: .topTrailing) {
                            if isTrashed {
                                HStack(spacing: 2) {
                                    Image(systemName: "trash.fill")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(.red)
                                    Text("待刪除")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                .padding(.horizontal, 5)
                                .padding(.vertical, 3)
                                .background(.black.opacity(0.65), in: Capsule())
                                .padding(4)
                                .allowsHitTesting(false)
                            } else if isKept {
                                HStack(spacing: 2) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(.green)
                                    Text("已保留")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                .padding(.horizontal, 5)
                                .padding(.vertical, 3)
                                .background(.black.opacity(0.65), in: Capsule())
                                .padding(4)
                                .allowsHitTesting(false)
                            }
                        }
                        // #3 Bottom-Left: 標籤與相簿 icon 搭配數字
                        .overlay(alignment: .bottomLeading) {
                            if tagCount > 0 || albumCount > 0 {
                                HStack(spacing: 4) {
                                    if tagCount > 0 {
                                        HStack(spacing: 2) {
                                            Image(systemName: "tag.fill")
                                                .font(.system(size: 9))
                                            Text("\(tagCount)")
                                                .font(.system(size: 9, weight: .bold))
                                        }
                                    }
                                    if albumCount > 0 {
                                        HStack(spacing: 2) {
                                            Image(systemName: "rectangle.stack.fill")
                                                .font(.system(size: 9))
                                            Text("\(albumCount)")
                                                .font(.system(size: 9, weight: .bold))
                                        }
                                    }
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 3)
                                .background(.black.opacity(0.65), in: Capsule())
                                .padding(.leading, 4)
                                .padding(.bottom, 6.5)
                                .allowsHitTesting(false)
                            }
                        }
                    }
                }
                .gridSwipeToSelect(
                    isSelecting: true,
                    columns: safeColumns,
                    spacing: 2,
                    topInset: 0,
                    assetCount: assets.count,
                    isSelected: { idx in
                        guard idx >= 0, idx < assets.count else { return false }
                        return selectedIDs.contains(assets[idx].localIdentifier)
                    },
                    onSelect: { idx, shouldSelect in
                        guard idx >= 0, idx < assets.count else { return }
                        let id = assets[idx].localIdentifier
                        if shouldSelect {
                            selectedIDs.insert(id)
                        } else {
                            selectedIDs.remove(id)
                        }
                    }
                )
                .padding(.bottom, 24)
            }
            .softScrollEdges()
        }
    }

    // MARK: - 空白狀態

    private var emptyPlaceholder: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.green)
            Text("太棒了！")
                .font(.title2.weight(.bold))
            Text("這個分類的照片已經全部整理完成了")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 下方批次操作列

    private var tagsButtonKey: LocalizedStringKey {
        let targets = assets.filter { selectedIDs.contains($0.localIdentifier) }
        if targets.count == 1, let first = targets.first {
            let count = tagStore.tagIDs(for: first).count
            return count == 0 ? "標籤" : "標籤(\(count))"
        }
        return "標籤"
    }

    private var albumsButtonKey: LocalizedStringKey {
        let targets = assets.filter { selectedIDs.contains($0.localIdentifier) }
        if targets.count == 1, let first = targets.first {
            let count = library.albumIDs(for: first).count
            return count == 0 ? "相簿" : "相簿(\(count))"
        }
        return "相簿"
    }

    private var batchActionBar: some View {
        let hasSelection = !selectedIDs.isEmpty
        let targets = assets.filter { selectedIDs.contains($0.localIdentifier) }
        let allFav = hasSelection && targets.allSatisfy { isFavorite($0) }
        let allKept = hasSelection && targets.allSatisfy { organized.isOrganized($0) }

        return ActionBarRow(forceHorizontal: true) {
            ActionBarButton(
                key: tagsButtonKey,
                icon: "tag",
                id: "grid.tags",
                isActive: quickMode == .tags,
                tint: .primary
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                    quickMode = (quickMode == .tags) ? nil : .tags
                }
            }
            Spacer(minLength: 4)
            ActionBarButton(
                key: albumsButtonKey,
                icon: "rectangle.stack.badge.plus",
                id: "grid.albums",
                isActive: quickMode == .albums,
                tint: .primary
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                    quickMode = (quickMode == .albums) ? nil : .albums
                }
            }
            Spacer(minLength: 4)
            ActionBarButton(
                key: allFav ? "取消喜愛" : "喜愛",
                icon: allFav ? "heart.slash" : "heart",
                id: "grid.favorite",
                tint: .primary
            ) {
                onBatchFavorite()
            }
            Spacer(minLength: 4)
            ActionBarButton(
                key: allKept ? "取消保留" : "保留",
                icon: allKept ? "checkmark.circle.badge.xmark" : "checkmark",
                id: "grid.keep",
                isActive: allKept,
                tint: .primary
            ) {
                onBatchKeep()
            }
            Spacer(minLength: 4)
            ActionBarButton(
                key: "刪除",
                icon: "xmark",
                id: "grid.delete",
                isDestructive: true,
                tint: .primary
            ) {
                onBatchDelete()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .floatingGlass(in: RoundedRectangle(cornerRadius: 26, style: .continuous), interactive: true)
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .disabled(!hasSelection)
        .opacity(hasSelection ? 1.0 : 0.45)
    }
}
