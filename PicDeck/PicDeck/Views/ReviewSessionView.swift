import SwiftUI
import Photos

/// 逐張審核畫面。手勢與按鈕並存：
/// 左滑保留、右滑回上一張（順便撤銷該張剛做的動作）、上滑刪除、
/// 下拉加入系統喜愛、雙擊放大；保留與刪除另有按鈕。
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
    @State private var banner: String?
    @State private var showHelp = false
    @State private var showTrash = false
    @State private var showAlbumPicker = false
    @State private var isZoomed = false
    @State private var showTagPicker = false
    @State private var showJournal = false

    private let threshold: CGFloat = 100

    var body: some View {
        VStack(spacing: 0) {
            header
            photoArea
            actionRow
            albumRow
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .task { await load() }
        .sheet(isPresented: $showHelp) { HelpSheet() }
        .sheet(isPresented: $showTagPicker) {
            if let asset = currentAsset {
                TagPickerView(assets: [asset])
            }
        }
        .sheet(isPresented: $showJournal) {
            if let asset = currentAsset,
               let date = asset.creationDate {
                let parts = PhotoGrouping.calendar.dateComponents([.year, .month, .day], from: date)
                JournalEditorView(year: parts.year ?? 0,
                                  month: parts.month ?? 0,
                                  day: parts.day ?? 0)
            }
        }
        .sheet(isPresented: $showTrash) { PendingTrashView() }
        .sheet(isPresented: $showAlbumPicker) {
            AlbumQuickPicker(albums: albums) { album in
                fileCurrent(into: album)
            }
        }
        .overlay(alignment: .top) {
            if let banner {
                Text(banner)
                    .font(.footnote.weight(.medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.top, 60)
                    .transition(.opacity)
            }
        }
    }

    // MARK: - 上方

    private var header: some View {
        VStack(spacing: 4) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark").font(.title3)
                }
                .accessibilityIdentifier("session.close")

                Spacer()

                Menu {
                    Text(bucket.title)
                } label: {
                    HStack(spacing: 4) {
                        Text(bucket.title).font(.headline)
                        Image(systemName: "chevron.down").font(.caption2)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color(.secondarySystemBackground), in: Capsule())
                }

                Spacer()

                Button { showTrash = true } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                        .overlay(alignment: .topTrailing) {
                            if !model.trashedAssetIDs.isEmpty {
                                Circle().fill(.red).frame(width: 8, height: 8).offset(x: 5, y: -3)
                            }
                        }
                }
                .accessibilityIdentifier("session.trash")
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

    private var actionRow: some View {
        HStack(spacing: 0) {
            Button { showHelp = true } label: {
                Label("Help", systemImage: "questionmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .accessibilityIdentifier("session.help")

            Button { showJournal = true } label: {
                Label("Journal", systemImage: "square.and.pencil")
                    .frame(maxWidth: .infinity)
            }
            .accessibilityIdentifier("session.journal")
            .disabled(currentAsset == nil)

            Button { showTagPicker = true } label: {
                Label("Tags", systemImage: "tag")
                    .frame(maxWidth: .infinity)
            }
            .accessibilityIdentifier("session.tags")
            .disabled(currentAsset == nil)

            Button { keepCurrent() } label: {
                Label("Keep", systemImage: "arrow.down.to.line")
                    .frame(maxWidth: .infinity)
            }
            .accessibilityIdentifier("session.keep")
            .disabled(currentAsset == nil)

            Button { deleteCurrent() } label: {
                Label("Delete", systemImage: "xmark")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.red)
            }
            .accessibilityIdentifier("session.delete")
            .disabled(currentAsset == nil)
        }
        .font(.caption)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
    }

    // MARK: - 相冊列

    private var albumRow: some View {
        VStack(spacing: 10) {
            Text("File into album…")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 14) {
                ForEach(albums.prefix(2)) { album in
                    albumButton(title: album.title, icon: "folder") { fileCurrent(into: album) }
                }

                albumButton(title: String(localized: "File into album…"), icon: "arrow.down") {
                    showAlbumPicker = true
                }

                albumButton(title: String(localized: "More albums"), icon: "ellipsis") {
                    showAlbumPicker = true
                }
            }
            .padding(.bottom, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    private func albumButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.title3)
                Text(title)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
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
            favoriteCurrent()
        } else if translation.width < -threshold {
            keepCurrent()
        } else if translation.width > threshold {
            goPrevious()
        }
    }

    /// 右滑：上一張，若上一張剛做過保留或刪除就一併撤銷。
    private func goPrevious() {
        guard let last = history.popLast() else {
            if index > 0 { withAnimation { index -= 1 } }
            return
        }

        switch last.kind {
        case .keep:
            if let asset = library.asset(withID: last.assetID) {
                organized.unmarkOrganized(asset)
            }
            model.refundQuota()
            showBanner(String(localized: "Undone"))
        case .delete:
            model.unmarkTrashed(last.assetID)
            model.refundQuota()
            showBanner(String(localized: "Undone"))
        case .favorite(let previous):
            if let asset = library.asset(withID: last.assetID) {
                Task { try? await library.setFavorite(asset, to: previous) }
            }
            showBanner(String(localized: "Undone"))
        case .skip:
            break
        }

        withAnimation { index = max(0, index - 1) }
    }

    /// 保留：標記成已整理，之後不再出現在未整理清單。
    private func keepCurrent() {
        guard let asset = currentAsset, model.hasQuotaLeft else { return }
        organized.markOrganized(asset)
        model.consumeQuota()
        history.append(SessionAction(assetID: asset.localIdentifier, kind: .keep))
        showBanner(String(localized: "Kept"))
        withAnimation { index += 1 }
    }

    /// 刪除：先進待刪清單，確認後才真的刪。
    private func deleteCurrent() {
        guard let asset = currentAsset, model.hasQuotaLeft else { return }
        model.markTrashed(asset.localIdentifier)
        model.consumeQuota()
        history.append(SessionAction(assetID: asset.localIdentifier, kind: .delete))
        showBanner(String(localized: "Marked for deletion"))
        withAnimation { index += 1 }
    }

    private func favoriteCurrent() {
        guard let asset = currentAsset else { return }
        let previous = asset.isFavorite
        Task { try? await library.setFavorite(asset, to: !previous) }
        history.append(SessionAction(assetID: asset.localIdentifier, kind: .favorite(previous: previous)))
        showBanner(previous ? String(localized: "Removed from favorites")
                            : String(localized: "Added to favorites"))
        withAnimation { index += 1 }
    }

    /// 歸檔到本機相簿，同時視為已整理。
    private func fileCurrent(into album: AlbumSummary) {
        guard let asset = currentAsset, model.hasQuotaLeft else { return }
        Task { try? await library.addAsset(asset, toAlbumWithID: album.id) }
        organized.markOrganized(asset)
        model.consumeQuota()
        history.append(SessionAction(assetID: asset.localIdentifier, kind: .keep))
        showBanner(String(localized: "Filed into \(album.title)"))
        withAnimation { index += 1 }
    }

    private func showBanner(_ text: String) {
        withAnimation { banner = text }
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            withAnimation { banner = nil }
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
