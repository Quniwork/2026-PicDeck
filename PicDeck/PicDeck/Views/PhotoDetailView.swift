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
    @State private var showTrash = false
    /// 這次自己改過的喜愛狀態，系統照片庫通知回來之前先用它顯示。
    @State private var favoriteState: [String: Bool] = [:]

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

                actionBar
            }
        }
        .preferredColorScheme(.dark)
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
        let target = library.asset(withID: asset.localIdentifier) ?? asset
        Task { try? await library.setFavorite(target, to: now) }
    }

    /// 刪除：跟整理一樣先放進待刪清單，不會直接刪掉。這張從檢視裡拿掉，換到相鄰的一張；沒有了就關閉。
    private func deleteCurrent() {
        guard let asset = current, let index = assets.firstIndex(where: { $0.localIdentifier == currentID }) else { return }
        model.markTrashed(asset.localIdentifier)
        var remaining = assets
        remaining.remove(at: index)
        guard !remaining.isEmpty else { dismiss(); return }
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

            if let image {
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
