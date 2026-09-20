import SwiftUI
import Photos

/// 逐張審核畫面，主要靠手勢：
/// 左滑保留、右滑回上一張（順便撤銷該張剛做的動作）、上滑加入待刪、
/// 下滑加入系統喜愛（再滑一次就移出喜愛）、雙擊放大。
/// 底下的功能列是寫日記、喜愛、標籤、相簿、刪除。保留只用手勢，沒有按鈕。
struct ReviewSessionView: View {
    let bucket: OrganizeBucket

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
    @State private var showJournal = false

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
        .toolbar(.hidden, for: .tabBar)
        .task { await load() }
        .sheet(isPresented: $showTagPicker) {
            if let asset = currentAsset {
                TagPickerView(assets: [asset])
            }
        }
        .sheet(isPresented: $showJournal) {
            if let asset = currentAsset,
               let date = asset.creationDate {
                let parts = PhotoGrouping.calendar.dateComponents([.year, .month, .day], from: date)
                // 目前這張照片預設就勾選，跟長按與多選寫日記一樣。
                JournalEditorView(year: parts.year ?? 0,
                                  month: parts.month ?? 0,
                                  day: parts.day ?? 0,
                                  preselectedIDs: [asset.localIdentifier])
            }
        }
        .sheet(isPresented: $showTrash) { PendingTrashView() }
        .sheet(isPresented: $showMoreAlbums, onDismiss: { Task { albums = await library.userAlbums() } }) {
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
                        Text(bucket.title)
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

                    Spacer()

                    GlassCircleButton { showTrash = true } label: {
                        Image(systemName: "trash")
                            .overlay(alignment: .topTrailing) {
                                // 待刪除的張數，紅色圓形加數字。
                                if !model.trashedAssetIDs.isEmpty {
                                    Text("\(model.trashedAssetIDs.count)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.white)
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
                ContentUnavailableView {
                    Label("Nothing left here", systemImage: "checkmark.circle")
                } description: {
                    Text("This source is all reviewed.")
                }
            } else if index >= assets.count {
                ContentUnavailableView {
                    Label("All done", systemImage: "checkmark.circle")
                } description: {
                    Text("You reached the end of this batch.")
                }
            } else if let asset = currentAsset {
                SessionPhotoCard(asset: asset, isZoomed: $isZoomed)
                    .offset(dragOffset)
                    .rotationEffect(.degrees(Double(dragOffset.width / 30)))
                    .overlay(alignment: .topTrailing) {
                        if isFavorite(asset) {
                            // 玻璃圓形加粉紅愛心，浮在照片右上角。
                            Image(systemName: "heart.fill")
                                .font(.title2)
                                .foregroundStyle(.pink)
                                .frame(width: 52, height: 52)
                                .floatingGlass(in: Circle())
                                .padding(12)
                                .transition(.scale.combined(with: .opacity))
                                .accessibilityIdentifier("session.favorite.badge")
                        }
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

        // 已經放進日記的照片就不再出現寫日記。
        let inJournal = currentAsset.map(journalStore.isInJournal) ?? false

        return HStack(spacing: 0) {
            if !inJournal {
                barButton("Write journal", icon: "square.and.pencil", id: "session.journal") {
                    showJournal = true
                }
                Spacer(minLength: 4)
            }
            barButton(favorite ? "Remove from favorites" : "Favorite",
                      icon: favorite ? "heart.slash" : "heart",
                      id: "session.favorite") {
                toggleFavoriteCurrent()
            }
            Spacer(minLength: 4)
            barButton("Tags", icon: "tag", id: "session.tags", isActive: quickMode == .tags) {
                quickMode = (quickMode == .tags) ? nil : .tags
            }
            Spacer(minLength: 4)
            barButton("Album", icon: "rectangle.stack.badge.plus", id: "session.albums",
                      isActive: quickMode == .albums) {
                quickMode = (quickMode == .albums) ? nil : .albums
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

    private func barButton(_ key: LocalizedStringKey,
                           icon: String,
                           id: String,
                           isActive: Bool = false,
                           isDestructive: Bool = false,
                           action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(key, systemImage: icon)
                .font(.caption)
                .labelStyle(.titleAndIcon)
                .lineLimit(1)
                .fixedSize()
                .foregroundStyle(isDestructive ? Color.red : (isActive ? Color.accentColor : Color.primary))
                .padding(.vertical, 6)
                .padding(.horizontal, 6)
                .background(isActive ? Color.accentColor.opacity(0.14) : Color.clear, in: Capsule())
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(id)
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
                       items: tagStore.tags.prefix(3).map { tag in
                           QuickItem(id: tag.id.uuidString, title: tag.name, iconRaw: tag.symbol, systemImage: nil) {
                               fileCurrent(intoTag: tag)
                           }
                       },
                       onMore: { showTagPicker = true })
        case .albums:
            quickPanel(title: String(localized: "File into album…"),
                       moreTitle: String(localized: "More albums"),
                       id: "session.albumrow",
                       items: albums.prefix(3).map { album in
                           QuickItem(id: album.id, title: album.title, iconRaw: nil, systemImage: "rectangle.stack") {
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
                             action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Group {
                    if let iconRaw {
                        IconLabel(raw: iconRaw, size: 22)
                    } else if let systemImage {
                        Image(systemName: systemImage).font(.title3)
                    }
                }
                .frame(height: 30)
                Text(title)
                    .font(.caption2)
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
                Task { try? await library.setFavorite(asset, to: previous) }
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
        Task { try? await library.setFavorite(asset, to: now) }
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
        Task { try? await library.addAsset(asset, toAlbumWithID: album.id) }
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
        var pool = all.filter { !organized.isOrganized($0) }

        switch bucket {
        case .allUnorganized:
            break
        case .unorganizedPhotos:
            pool = pool.filter { $0.mediaType == .image }
        case .unorganizedVideos:
            pool = pool.filter { $0.mediaType == .video }
        case .unorganizedScreenshots:
            let screenshots = await library.assets(matching: .screenshots)
            let ids = Set(screenshots.map(\.localIdentifier))
            pool = pool.filter { ids.contains($0.localIdentifier) }
        case .month(let year, let month):
            let calendar = Calendar.current
            pool = pool.filter { asset in
                guard let date = asset.creationDate else { return false }
                let parts = calendar.dateComponents([.year, .month], from: date)
                return parts.year == year && parts.month == month
            }
        }

        assets = pool
        index = 0
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
