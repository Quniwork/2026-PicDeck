import SwiftUI
import Photos

/// 逐張審核畫面，主要靠手勢：
/// 左滑保留、右滑回上一張（順便撤銷該張剛做的動作）、上滑加入待刪、
/// 下滑加入系統喜愛（再滑一次就移出喜愛）、雙擊放大。
/// 底下的功能列是寫日記、喜愛、標籤、相簿、刪除。保留只用手勢，沒有按鈕。
struct ReviewSessionView: View {
    /// 目前看的來源。可以從頁首的選單切到其他未整理集合。
    @State private var bucket: OrganizeBucket
    @State private var initialMonthBucket: OrganizeBucket?

    init(bucket: OrganizeBucket) {
        _bucket = State(initialValue: bucket)
        if case .month = bucket {
            _initialMonthBucket = State(initialValue: bucket)
        }
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
    /// 目前這張照片所屬的相簿名稱與 ID 清單。
    @State private var currentAlbums: [String] = []
    @State private var currentAlbumIDs: Set<String> = []

    private var currentTags: [PhotoTag] {
        guard let currentAsset else { return [] }
        return tagStore.tags(for: currentAsset)
    }

    private enum QuickMode { case tags, albums }

    private let threshold: CGFloat = 100

    var body: some View {
        VStack(spacing: 0) {
            header
            photoArea
            GlassGroup(spacing: 10) {
                VStack(spacing: 0) {
                    actionBar
                    quickRow
                }
            }
        }
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
        .sheet(isPresented: $showTagPicker) {
            if let asset = currentAsset {
                TagPickerView(assets: [asset])
            }
        }
        .sheet(isPresented: $showTrash) { PendingTrashView() }
        .sheet(isPresented: $showMoreAlbums, onDismiss: {
            Task {
                albums = await library.userAlbums()
                await updateCurrentAssetAlbums()
            }
        }) {
            if let asset = currentAsset {
                AlbumPickerView(assets: [asset])
            }
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

    /// 頁首：關閉、來源標題、垃圾桶。三個都是浮在照片上的玻璃，靠得近時會融合成一組。
    private var header: some View {
        VStack(spacing: 6) {
            GlassGroup(spacing: 16) {
                HStack {
                    GlassCircleButton { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel(Text("Close"))
                    .accessibilityIdentifier("session.close")

                    Spacer()

                    Menu {
                        // 切到其他未整理集合。張數是 0 的不列出；沒解鎖的顯示鎖頭，不能選。
                        ForEach(sourceBuckets) { option in
                            Button {
                                switchBucket(option)
                            } label: {
                                Label {
                                    Text("\(option.title)（\(sourceCounts[option.id] ?? 0)）")
                                } icon: {
                                    Image(systemName: option == bucket ? "checkmark"
                                                       : (model.canUse(option) ? sourceIcon(option) : "lock.fill"))
                                }
                            }
                            .disabled(!model.canUse(option) && option != bucket)
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

                    Spacer()

                    GlassCircleButton { showTrash = true } label: {
                        Image(systemName: "trash")
                            .overlay(alignment: .topTrailing) {
                                // 待刪除的張數，紅色圓形加數字。
                                if !model.trashedAssetIDs.isEmpty {
                                    Text("\(model.trashedAssetIDs.count)")
                                        .font(.system(.caption2, design: .rounded, weight: .bold))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                        .fixedSize()
                                        .padding(.horizontal, 5)
                                        .frame(minWidth: 18, minHeight: 18)
                                        .background(Color.red, in: Capsule())
                                        .offset(x: 12, y: -12)
                                        .accessibilityIdentifier("session.trash.count")
                                }
                            }
                    }
                    .accessibilityLabel(Text("Pending deletion"))
                    .accessibilityIdentifier("session.trash")
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 8)
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
                AppEmptyState(icon: "checkmark.circle",
                              title: String(localized: "All done"),
                              message: String(localized: "You reached the end of this batch."))
            } else if let asset = currentAsset {
                SessionPhotoCard(asset: asset, isZoomed: $isZoomed)
                    .offset(dragOffset)
                    .rotationEffect(.degrees(Double(dragOffset.width / 30)))
                    .overlay(alignment: .top) {
                        HStack(alignment: .top, spacing: 8) {
                            if !currentTags.isEmpty || !currentAlbums.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 6) {
                                        ForEach(currentTags) { tag in
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
                                            .floatingGlass(in: Capsule())
                                        }
                                        ForEach(currentAlbums, id: \.self) { albumTitle in
                                            HStack(spacing: 4) {
                                                Image(systemName: "rectangle.stack.fill")
                                                    .font(.system(size: 11))
                                                    .foregroundStyle(Color.accentColor)
                                                Text(albumTitle)
                                                    .font(.caption2.weight(.medium))
                                                    .lineLimit(1)
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .foregroundStyle(.primary)
                                            .floatingGlass(in: Capsule())
                                        }
                                    }
                                }
                            }

                            Spacer(minLength: 0)

                            if isFavorite(asset) {
                                // 玻璃圓形加粉紅愛心，浮在照片右上角。
                                Image(systemName: "heart.fill")
                                    .font(.title2)
                                    .foregroundStyle(.pink)
                                    .frame(width: 44, height: 44)
                                    .floatingGlass(in: Circle())
                                    .transition(.scale.combined(with: .opacity))
                                    .accessibilityIdentifier("session.favorite.badge")
                            }
                        }
                        .padding(12)
                        .allowsHitTesting(false)
                        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: currentTags)
                        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: currentAlbums)
                    }
                    .overlay(alignment: .center) { gestureHint }
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 12)
                            .onChanged { dragOffset = $0.translation }
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
        } else if dragOffset.height > 55 {
            hint("Favorite", icon: "heart.fill", color: .pink)
        } else if dragOffset.width < -55 {
            hint("Keep", icon: "arrow.down.to.line.circle.fill", color: .green)
        } else if dragOffset.width > 55 {
            hint("Previous", icon: "arrow.right.circle.fill", color: .accentColor)
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

    /// 跟選取照片時的功能列同一種樣式：玻璃膠囊、小圖示加文字、間距平均。
    private var actionBar: some View {
        let favorite = currentAsset.map(isFavorite) ?? false

        // 整理畫面不寫日記。順序：標籤、相簿、喜愛（移出喜愛）、保留、刪除。
        return ActionBarRow {
            barButton("Tags", icon: currentTags.isEmpty ? "tag" : "tag.fill", id: "session.tags", isActive: quickMode == .tags) {
                quickMode = (quickMode == .tags) ? nil : .tags
            }
            Spacer(minLength: 4)
            barButton("Album", icon: currentAlbums.isEmpty ? "rectangle.stack.badge.plus" : "rectangle.stack.fill", id: "session.albums",
                      isActive: quickMode == .albums) {
                quickMode = (quickMode == .albums) ? nil : .albums
            }
            Spacer(minLength: 4)
            barButton(favorite ? "Remove from favorites" : "Favorite",
                      icon: favorite ? "heart.slash" : "heart",
                      id: "session.favorite") {
                toggleFavoriteCurrent()
            }
            Spacer(minLength: 4)
            barButton("Keep", icon: "checkmark", id: "session.keep") {
                keepCurrent()
            }
            Spacer(minLength: 4)
            barButton("Delete", icon: "xmark", id: "session.delete", isDestructive: true) {
                deleteCurrent()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .floatingGlass(in: RoundedRectangle(cornerRadius: 26, style: .continuous), interactive: true)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .disabled(currentAsset == nil)
    }

    private func barButton(_ key: LocalizedStringKey, icon: String, id: String,
                           isActive: Bool = false, isDestructive: Bool = false,
                           action: @escaping () -> Void) -> some View {
        ActionBarButton(key: key, icon: icon, id: id, isActive: isActive,
                        isDestructive: isDestructive, action: action)
    }

    // MARK: - 快速分類列

    /// 點了標籤或相簿之後才出現：前三個項目加上第四個「更多」。
    @ViewBuilder
    private var quickRow: some View {
        switch quickMode {
        case .tags:
            quickPanel(title: String(localized: "File into tag…"),
                       moreTitle: String(localized: "More tags"),
                       id: "session.tagrow",
                       items: tagStore.tagsByRecentUse.prefix(3).map { tag in
                           let isSelected = currentAsset.map { tagStore.tagIDs(for: $0).contains(tag.id) } ?? false
                           return QuickItem(id: tag.id.uuidString, title: tag.name, iconRaw: tag.symbol, systemImage: nil, isSelected: isSelected) {
                               fileCurrent(intoTag: tag)
                           }
                       },
                       onMore: { showTagPicker = true })
        case .albums:
            quickPanel(title: String(localized: "File into album…"),
                       moreTitle: String(localized: "More albums"),
                       id: "session.albumrow",
                       items: albums.prefix(3).map { album in
                           let isSelected = currentAlbumIDs.contains(album.id)
                           return QuickItem(id: album.id, title: album.title, iconRaw: nil, systemImage: "rectangle.stack", isSelected: isSelected) {
                               fileCurrent(into: album)
                           }
                       },
                       onMore: { showMoreAlbums = true })
        case nil:
            EmptyView()
        }
    }

    private struct QuickItem: Identifiable {
        let id: String
        let title: String
        let iconRaw: String?
        let systemImage: String?
        var isSelected: Bool = false
        let action: () -> Void
    }

    private func quickPanel(title: String,
                            moreTitle: String,
                            id: String,
                            items: [QuickItem],
                            onMore: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            // 固定四格：前三個是項目，第四個永遠是「更多」。
            HStack(alignment: .top, spacing: 0) {
                ForEach(0..<3, id: \.self) { slot in
                    if slot < items.count {
                        quickButton(title: items[slot].title,
                                    iconRaw: items[slot].iconRaw,
                                    systemImage: items[slot].systemImage,
                                    isSelected: items[slot].isSelected,
                                    action: items[slot].action)
                    } else {
                        Color.clear.frame(maxWidth: .infinity, minHeight: 1)
                    }
                }
                quickButton(title: moreTitle, iconRaw: nil, systemImage: "ellipsis", action: onMore)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 10)
        .padding(.horizontal, 12)
        .floatingGlass(in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
        .accessibilityIdentifier(id)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func quickButton(title: String,
                             iconRaw: String?,
                             systemImage: String?,
                             isSelected: Bool = false,
                             action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Group {
                        if let iconRaw {
                            IconLabel(raw: iconRaw, size: 22)
                        } else if let systemImage {
                            Image(systemName: systemImage).font(.title3)
                        }
                    }
                    .frame(height: 30)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.primary)

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.accentColor)
                            .offset(x: 8, y: -2)
                    }
                }
                Text(title)
                    .font(.caption2.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityIdentifier("session.quick")
        .disabled(currentAsset == nil)
    }

    // MARK: - 狀態

    private var currentAsset: PHAsset? {
        guard index >= 0, index < assets.count else { return nil }
        return assets[index]
    }

    // MARK: - 動作

    private func handleDrag(_ translation: CGSize) {
        dragOffset = .zero

        if translation.height < -threshold {
            deleteCurrent()
        } else if translation.height > threshold {
            toggleFavoriteCurrent()
        } else if translation.width < -threshold {
            keepCurrent()
        } else if translation.width > threshold {
            goPrevious()
        }
    }

    /// 右滑：上一張，若上一張剛做過保留或刪除就一併撤銷。
    private func goPrevious() {
        guard let last = history.popLast() else {
            if index > 0 { withMotion { index -= 1 } }
            return
        }

        switch last.kind {
        case .keep:
            if let asset = library.asset(withID: last.assetID) {
                organized.unmarkOrganized(asset)
            }
            model.refundQuota()
            showBanner(String(localized: "Undone"), icon: "arrow.uturn.backward", tint: .secondary)
        case .delete:
            model.unmarkTrashed(last.assetID)
            model.refundQuota()
            showBanner(String(localized: "Undone"), icon: "arrow.uturn.backward", tint: .secondary)
        case .favorite(let previous):
            if let asset = library.asset(withID: last.assetID) {
                Task {
                    await library.attempt(String(localized: "Couldn't change favorites")) {
                        try await library.setFavorite(asset, to: previous)
                    }
                }
            }
            showBanner(String(localized: "Undone"), icon: "arrow.uturn.backward", tint: .secondary)
        case .skip:
            break
        }

        withMotion { index = max(0, index - 1) }
    }

    /// 保留：標記成已整理，之後不再出現在未整理清單。
    private func keepCurrent() {
        guard let asset = currentAsset, model.hasQuotaLeft else { return }
        organized.markOrganized(asset)
        model.consumeQuota()
        history.append(SessionAction(assetID: asset.localIdentifier, kind: .keep))
        showBanner(String(localized: "Kept"), icon: "checkmark.circle.fill", tint: .green)
        withMotion { index += 1 }
    }

    /// 刪除：先進待刪清單，確認後才真的刪。
    private func deleteCurrent() {
        guard let asset = currentAsset, model.hasQuotaLeft else { return }
        model.markTrashed(asset.localIdentifier)
        model.consumeQuota()
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

    /// 分類到標籤：加上標籤，同時視為已整理，然後看下一張。
    private func fileCurrent(intoTag tag: PhotoTag) {
        guard let asset = currentAsset, model.hasQuotaLeft else { return }
        tagStore.addTag(tag.id, to: [asset])
        organized.markOrganized(asset)
        model.consumeQuota()
        history.append(SessionAction(assetID: asset.localIdentifier, kind: .keep))
        showBanner(String(localized: "Filed into \(tag.name)"), icon: "tag.fill", tint: .accentColor, haptic: .success)
        withMotion { index += 1 }
    }

    /// 歸檔到本機相簿，同時視為已整理。
    private func fileCurrent(into album: AlbumSummary) {
        guard let asset = currentAsset, model.hasQuotaLeft else { return }
        Task {
            await library.attempt(String(localized: "Couldn't add to the album")) {
                try await library.addAsset(asset, toAlbumWithID: album.id)
            }
        }
        organized.markOrganized(asset)
        model.consumeQuota()
        history.append(SessionAction(assetID: asset.localIdentifier, kind: .keep))
        showBanner(String(localized: "Filed into \(album.title)"), icon: "rectangle.stack.fill", tint: .accentColor, haptic: .success)
        withMotion { index += 1 }
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
        basePool = all.filter { !organized.isOrganized($0) }
        screenshotIDs = Set(await library.assets(matching: .screenshots).map(\.localIdentifier))
        var counts: [String: Int] = [
            OrganizeBucket.allUnorganized.id: basePool.count,
            OrganizeBucket.unorganizedPhotos.id: basePool.filter { $0.mediaType == .image }.count,
            OrganizeBucket.unorganizedVideos.id: basePool.filter { $0.mediaType == .video }.count,
            OrganizeBucket.unorganizedScreenshots.id: basePool.filter { screenshotIDs.contains($0.localIdentifier) }.count,
        ]
        let calendar = Calendar.current
        if case .month(let year, let month) = bucket {
            counts[bucket.id] = basePool.filter { asset in
                guard let date = asset.creationDate else { return false }
                let parts = calendar.dateComponents([.year, .month], from: date)
                return parts.year == year && parts.month == month
            }.count
        }
        if let initial = initialMonthBucket, case .month(let year, let month) = initial {
            counts[initial.id] = basePool.filter { asset in
                guard let date = asset.creationDate else { return false }
                let parts = calendar.dateComponents([.year, .month], from: date)
                return parts.year == year && parts.month == month
            }.count
        }
        sourceCounts = counts
        applyBucket()
        await updateCurrentAssetAlbums()
    }

    /// 依目前的來源挑出要整理的照片，從第一張開始。
    private func applyBucket() {
        var pool = basePool
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
        index = 0
        history.removeAll()
    }

    /// 選單裡的來源：四個固定集合，張數是 0 的不列（目前這個一定列）。
    private var sourceBuckets: [OrganizeBucket] {
        let all: [OrganizeBucket] = [.allUnorganized, .unorganizedPhotos, .unorganizedVideos, .unorganizedScreenshots]
        var result = all.filter { (sourceCounts[$0.id] ?? 0) > 0 || $0 == bucket }
        if case .month = bucket, !result.contains(bucket) { result.append(bucket) }
        if let initial = initialMonthBucket, !result.contains(initial) { result.append(initial) }
        return result
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
