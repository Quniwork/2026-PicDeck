import SwiftUI
import Photos

/// 逐張審核畫面，主要靠手勢：
/// 左滑保留、右滑回上一張（順便撤銷該張剛做的動作）、上滑加入待刪、
/// 下滑加入系統喜愛（再滑一次就移出喜愛）、雙擊放大。
/// 底下的功能列是寫日記、喜愛、標籤、相簿、刪除。保留只用手勢，沒有按鈕。
struct ReviewSessionView: View {
    @State private var bucket: OrganizeBucket
    @State private var initialMonthBucket: OrganizeBucket?
    @State private var summary: UnorganizedSummary
    @State private var showPaywall = false

    init(bucket: OrganizeBucket, initialSummary: UnorganizedSummary? = nil) {
        _bucket = State(initialValue: bucket)
        if case .month = bucket {
            _initialMonthBucket = State(initialValue: bucket)
        }
        _summary = State(initialValue: initialSummary ?? UnorganizedSummary())
    }

    /// 未整理的全部照片與截圖的識別碼，切換來源時不用重抓。
    @State private var basePool: [PHAsset] = []
    @State private var screenshotIDs: Set<String> = []
    @State private var sourceCounts: [String: Int] = [:]

    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var organized: OrganizedStore
    @EnvironmentObject private var tagStore: TagStore
    @EnvironmentObject private var journalStore: JournalStore
    @EnvironmentObject private var noteStore: NoteStore
    @Environment(\.dismiss) private var dismiss

    @State private var assets: [PHAsset] = []
    @State private var index = 0
    @State private var dragOffset: CGSize = .zero
    @State private var isLoading = true
    @State private var albums: [AlbumSummary] = []
    @State private var history: [SessionAction] = []
    @State private var banner: SessionBanner?
    @State private var showTrash = false
    /// 點了標籤或相簿之後，最底下展開的快速分類列。
    @State private var quickMode: QuickMode?
    /// 這次整理裡改過的喜愛狀態。系統照片的快照會過期，所以自己記一份最新的。
    @State private var favoriteState: [String: Bool] = [:]
    @State private var showMoreAlbums = false
    @State private var isZoomed = false
    @State private var showTagPicker = false
    @State private var showNoteEditor = false
    @State private var showJournalEditor = false
    @State private var isNoteExpanded = false
    @State private var isInspectorExpanded = false
    /// 記錄每次拖曳「起始時」inspector 是否展開，避免手勢結束時誤觸 dismiss。
    @State private var inspectorExpandedAtGestureStart = false
    /// 目前這張照片所屬的相簿名稱與 ID 清單。
    @State private var currentAlbums: [String] = []
    @State private var currentAlbumIDs: Set<String> = []

    /// 整理柵欄 / 網格模式相關狀態
    @AppStorage("review_session_is_grid_mode") private var isGridMode = false
    @State private var gridSelectedIDs: Set<String> = []
    @State private var batchSelectedAssetsForTag: [PHAsset] = []
    @State private var batchSelectedAssetsForAlbum: [PHAsset] = []
    @State private var previewAsset: PHAsset? = nil

    private var currentTags: [PhotoTag] {
        guard let currentAsset else { return [] }
        return tagStore.tags(for: currentAsset)
    }

    private enum QuickMode { case tags, albums }

    private let threshold: CGFloat = 100

    var body: some View {
        VStack(spacing: 10) {
            header
            if isGridMode {
                OrganizeGridView(
                    assets: assets,
                    selectedIDs: $gridSelectedIDs,
                    onToggleSelect: { asset in
                        let id = asset.localIdentifier
                        if gridSelectedIDs.contains(id) {
                            gridSelectedIDs.remove(id)
                        } else {
                            gridSelectedIDs.insert(id)
                        }
                    },
                    onToggleSelectAll: {
                        if gridSelectedIDs.count == assets.count {
                            gridSelectedIDs.removeAll()
                        } else {
                            gridSelectedIDs = Set(assets.map(\.localIdentifier))
                        }
                    },
                    onBatchKeep: {
                        batchKeepSelected()
                    },
                    onBatchDelete: {
                        batchDeleteSelected()
                    },
                    onBatchFavorite: {
                        batchToggleFavoriteSelected()
                    },
                    onBatchTags: {
                        let targets = selectedGridAssets
                        if !targets.isEmpty {
                            batchSelectedAssetsForTag = targets
                            showTagPicker = true
                        }
                    },
                    onBatchAlbums: {
                        let targets = selectedGridAssets
                        if !targets.isEmpty {
                            batchSelectedAssetsForAlbum = targets
                            showMoreAlbums = true
                        }
                    },
                    onOpenAsset: { asset in
                        previewAsset = asset
                    },
                    isFavorite: { isFavorite($0) }
                )
                .layoutPriority(1)
            } else {
                photoArea
                    .layoutPriority(1)

                if isInspectorExpanded, let asset = currentAsset {
                    PhotoInspectorPanelView(asset: asset) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            isInspectorExpanded = false
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 12)
                            .onEnded { value in
                                let dy = value.translation.height
                                let dx = abs(value.translation.width)
                                if dy > 40, dy > dx * 1.2 {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                        isInspectorExpanded = false
                                    }
                                }
                            }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.horizontal, 10)
                }

                quickRow
                actionBar
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: isInspectorExpanded)
        .background(Color(.systemBackground))
        // 每個動作的結果提示出現時，配一個對應的觸覺：保留與撤銷輕、喜愛與分類成功、刪除警告。
        .sensoryFeedback(trigger: banner?.id) { _, new in
            guard new != nil, let haptic = banner?.haptic else { return nil }
            switch haptic {
            case .light: return .impact(weight: .light)
            case .success: return .success
            case .warning: return .warning
            }
        }
        .navigationBarBackButtonHidden(true)
        .failureToast()
        .toolbar(.hidden, for: .tabBar)
        .task { await load() }
        .task(id: currentAsset?.localIdentifier) {
            await updateCurrentAssetAlbums()
        }
        .onChange(of: currentAsset?.localIdentifier) { _, newID in
            isNoteExpanded = false
            if let newID {
                model.setLastReviewedAssetID(newID, for: bucket.id)
            }
        }
        .sheet(isPresented: $showTagPicker, onDismiss: {
            batchSelectedAssetsForTag = []
        }) {
            let targets = !batchSelectedAssetsForTag.isEmpty ? batchSelectedAssetsForTag : (currentAsset.map { [$0] } ?? [])
            if !targets.isEmpty {
                TagPickerView(assets: targets)
            }
        }
        .sheet(isPresented: $showNoteEditor) {
            if let asset = currentAsset {
                NoteEditorView(asset: asset)
            }
        }
        .sheet(isPresented: $showJournalEditor) {
            if let asset = currentAsset {
                if let entry = journalStore.entry(for: asset) {
                    JournalEditorView(entry: entry)
                } else {
                    let date = asset.creationDate ?? Date()
                    let parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
                    JournalEditorView(year: parts.year ?? 2026, month: parts.month ?? 1, day: parts.day ?? 1, preselectedIDs: [asset.localIdentifier])
                }
            }
        }
        .sheet(isPresented: $showTrash, onDismiss: {
            Task { await load() }
        }) { PendingTrashView() }
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .sheet(isPresented: $showMoreAlbums, onDismiss: {
            batchSelectedAssetsForAlbum = []
            Task {
                albums = await library.userAlbums()
                await updateCurrentAssetAlbums()
            }
        }) {
            let targets = !batchSelectedAssetsForAlbum.isEmpty ? batchSelectedAssetsForAlbum : (currentAsset.map { [$0] } ?? [])
            if !targets.isEmpty {
                AlbumPickerView(assets: targets)
            }
        }
        .sheet(item: $previewAsset) { asset in
            PhotoDetailView(assets: assets, startID: asset.localIdentifier)
        }
        // 動作結果放在畫面正中間，比原本壓在標題下的小字明顯得多。
        .overlay(alignment: .center) {
            if let banner {
                HStack(spacing: 10) {
                    Image(systemName: banner.icon)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(banner.tint)
                    Text(banner.text)
                        .font(.headline)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
                .background(.regularMaterial, in: Capsule())
                .overlay(Capsule().stroke(Color.primary.opacity(0.08)))
                .shadow(color: .black.opacity(0.18), radius: 12, y: 4)
                .transition(.scale(scale: 0.85).combined(with: .opacity))
                .allowsHitTesting(false)
                .accessibilityIdentifier("session.banner")
            }
        }
    }

    // MARK: - 上方

    // MARK: - 上方

    /// 頁首：關閉、來源標題（螢幕正中央置中）、右上角按鈕群（網格切換與待刪除垃圾桶各自獨立，不融合）。
    private var header: some View {
        VStack(spacing: 6) {
            ZStack {
                // 中間：來源日期選單（絕對水平置中，不受兩側按鈕數量或寬度影響）
                sourceMenu
                    .frame(maxWidth: .infinity, alignment: .center)

                // 兩側按鈕
                HStack {
                    GlassCircleButton { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel(Text("關閉"))
                    .accessibilityIdentifier("session.close")

                    Spacer()

                    HStack(spacing: 12) {
                        GlassCircleButton {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isGridMode.toggle()
                                if index >= assets.count {
                                    index = max(0, assets.count - 1)
                                }
                            }
                        } label: {
                            Image(systemName: isGridMode ? "rectangle.portrait.fill" : "square.grid.3x3.fill")
                        }
                        .accessibilityLabel(Text(isGridMode ? "切換至卡片模式" : "切換至網格模式"))
                        .accessibilityIdentifier("session.modeToggle")

                        GlassCircleButton { showTrash = true } label: {
                            Image(systemName: "trash")
                        }
                        .accessibilityLabel(Text("待刪除清單"))
                        .accessibilityIdentifier("session.trash")
                        .overlay(alignment: .topTrailing) {
                            if !model.trashedAssetIDs.isEmpty {
                                Text("\(model.trashedAssetIDs.count)")
                                    .font(.system(.caption2, design: .rounded, weight: .bold))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                    .fixedSize()
                                    .padding(.horizontal, 5)
                                    .frame(minWidth: 18, minHeight: 18)
                                    .background(Color.red, in: Capsule())
                                    .offset(x: 5, y: -5)
                                    .allowsHitTesting(false)
                                    .accessibilityIdentifier("session.trash.count")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            if !isGridMode {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.bottom, 8)
    }

    private var sourceMenu: some View {
        Menu {
            bucketButton(for: .allUnorganized, count: summary.allCount)
            bucketButton(for: .unorganizedPhotos, count: summary.photoCount)
            bucketButton(for: .unorganizedVideos, count: summary.videoCount)
            bucketButton(for: .unorganizedScreenshots, count: summary.screenshotCount)

            let monthList = monthsForMenu
            if !monthList.isEmpty {
                Menu {
                    ForEach(monthList) { month in
                        let monthBucket = OrganizeBucket.month(year: month.year, month: month.month)
                        Button {
                            if model.canUse(monthBucket) {
                                switchBucket(monthBucket)
                            } else {
                                showPaywall = true
                            }
                        } label: {
                            Label {
                                Text("\(month.title)（\(month.count)）")
                            } icon: {
                                if monthBucket == bucket {
                                    Image(systemName: "checkmark")
                                } else if !model.canUse(monthBucket) {
                                    Image(systemName: "lock.fill")
                                } else {
                                    Image(systemName: "calendar")
                                }
                            }
                        }
                        .disabled(!model.canUse(monthBucket) && monthBucket != bucket)
                    }
                } label: {
                    Label {
                        Text("依月份")
                    } icon: {
                        if case .month = bucket {
                            Image(systemName: "calendar.badge.checkmark")
                        } else {
                            Image(systemName: "calendar")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(bucket.title).font(.headline)
                Image(systemName: "chevron.down").font(.caption2.weight(.bold))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 18)
            .frame(height: 44)
            .floatingGlass(in: Capsule(), interactive: true)
        }
        .accessibilityIdentifier("session.source")
    }

    private var subtitle: String {
        guard let asset = currentAsset, !assets.isEmpty else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let date = asset.creationDate.map { formatter.string(from: $0) } ?? ""
        return "\(index + 1) / \(assets.count) · \(date)"
    }

    // MARK: - 照片

    @ViewBuilder
    private var photoArea: some View {
        ZStack {
            if isLoading {
                ProgressView()
            } else if assets.isEmpty {
                AppEmptyState(icon: "checkmark.circle",
                              title: String(localized: "Nothing left here"),
                              message: String(localized: "This source is all reviewed."))
            } else if index >= assets.count {
                VStack(spacing: 16) {
                    AppEmptyState(icon: "checkmark.circle",
                                  title: String(localized: "All done"),
                                  message: String(localized: "You reached the end of this batch."))
                    if !assets.isEmpty {
                        Button {
                            withMotion { index = max(0, assets.count - 1) }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                Text("返回查看照片")
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.accentColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.accentColor.opacity(0.12), in: Capsule())
                        }
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            if value.translation.width > 50, !assets.isEmpty {
                                withMotion { index = max(0, assets.count - 1) }
                            }
                        }
                )
            } else if let asset = currentAsset {
                SessionPhotoCard(asset: asset, isZoomed: $isZoomed)
                    .overlay {
                        // 手勢滑動時的色彩遮罩回饋：左滑綠色（保留）、上滑紅色（刪除）
                        // 置於 offset/rotationEffect 之前，拖拉時遮罩完全貼合卡片並跟隨移動旋轉
                        if dragOffset.width < -20 {
                            Color.green.opacity(min(0.38, Double(-dragOffset.width / 200)))
                                .allowsHitTesting(false)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else if dragOffset.height < -20 {
                            Color.red.opacity(min(0.38, Double(-dragOffset.height / 200)))
                                .allowsHitTesting(false)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .overlay(alignment: .topLeading) {
                        VStack(alignment: .leading, spacing: 6) {
                            // #1 喜愛
                            if isFavorite(asset) {
                                Button {
                                    toggleFavoriteCurrent()
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 11))
                                            .foregroundStyle(.pink)
                                        Text(String(localized: "Favorite", defaultValue: "喜愛"))
                                            .font(.caption2.weight(.medium))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .foregroundStyle(.primary)
                                    .floatingGlass(in: Capsule(), interactive: true)
                                }
                                .buttonStyle(.plain)
                            }

                            // #2 日記
                            if journalStore.isInJournal(asset) {
                                Button {
                                    showJournalEditor = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "book.closed.fill")
                                            .font(.system(size: 11))
                                            .foregroundStyle(.white)
                                        Text("日記")
                                            .font(.caption2.weight(.medium))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .foregroundStyle(.primary)
                                    .floatingGlass(in: Capsule(), interactive: true)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(12)
                        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: isFavorite(asset))
                    }
                    .overlay(alignment: .topTrailing) {
                        // #3 狀態按鈕 (移出待刪除)
                        if model.trashedAssetIDs.contains(asset.localIdentifier) {
                            Button {
                                untrashCurrent()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.uturn.backward")
                                        .font(.system(size: 10, weight: .bold))
                                    Text(String(localized: "Remove from pending deletion", defaultValue: "移出待刪除"))
                                        .font(.caption2.weight(.bold))
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.red, in: Capsule())
                            }
                            .buttonStyle(.plain)
                            .transition(.scale.combined(with: .opacity))
                            .padding(12)
                        }
                    }
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 8) {
                            // #4 標籤 (水平單列滾動，不折行)
                            if !currentTags.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 6) {
                                        ForEach(currentTags) { tag in
                                            Button {
                                                showTagPicker = true
                                            } label: {
                                                HStack(spacing: 4) {
                                                    if !tag.symbol.isEmpty {
                                                        IconLabel(raw: tag.symbol, size: 13)
                                                    } else {
                                                        Image(systemName: "tag.fill")
                                                            .font(.system(size: 11))
                                                    }
                                                    Text(tag.name)
                                                        .font(.caption2.weight(.medium))
                                                        .lineLimit(1)
                                                }
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .foregroundStyle(.primary)
                                                .floatingGlass(in: Capsule(), interactive: true)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }

                            // #5 備註（最多顯示兩行，點擊顯示更多才展開）
                            if let noteText = noteStore.note(for: asset)?.text, !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(noteText)
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                        .lineLimit(isNoteExpanded ? nil : 2)
                                        .multilineTextAlignment(.leading)

                                    Button {
                                        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                            isNoteExpanded.toggle()
                                        }
                                    } label: {
                                        Text(isNoteExpanded ? "顯示較少" : "顯示更多")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(Color.accentColor)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(10)
                                .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }
                        .padding(12)
                        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: currentTags)
                    }
                    .offset(dragOffset)
                    .rotationEffect(dragOffset.height > 0 && dragOffset.height > abs(dragOffset.width) ? .zero : .degrees(Double(dragOffset.width / 30)))
                    .overlay(alignment: .center) { gestureHint }
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 12)
                            .onChanged { value in
                                if abs(value.translation.height) < 4, abs(value.translation.width) < 4 {
                                    inspectorExpandedAtGestureStart = isInspectorExpanded
                                }
                                dragOffset = value.translation
                            }
                            .onEnded { handleDrag($0.translation) }
                    )
                    .animation(.spring(response: 0.28, dampingFraction: 0.82), value: dragOffset)
                    .padding(.horizontal, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var gestureHint: some View {
        if dragOffset.height < -55 {
            hint("Delete", icon: "trash.fill", color: .red)
        } else if dragOffset.width < -55 {
            hint("Keep", icon: "checkmark.circle.fill", color: .green)
        } else if dragOffset.width > 55 {
            hint("Previous", icon: "arrow.left.circle.fill", color: .accentColor)
        }
    }

    private func hint(_ key: LocalizedStringKey, icon: String, color: Color) -> some View {
        Label(key, systemImage: icon)
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(color.opacity(0.9), in: Capsule())
    }

    // MARK: - 功能列

    private var tagsButtonKey: LocalizedStringKey {
        if currentTags.isEmpty {
            return "標籤"
        } else {
            return "標籤(\(currentTags.count))"
        }
    }

    private var albumsButtonKey: LocalizedStringKey {
        if currentAlbums.isEmpty {
            return "相簿"
        } else {
            return "相簿(\(currentAlbums.count))"
        }
    }

    /// 跟選取照片時的功能列同一種樣式：玻璃膠囊、小圖示加文字、間距平均。
    private var actionBar: some View {
        let favorite = currentAsset.map(isFavorite) ?? false
        let isKept = currentAsset.map { organized.isOrganized($0) } ?? false

        // 順序：資訊、標籤、相簿、喜愛（移出喜愛）、保留、刪除。
        return ActionBarRow(forceHorizontal: true) {
            barButton("資訊", icon: isInspectorExpanded ? "info.circle.fill" : "info.circle",
                      id: "session.info", isActive: isInspectorExpanded) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    isInspectorExpanded.toggle()
                }
            }
            Spacer(minLength: 4)
            barButton(tagsButtonKey, icon: "tag", id: "session.tags",
                      isActive: quickMode == .tags) {
                quickMode = (quickMode == .tags) ? nil : .tags
            }
            Spacer(minLength: 4)
            barButton(albumsButtonKey, icon: "rectangle.stack.badge.plus", id: "session.albums",
                      isActive: quickMode == .albums) {
                quickMode = (quickMode == .albums) ? nil : .albums
            }
            Spacer(minLength: 4)
            barButton(favorite ? "取消喜愛" : "喜愛",
                      icon: favorite ? "heart.slash" : "heart",
                      id: "session.favorite") {
                toggleFavoriteCurrent()
            }
            Spacer(minLength: 4)
            barButton(isKept ? "取消保留" : "保留",
                      icon: isKept ? "checkmark.circle.badge.xmark" : "checkmark",
                      id: "session.keep",
                      isActive: isKept) {
                keepCurrent()
            }
            Spacer(minLength: 4)
            barButton("刪除", icon: "xmark", id: "session.delete", isDestructive: true) {
                deleteCurrent()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .floatingGlass(in: RoundedRectangle(cornerRadius: 26, style: .continuous), interactive: true)
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .disabled(currentAsset == nil)
    }

    private func barButton(_ key: LocalizedStringKey, icon: String, id: String,
                           isActive: Bool = false, isDestructive: Bool = false,
                           badgeCount: Int? = nil,
                           action: @escaping () -> Void) -> some View {
        ActionBarButton(key: key, icon: icon, id: id, isActive: isActive,
                        isDestructive: isDestructive, badgeCount: badgeCount, action: action)
    }

    // MARK: - 快速分類列

    /// 點了標籤或相簿之後才出現：水平滑動膠囊列（圖 2、圖 3 樣式）。
    @ViewBuilder
    private var quickRow: some View {
        if let mode = quickMode, let asset = currentAsset {
            QuickAssetChipsBar(
                mode: mode == .tags ? .tags : .albums,
                asset: asset,
                assignedAlbumIDs: $currentAlbumIDs,
                onManage: {
                    if mode == .tags {
                        showTagPicker = true
                    } else {
                        showMoreAlbums = true
                    }
                }
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - 狀態

    private var currentAsset: PHAsset? {
        guard index >= 0, index < assets.count else { return nil }
        return assets[index]
    }

    // MARK: - 動作

    private func handleDrag(_ translation: CGSize) {
        dragOffset = .zero

        let vertical = translation.height
        let horizontal = translation.width

        if vertical > 100 && vertical > abs(horizontal) * 1.3 {
            // 手勢起始時 inspector 開著 → 只收起面板，不 dismiss 整理畫面
            if inspectorExpandedAtGestureStart {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    isInspectorExpanded = false
                }
            } else {
                dismiss()
            }
        } else if vertical < -threshold && abs(vertical) > abs(horizontal) * 1.3 {
            deleteCurrent()
        } else if horizontal < -threshold {
            keepCurrent()
        } else if horizontal > threshold {
            goPrevious()
        }
    }

    /// 右滑：上一張，單純返回前一張瀏覽，不做任何動作撤銷。
    private func goPrevious() {
        if index > 0 {
            withMotion { index -= 1 }
        }
    }

    /// 移出待刪除：若前一張照片原本在待刪清單，可點擊右上角膠囊移出。
    private func untrashCurrent() {
        guard let asset = currentAsset else { return }
        model.unmarkTrashed(asset.localIdentifier)
        organized.unmarkOrganized(asset)
        incrementCounts(for: asset)
        showBanner(String(localized: "Removed from pending deletion", defaultValue: "已移出待刪除"),
                   icon: "arrow.uturn.backward", tint: .secondary)
    }

    /// 保留／取消保留：標記成已整理或取消已整理。
    private func keepCurrent() {
        guard let asset = currentAsset else { return }
        if organized.isOrganized(asset) {
            organized.unmarkOrganized(asset)
            incrementCounts(for: asset)
            showBanner("已取消保留", icon: "checkmark.circle", tint: .secondary, haptic: .light)
        } else {
            guard model.hasQuotaLeft else { showPaywall = true; return }
            organized.markOrganized(asset)
            model.consumeQuota()
            decrementCounts(for: asset)
            history.append(SessionAction(assetID: asset.localIdentifier, kind: .keep))
            withMotion { index += 1 }
        }
    }

    /// 刪除：先進待刪清單，確認後才真的刪。
    private func deleteCurrent() {
        guard let asset = currentAsset, model.hasQuotaLeft else { return }
        model.markTrashed(asset.localIdentifier)
        model.consumeQuota()
        decrementCounts(for: asset)
        history.append(SessionAction(assetID: asset.localIdentifier, kind: .delete))
        showBanner(String(localized: "Marked for deletion"), icon: "trash.fill", tint: .red, haptic: .warning)
        withMotion { index += 1 }
    }

    /// 這張現在是不是喜愛。優先用這次整理裡自己記的，沒有才看系統照片。
    private func isFavorite(_ asset: PHAsset) -> Bool {
        if let known = favoriteState[asset.localIdentifier] { return known }
        return (library.asset(withID: asset.localIdentifier) ?? asset).isFavorite
    }

    /// 喜愛與移出喜愛：不跳到下一張，同一張再做一次就是反過來。
    private func toggleFavoriteCurrent() {
        guard let asset = currentAsset else { return }
        let now = !isFavorite(asset)
        favoriteState[asset.localIdentifier] = now
        if now {
            organized.markOrganized(asset)
        }
        Task {
            await library.attempt(String(localized: "Couldn't change favorites")) {
                try await library.setFavorite(asset, to: now)
            }
        }
        showBanner(now ? String(localized: "Added to favorites")
                       : String(localized: "Removed from favorites"),
                   icon: now ? "heart.fill" : "heart.slash.fill",
                   tint: now ? .pink : .secondary,
                   haptic: now ? .success : .light)
    }

    /// 切換標籤：若已加入則移除，未加入則加入。留在當前照片，不自動跳下一張。
    private func toggleTag(_ tag: PhotoTag) {
        guard let asset = currentAsset else { return }
        let hasTag = tagStore.tagIDs(for: asset).contains(tag.id)
        if hasTag {
            tagStore.removeTag(tag.id, from: [asset])
            showBanner("已移除標籤 \(tag.name)",
                       icon: "tag.slash.fill", tint: .secondary, haptic: .light)
        } else {
            tagStore.addTag(tag.id, to: [asset])
            organized.markOrganized(asset)
            showBanner("已加入標籤 \(tag.name)",
                       icon: "tag.fill", tint: .accentColor, haptic: .success)
        }
    }

    /// 切換相簿：若已加入則移出，未加入則加入。留在當前照片，不自動跳下一張。
    private func toggleAlbum(_ album: AlbumSummary) {
        guard let asset = currentAsset else { return }
        let inAlbum = currentAlbumIDs.contains(album.id)
        if inAlbum {
            currentAlbumIDs.remove(album.id)
            currentAlbums.removeAll(where: { $0 == album.title })
            Task {
                await library.attempt(String(localized: "Couldn't remove from the album", defaultValue: "無法從相簿移除")) {
                    try await library.removeAssets([asset], fromAlbumWithID: album.id)
                }
                await updateCurrentAssetAlbums()
            }
            showBanner("已從相簿 \(album.title) 移除",
                       icon: "rectangle.stack.badge.minus", tint: .secondary, haptic: .light)
        } else {
            currentAlbumIDs.insert(album.id)
            if !currentAlbums.contains(album.title) {
                currentAlbums.append(album.title)
            }
            organized.markOrganized(asset)
            Task {
                await library.attempt(String(localized: "Couldn't add to the album", defaultValue: "無法加入相簿")) {
                    try await library.addAsset(asset, toAlbumWithID: album.id)
                }
                await updateCurrentAssetAlbums()
            }
            showBanner("已加入相簿 \(album.title)",
                       icon: "rectangle.stack.fill", tint: .accentColor, haptic: .success)
        }
    }

    private func decrementCounts(for asset: PHAsset) {
        summary.allCount = max(0, summary.allCount - 1)
        if asset.mediaType == .image {
            summary.photoCount = max(0, summary.photoCount - 1)
        } else if asset.mediaType == .video {
            summary.videoCount = max(0, summary.videoCount - 1)
        }
        if screenshotIDs.contains(asset.localIdentifier) {
            summary.screenshotCount = max(0, summary.screenshotCount - 1)
        }
        if let date = asset.creationDate {
            let parts = Calendar.current.dateComponents([.year, .month], from: date)
            if let y = parts.year, let m = parts.month {
                if let idx = summary.months.firstIndex(where: { $0.year == y && $0.month == m }) {
                    let old = summary.months[idx]
                    summary.months[idx] = UnorganizedSummary.MonthBucket(
                        id: old.id, year: old.year, month: old.month,
                        title: old.title, count: max(0, old.count - 1), tint: old.tint
                    )
                }
            }
        }
    }

    private func incrementCounts(for asset: PHAsset) {
        summary.allCount += 1
        if asset.mediaType == .image {
            summary.photoCount += 1
        } else if asset.mediaType == .video {
            summary.videoCount += 1
        }
        if screenshotIDs.contains(asset.localIdentifier) {
            summary.screenshotCount += 1
        }
        if let date = asset.creationDate {
            let parts = Calendar.current.dateComponents([.year, .month], from: date)
            if let y = parts.year, let m = parts.month {
                if let idx = summary.months.firstIndex(where: { $0.year == y && $0.month == m }) {
                    let old = summary.months[idx]
                    summary.months[idx] = UnorganizedSummary.MonthBucket(
                        id: old.id, year: old.year, month: old.month,
                        title: old.title, count: old.count + 1, tint: old.tint
                    )
                }
            }
        }
    }

    private func showBanner(_ text: String, icon: String, tint: Color,
                            haptic: SessionBanner.Haptic = .light) {
        let current = SessionBanner(text: text, icon: icon, tint: tint, haptic: haptic)
        withMotion(.spring(response: 0.3, dampingFraction: 0.75)) { banner = current }
        Task {
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            // 連續兩個動作時，只有最後一個提示會自己收起來。
            if banner?.id == current.id {
                withMotion(.easeOut(duration: 0.2)) { banner = nil }
            }
        }
    }

    // MARK: - 載入

    private func load() async {
        isLoading = true
        defer { isLoading = false }

        albums = await library.userAlbums()

        let all = await library.assets(matching: .all)
        await organized.refresh(allAssets: all)
        let trashed = Set(model.trashedAssetIDs)
        basePool = all.filter { !organized.isOrganized($0) && !trashed.contains($0.localIdentifier) }
        screenshotIDs = Set(await library.assets(matching: .screenshots).map(\.localIdentifier))

        let builtSummary = await UnorganizedSummary.build(from: basePool)
        summary = builtSummary

        var counts: [String: Int] = [
            OrganizeBucket.allUnorganized.id: builtSummary.allCount,
            OrganizeBucket.unorganizedPhotos.id: builtSummary.photoCount,
            OrganizeBucket.unorganizedVideos.id: builtSummary.videoCount,
            OrganizeBucket.unorganizedScreenshots.id: builtSummary.screenshotCount,
        ]
        for m in builtSummary.months {
            counts["\(m.year)-\(m.month)"] = m.count
        }
        if case .month(let year, let month) = bucket {
            counts[bucket.id] = counts[bucket.id] ?? basePool.filter { asset in
                guard let date = asset.creationDate else { return false }
                let parts = Calendar.current.dateComponents([.year, .month], from: date)
                return parts.year == year && parts.month == month
            }.count
        }
        if let initial = initialMonthBucket, case .month(let year, let month) = initial {
            counts[initial.id] = counts[initial.id] ?? basePool.filter { asset in
                guard let date = asset.creationDate else { return false }
                let parts = Calendar.current.dateComponents([.year, .month], from: date)
                return parts.year == year && parts.month == month
            }.count
        }
        sourceCounts = counts
        applyBucket()
        await updateCurrentAssetAlbums()
    }

    /// 依目前的來源挑出要整理的照片，排除已整理與待刪除，並接續進度。
    private func applyBucket() {
        let trashed = Set(model.trashedAssetIDs)
        var pool = basePool.filter { !organized.isOrganized($0) && !trashed.contains($0.localIdentifier) }
        switch bucket {
        case .allUnorganized:
            break
        case .unorganizedPhotos:
            pool = pool.filter { $0.mediaType == .image }
        case .unorganizedVideos:
            pool = pool.filter { $0.mediaType == .video }
        case .unorganizedScreenshots:
            pool = pool.filter { screenshotIDs.contains($0.localIdentifier) }
        case .month(let year, let month):
            let calendar = Calendar.current
            pool = pool.filter { asset in
                guard let date = asset.creationDate else { return false }
                let parts = calendar.dateComponents([.year, .month], from: date)
                return parts.year == year && parts.month == month
            }
        }
        assets = pool
        sourceCounts[bucket.id] = pool.count
        if let bookmark = model.lastReviewedAssetIDs[bucket.id],
           let found = pool.firstIndex(where: { $0.localIdentifier == bookmark }) {
            index = found
        } else {
            index = 0
        }
        history.removeAll()
    }

    private var monthsForMenu: [UnorganizedSummary.MonthBucket] {
        var list = summary.months
        if case .month(let year, let month) = bucket {
            if !list.contains(where: { $0.year == year && $0.month == month }) {
                list.insert(UnorganizedSummary.MonthBucket(
                    id: "\(year)-\(month)",
                    year: year,
                    month: month,
                    title: DateTitle.month(year: year, month: month),
                    count: sourceCounts[bucket.id] ?? assets.count,
                    tint: .blue
                ), at: 0)
            }
        }
        return list
    }

    private func bucketButton(for option: OrganizeBucket, count: Int) -> some View {
        Button {
            if model.canUse(option) {
                switchBucket(option)
            } else {
                showPaywall = true
            }
        } label: {
            Label {
                Text("\(option.title)（\(count)）")
            } icon: {
                if option == bucket {
                    Image(systemName: "checkmark")
                } else if !model.canUse(option) {
                    Image(systemName: "lock.fill")
                } else {
                    Image(systemName: sourceIcon(option))
                }
            }
        }
        .disabled(count == 0 && option != bucket && model.canUse(option))
    }

    private func sourceIcon(_ bucket: OrganizeBucket) -> String {
        switch bucket {
        case .allUnorganized: return PhotoFilter.all.systemImage
        case .unorganizedPhotos: return PhotoFilter.photos.systemImage
        case .unorganizedVideos: return PhotoFilter.videos.systemImage
        case .unorganizedScreenshots: return PhotoFilter.screenshots.systemImage
        case .month: return "calendar"
        }
    }

    private func switchBucket(_ newBucket: OrganizeBucket) {
        guard newBucket != bucket else { return }
        quickMode = nil
        withMotion {
            bucket = newBucket
            applyBucket()
            Task { await updateCurrentAssetAlbums() }
        }
    }

    private func updateCurrentAssetAlbums() async {
        guard let asset = currentAsset else {
            currentAlbums = []
            currentAlbumIDs = []
            return
        }
        let titles = library.albumTitles(for: asset)
        let ids = library.albumIDs(for: asset)
        currentAlbums = titles
        currentAlbumIDs = ids
    }

    // MARK: - 柵欄 / 網格模式批次動作

    private var selectedGridAssets: [PHAsset] {
        assets.filter { gridSelectedIDs.contains($0.localIdentifier) }
    }

    private func batchKeepSelected() {
        let targets = selectedGridAssets
        guard !targets.isEmpty else { return }

        let allKept = targets.allSatisfy { organized.isOrganized($0) }
        if allKept {
            for asset in targets {
                organized.unmarkOrganized(asset)
                incrementCounts(for: asset)
            }
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                gridSelectedIDs.removeAll()
            }
            showBanner("已取消保留 \(targets.count) 張照片", icon: "checkmark.circle", tint: .secondary, haptic: .light)
        } else {
            guard model.hasQuotaLeft else { showPaywall = true; return }
            let unkept = targets.filter { !organized.isOrganized($0) }
            for asset in unkept {
                organized.markOrganized(asset)
                decrementCounts(for: asset)
                history.append(SessionAction(assetID: asset.localIdentifier, kind: .keep))
            }
            model.consumeQuota(unkept.count)

            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                gridSelectedIDs.removeAll()
            }
            showBanner("已保留 \(targets.count) 張照片", icon: "checkmark.circle.fill", tint: .green, haptic: .light)
        }
    }

    private func batchDeleteSelected() {
        let targets = selectedGridAssets
        guard !targets.isEmpty else { return }
        guard model.hasQuotaLeft else { showPaywall = true; return }
        let count = targets.count

        for asset in targets {
            model.markTrashed(asset.localIdentifier)
            decrementCounts(for: asset)
            history.append(SessionAction(assetID: asset.localIdentifier, kind: .delete))
        }
        model.consumeQuota(count)

        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            gridSelectedIDs.removeAll()
        }
        showBanner("已加入待刪除 \(count) 張照片", icon: "trash.fill", tint: .red, haptic: .warning)
    }

    private func batchToggleFavoriteSelected() {
        let targets = selectedGridAssets
        guard !targets.isEmpty else { return }
        let allFavorites = targets.allSatisfy { isFavorite($0) }
        let targetState = !allFavorites

        for asset in targets {
            favoriteState[asset.localIdentifier] = targetState
            if targetState {
                organized.markOrganized(asset)
            }
        }
        Task {
            for asset in targets {
                try? await library.setFavorite(asset, to: targetState)
            }
        }
        showBanner(targetState ? "已將 \(targets.count) 張加入喜愛" : "已將 \(targets.count) 張移出喜愛",
                   icon: targetState ? "heart.fill" : "heart.slash.fill",
                   tint: targetState ? .pink : .secondary,
                   haptic: targetState ? .success : .light)
    }
}

/// 動作之後跳出來的結果提示。
struct SessionBanner: Equatable {
    enum Haptic { case light, success, warning }

    let id = UUID()
    let text: String
    let icon: String
    let tint: Color
    var haptic: Haptic = .light
}

/// 這次整理過程中的一個動作，用來支援右滑撤銷。
struct SessionAction {
    enum Kind {
        case keep
        case delete
        case favorite(previous: Bool)
        case skip
    }

    let assetID: String
    let kind: Kind
}
