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

    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var journalStore: JournalStore
    @EnvironmentObject private var noteStore: NoteStore
    @Environment(\.dismiss) private var dismiss

    @State private var sheet: DetailSheet?
    /// 往下滑關閉時，畫面跟著手指往下走的距離。
    @State private var dragDown: CGFloat = 0
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

    init(assets: [PHAsset], startID: String, showsJournal: Bool = true) {
        self.showsJournal = showsJournal
        _assets = State(initialValue: assets)
        _currentID = State(initialValue: startID)
    }

    private var current: PHAsset? { assets.first { $0.localIdentifier == currentID } }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                TabView(selection: $currentID) {
                    ForEach(assets, id: \.localIdentifier) { asset in
                        DetailPage(asset: asset, isFavorite: isFavorite(asset))
                            .tag(asset.localIdentifier)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                // 往下滑就關閉：畫面跟著手指往下走，滑超過一段距離放開就關掉，不夠就彈回來。
                // 只在明顯是垂直的滑動才算，左右翻頁不受影響。
                .offset(y: dragDown)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 20)
                        .onChanged { value in
                            let vertical = value.translation.height
                            guard vertical > 0, vertical > abs(value.translation.width) * 1.5 else { return }
                            dragDown = vertical
                        }
                        .onEnded { value in
                            let vertical = value.translation.height
                            if vertical > 110, vertical > abs(value.translation.width) * 1.5 {
                                dismiss()
                            } else {
                                withMotion(.spring(response: 0.3, dampingFraction: 0.8)) { dragDown = 0 }
                            }
                        }
                )

                actionBar
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

            GlassCircleButton { showTrash = true } label: {
                Image(systemName: "trash")
                    .overlay(alignment: .topTrailing) {
                        if !model.trashedAssetIDs.isEmpty {
                            Text("\(model.trashedAssetIDs.count)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .fixedSize()
                                .padding(.horizontal, 5)
                                .frame(minWidth: 18, minHeight: 18)
                                .background(Color.red, in: Capsule())
                                .offset(x: 12, y: -12)
                        }
                    }
            }
            .accessibilityLabel(Text("Pending deletion"))
            .accessibilityIdentifier("detail.trash")
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    private var titleText: String {
        guard let date = current?.creationDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - 功能列

    private var actionBar: some View {
        let asset = current
        let favorite = asset.map(isFavorite) ?? false

        return ActionBarRow {
            if showsJournal {
                barButton("Journal", icon: "book.closed", id: "detail.journal") { sheet = .journal }
                Spacer(minLength: 4)
            }
            barButton("Note", icon: "note.text", id: "detail.note") { sheet = .note }
            Spacer(minLength: 4)
            barButton("Tags", icon: "tag", id: "detail.tags") { sheet = .tags }
            Spacer(minLength: 4)
            barButton("Album", icon: "rectangle.stack.badge.plus", id: "detail.album") { sheet = .album }
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
        .padding(.vertical, 6)
        .disabled(asset == nil)
    }

    private func barButton(_ key: LocalizedStringKey, icon: String, id: String,
                           isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        ActionBarButton(key: key, icon: icon, id: id, isDestructive: isDestructive,
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

    private func isFavorite(_ asset: PHAsset) -> Bool {
        if let known = favoriteState[asset.localIdentifier] { return known }
        return (library.asset(withID: asset.localIdentifier) ?? asset).isFavorite
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
