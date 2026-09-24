import SwiftUI
import Photos

/// 在照片分頁的時間軸或全部點一張照片，彈出的全螢幕檢視。
///
/// 標題是這張的日期時間；左邊關閉，右邊待刪除。可以左右滑看前後的照片。
/// 底下的功能列：日記、備註、標籤、相簿、喜愛（移出喜愛）、刪除。
/// 日記與備註已經寫過就打開原本的內容來編輯。
struct PhotoDetailView: View {
    @State private var assets: [PHAsset]
    @State private var currentID: String
    /// 從日記點進來時不再有「日記」（已經在日記裡了）。
    private let showsJournal: Bool
    /// false 時只看照片與備註：沒有下面那排功能按鈕，也沒有待刪除。收藏、月曆、週曆點開用。
    private let showsActions: Bool

    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var journalStore: JournalStore
    @EnvironmentObject private var noteStore: NoteStore
    @EnvironmentObject private var tagStore: TagStore
    @Environment(\.dismiss) private var dismiss

    private enum QuickMode {
        case tags
        case albums
    }

    @State private var sheet: DetailSheet?
    @State private var quickMode: QuickMode?
    @State private var currentAlbumIDs: Set<String> = []
    @State private var isInspectorExpanded = false
    /// 往下滑關閉時，畫面跟著手指往下走的距離。
    @State private var dragDown: CGFloat = 0
    /// 記錄每次拖曳「起始時」inspector 是否展開，避免手勢結束時狀態已變而誤觸 dismiss。
    @State private var inspectorExpandedAtGestureStart = false
    @State private var showTrash = false
    /// 這次自己改過的喜愛狀態，系統照片庫通知回來之前先用它顯示。
    @State private var favoriteState: [String: Bool] = [:]
    /// 觸覺回饋：每做一次動作加一，換成對應的震動。
    @State private var favoriteTick = 0
    @State private var deleteTick = 0
    /// 剛刪掉的一張，顯示「復原」用。
    @State private var undoItem: UndoItem?
    @State private var undoHideTask: Task<Void, Never>?

    private struct UndoItem: Equatable {
        let assetID: String
        let index: Int
    }

    private enum DetailSheet: Identifiable {
        case journal, note, tags, album
        var id: Int { hashValue }
    }

    init(assets: [PHAsset], startID: String, showsJournal: Bool = true, showsActions: Bool = true) {
        self.showsJournal = showsJournal
        self.showsActions = showsActions
        _assets = State(initialValue: assets)
        _currentID = State(initialValue: startID)
    }

    private var current: PHAsset? { assets.first { $0.localIdentifier == currentID } }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 10) {
                    header

                    TabView(selection: $currentID) {
                        ForEach(assets, id: \.localIdentifier) { asset in
                            DetailPage(asset: asset, isFavorite: isFavorite(asset))
                                .tag(asset.localIdentifier)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(minHeight: geometry.size.height * 0.32)
                    .layoutPriority(1)
                    .offset(y: isInspectorExpanded ? 0 : dragDown)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 20)
                            .onChanged { value in
                                let vertical = value.translation.height
                                let horizontal = abs(value.translation.width)
                                // 在手勢剛啟動時（位移很小）記錄 inspector 當下狀態
                                if abs(vertical) < 4, abs(value.translation.width) < 4 {
                                    inspectorExpandedAtGestureStart = isInspectorExpanded
                                }
                                if !isInspectorExpanded {
                                    if vertical > 0, vertical > horizontal * 1.5 {
                                        dragDown = vertical
                                    }
                                }
                            }
                            .onEnded { value in
                                let vertical = value.translation.height
                                let horizontal = abs(value.translation.width)
                                // 判斷依據：手勢「起始」時 inspector 是否展開，而非當下狀態
                                if !inspectorExpandedAtGestureStart {
                                    if vertical > 110, vertical > horizontal * 1.5 {
                                        dismiss()
                                    } else if vertical < -45, abs(vertical) > horizontal * 1.5 {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                            dragDown = 0
                                            isInspectorExpanded = true
                                        }
                                    } else {
                                        withMotion(.spring(response: 0.3, dampingFraction: 0.8)) { dragDown = 0 }
                                    }
                                } else {
                                    // 手勢起始時 inspector 是開著的 → 只收起，絕不 dismiss
                                    if vertical > 50, vertical > horizontal * 1.3 {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                            isInspectorExpanded = false
                                        }
                                    }
                                }
                            }
                    )

                    if isInspectorExpanded, let currentAsset = current {
                        PhotoInspectorPanelView(asset: currentAsset) {
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

                    // 4. 展開標籤或相簿列表（點 3 內的標籤或相簿時展開，位於 3 上方）
                    if let mode = quickMode, let currentAsset = current {
                        QuickAssetChipsBar(
                            mode: mode == .tags ? .tags : .albums,
                            asset: currentAsset,
                            assignedAlbumIDs: $currentAlbumIDs,
                            onManage: {
                                sheet = (mode == .tags) ? .tags : .album
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // 3. 固定在頁尾的功能列（就算 2 展開了還是保留）
                    if showsActions {
                        actionBar
                    } else {
                        noteCaption
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .overlay(alignment: .bottom) { undoBanner }
        .failureToast()
        .sheet(item: $sheet) { which in
            if let asset = current {
                switch which {
                case .journal:
                    let day = dayParts(asset)
                    // 那天已經有日記就載入它，這張照片一併勾選。
                    JournalEditorView(year: day.0, month: day.1, day: day.2,
                                      preselectedIDs: [asset.localIdentifier])
                case .note:
                    NoteEditorView(asset: asset)
                case .tags:
                    TagPickerView(assets: [asset])
                case .album:
                    AlbumPickerView(assets: [asset])
                }
            }
        }
        .sheet(isPresented: $showTrash) { PendingTrashView() }
        .task(id: currentID) {
            if let asset = current {
                currentAlbumIDs = library.albumIDs(for: asset)
            } else {
                currentAlbumIDs = []
            }
        }
        .sensoryFeedback(.success, trigger: favoriteTick)
        .sensoryFeedback(.warning, trigger: deleteTick)
        .sensoryFeedback(.selection, trigger: currentID)
    }

    // MARK: - 頁首

    private var header: some View {
        HStack {
            GlassCircleButton { dismiss() } label: {
                Image(systemName: "xmark")
            }
            .accessibilityLabel(Text("Close"))
            .accessibilityIdentifier("detail.close")

            Spacer()

            Text(titleText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .accessibilityIdentifier("detail.title")

            Spacer()

            HStack(spacing: 8) {
                if showsActions {
                    GlassCircleButton { showTrash = true } label: {
                        Image(systemName: "trash")
                    }
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
                        }
                    }
                    .accessibilityLabel(Text("Pending deletion"))
                    .accessibilityIdentifier("detail.trash")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    /// 沒有功能按鈕時，這張有備註就顯示在底下。
    @ViewBuilder
    private var noteCaption: some View {
        if let asset = current, let text = noteStore.note(for: asset)?.text, !text.isEmpty {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .floatingGlass(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .accessibilityIdentifier("detail.note.text")
        } else {
            Color.clear.frame(height: 16)
        }
    }

    private var titleText: String {
        guard let date = current?.creationDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - 功能列

    private var tagsCount: Int {
        guard let current else { return 0 }
        return tagStore.tagIDs(for: current).count
    }

    private var tagsButtonKey: LocalizedStringKey {
        if tagsCount == 0 {
            return "Tags"
        } else {
            return "\(String(localized: "Tags"))(\(tagsCount))"
        }
    }

    private var albumsButtonKey: LocalizedStringKey {
        let count = currentAlbumIDs.count
        if count == 0 {
            return "Album"
        } else {
            return "\(String(localized: "Album"))(\(count))"
        }
    }

    private var actionBar: some View {
        let asset = current
        let favorite = asset.map(isFavorite) ?? false

        return ActionBarRow {
            barButton("資訊", icon: isInspectorExpanded ? "info.circle.fill" : "info.circle",
                      id: "detail.info", isActive: isInspectorExpanded) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    isInspectorExpanded.toggle()
                }
            }
            Spacer(minLength: 4)
            barButton(tagsButtonKey, icon: "tag", id: "detail.tags",
                      isActive: quickMode == .tags) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                    quickMode = (quickMode == .tags) ? nil : .tags
                }
            }
            Spacer(minLength: 4)
            barButton(albumsButtonKey, icon: "rectangle.stack.badge.plus", id: "detail.album",
                      isActive: quickMode == .albums) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                    quickMode = (quickMode == .albums) ? nil : .albums
                }
            }
            Spacer(minLength: 4)
            barButton(favorite ? "Remove from favorites" : "Favorite",
                      icon: favorite ? "heart.slash" : "heart", id: "detail.favorite") {
                toggleFavorite()
            }
            Spacer(minLength: 4)
            barButton("Delete", icon: "xmark", id: "detail.delete", isDestructive: true) {
                deleteCurrent()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .floatingGlass(in: RoundedRectangle(cornerRadius: 26, style: .continuous), interactive: true)
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .disabled(asset == nil)
    }

    private func barButton(_ key: LocalizedStringKey, icon: String, id: String,
                           isActive: Bool = false,
                           isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        ActionBarButton(key: key, icon: icon, id: id, isActive: isActive,
                        isDestructive: isDestructive,
                        tint: .white, action: action)
    }

    /// 刪除之後浮在功能列上面：「已放進待刪除　復原」。
    @ViewBuilder
    private var undoBanner: some View {
        if let undoItem {
            HStack(spacing: 14) {
                Label(String(localized: "Moved to pending deletion"), systemImage: "trash.fill")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white)
                Button(String(localized: "Undo")) { undoDelete(undoItem) }
                    .font(.footnote.weight(.bold))
                    .accessibilityIdentifier("detail.undo")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .floatingGlass(in: Capsule(), interactive: true)
            .padding(.bottom, 96)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private func undoDelete(_ item: UndoItem) {
        undoHideTask?.cancel()
        model.unmarkTrashed(item.assetID)
        if let asset = library.asset(withID: item.assetID) {
            withMotion {
                assets.insert(asset, at: min(item.index, assets.count))
                currentID = asset.localIdentifier
                undoItem = nil
            }
        } else {
            withMotion { undoItem = nil }
        }
    }

    // MARK: - 動作

    private func dayParts(_ asset: PHAsset) -> (Int, Int, Int) {
        let parts = PhotoGrouping.calendar.dateComponents([.year, .month, .day],
                                                         from: asset.creationDate ?? Date())
        return (parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    /// `asset` 是傳進來時就已經抓好的實體，直接讀它的 `isFavorite` 就好；
    /// 不要為了「保險」再用 ID 去 PhotoKit 重新查一次——`ForEach` 每張都會呼叫這個函式，
    /// 開「全部」這種上千張的清單時，等於在主執行緒排隊打上千次 Photos 資料庫查詢，
    /// 卡住超過系統的看門狗時限就會被強制關閉（實機上已經這樣當機過）。
    private func isFavorite(_ asset: PHAsset) -> Bool {
        favoriteState[asset.localIdentifier] ?? asset.isFavorite
    }

    private func toggleFavorite() {
        guard let asset = current else { return }
        let now = !isFavorite(asset)
        favoriteState[asset.localIdentifier] = now
        favoriteTick += 1
        let target = library.asset(withID: asset.localIdentifier) ?? asset
        Task {
            let ok = await library.attempt(String(localized: "Couldn't change favorites")) {
                try await library.setFavorite(target, to: now)
            }
            // 沒成功就把畫面上的狀態還原。
            if !ok { favoriteState[asset.localIdentifier] = !now }
        }
    }

    /// 刪除：跟整理一樣先放進待刪清單，不會直接刪掉。這張從檢視裡拿掉，換到相鄰的一張；沒有了就關閉。
    private func deleteCurrent() {
        guard let asset = current, let index = assets.firstIndex(where: { $0.localIdentifier == currentID }) else { return }
        model.markTrashed(asset.localIdentifier)
        deleteTick += 1
        var remaining = assets
        remaining.remove(at: index)
        // 最後一張刪掉就直接關閉；否則留在檢視裡，顯示可以復原的提示。
        guard !remaining.isEmpty else { dismiss(); return }
        withMotion { undoItem = UndoItem(assetID: asset.localIdentifier, index: index) }
        undoHideTask?.cancel()
        undoHideTask = Task {
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            guard !Task.isCancelled else { return }
            withMotion { undoItem = nil }
        }
        let next = remaining[min(index, remaining.count - 1)]
        withMotion {
            assets = remaining
            currentID = next.localIdentifier
        }
    }
}

/// 一頁一張照片，載入大圖。喜愛的話右上角有愛心。
private struct DetailPage: View {
    let asset: PHAsset
    let isFavorite: Bool
    @State private var image: UIImage?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(white: 0.11))

            if asset.mediaType == .video {
                InlineVideoView(asset: asset, poster: image)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressView().tint(.white).frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
                    .frame(width: 44, height: 44)
                    .floatingGlass(in: Circle())
                    .padding(12)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .task(id: asset.localIdentifier) {
            image = await ThumbnailLoader.shared.image(for: asset, size: 1400)
        }
    }
}
