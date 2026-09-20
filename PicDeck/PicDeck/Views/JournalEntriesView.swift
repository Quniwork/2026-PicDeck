import SwiftUI
import Photos

/// 日記分頁：只列出有寫日記的日子。
struct JournalEntriesView: View {
    @EnvironmentObject private var journalStore: JournalStore

    /// 點日期或編輯鈕時開啟編輯。
    let onEdit: (Int, Int, Int) -> Void
    /// 目前篩選到的紀念日標籤，會顯示在日期下方。
    var anniversaryTag: PhotoTag? = nil
    /// 目前篩選允許的照片。nil 代表沒有篩選，全部都顯示。
    var allowedPhotoIDs: Set<String>? = nil

    /// 右側拖拉軸。依目前看得到的日記重新算。
    private var scrub: ScrubIndex {
        let anchors = visibleEntries.compactMap { entry -> ScrubAnchor? in
            guard let parts = JournalStore.components(fromKey: entry.id) else { return nil }
            var components = DateComponents()
            components.year = parts.year
            components.month = parts.month
            components.day = parts.day
            guard let date = PhotoGrouping.calendar.date(from: components) else { return nil }
            return ScrubAnchor(id: entry.id, date: date, count: 1)
        }
        return ScrubIndex(anchors: anchors, itemsPerScreen: 3)
    }

    /// 篩選中時，只留下有照片落在篩選結果裡的日記。
    private var visibleEntries: [JournalEntry] {
        guard let allowedPhotoIDs else { return journalStore.sortedEntries }
        return journalStore.sortedEntries.filter { entry in
            entry.photoIDs.contains { allowedPhotoIDs.contains($0) }
        }
    }

    var body: some View {
        Group {
            if visibleEntries.isEmpty {
                ContentUnavailableView {
                    Label("No journal entries", systemImage: "square.and.pencil")
                } description: {
                    if allowedPhotoIDs == nil {
                        Text("Long press a photo and choose Write journal to add one.")
                    } else {
                        Text("No journal entries match this filter.")
                    }
                }
            } else {
                AnchoredScrollView(anchorID: nil, isReady: true, scrub: scrub) {
                    LazyVStack(spacing: 14) {
                        ForEach(visibleEntries) { entry in
                            JournalEntryRow(entry: entry, anniversaryTag: anniversaryTag) {
                                guard let parts = JournalStore.components(fromKey: entry.id) else { return }
                                onEdit(parts.year, parts.month, parts.day)
                            }
                            .id(entry.id)
                            .accessibilityIdentifier("journal.entry.\(entry.id)")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .background(Color(.systemGroupedBackground))
            }
        }
    }
}

/// 一篇日記，做成一張卡片。版面由上到下是：
/// 心情與日期、紀念日、文字、照片。
///
/// 文字太長時收成五行，可以展開。照片一排四張，
/// 超過四張時第四張標示還有幾張，點它展開全部；展開後再點同一張就是放大。
struct JournalEntryRow: View {
    let entry: JournalEntry
    var anniversaryTag: PhotoTag? = nil
    let onEdit: () -> Void

    @EnvironmentObject private var library: PhotoLibraryService

    @State private var assets: [PHAsset] = []
    @State private var isPhotosExpanded = false
    @State private var isTextExpanded = false
    @State private var zoomAsset: PHAsset?

    private let maxCollapsed = 4
    private let collapsedLines = 5
    /// 超過這個長度才給展開按鈕，不用去量實際有沒有被截斷。
    private let longTextThreshold = 110

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 4)

    private var visibleAssets: [PHAsset] {
        isPhotosExpanded ? assets : Array(assets.prefix(maxCollapsed))
    }

    /// 收合狀態下還沒顯示的張數。
    private var hiddenCount: Int {
        isPhotosExpanded ? 0 : max(0, assets.count - maxCollapsed)
    }

    private var isLongText: Bool {
        entry.text.count > longTextThreshold
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            if !entry.text.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.text)
                        .font(.subheadline)
                        .lineSpacing(3)
                        .lineLimit(isTextExpanded ? nil : collapsedLines)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if isLongText {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { isTextExpanded.toggle() }
                        } label: {
                            Text(isTextExpanded ? "Show less" : "Show more")
                                .font(.caption.weight(.semibold))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.tint)
                        .accessibilityIdentifier("journal.text.toggle")
                    }
                }
            }

            if !assets.isEmpty {
                photoGrid
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 16))
        .task(id: entry.photoIDs) {
            assets = library.assets(withIDs: entry.photoIDs)
            isPhotosExpanded = false
            isTextExpanded = false
        }
        .fullScreenCover(item: $zoomAsset) { asset in
            ZoomedPhotoView(asset: asset)
        }
    }

    // MARK: - 標題

    private var header: some View {
        HStack(alignment: .top, spacing: 10) {
            // 心情。沒選心情時留一個淡淡的預設圖示，版面才不會忽大忽小。
            ZStack {
                Circle()
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 38, height: 38)
                IconLabel(raw: entry.mood, size: 20, placeholder: "text.alignleft")
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(title)
                        .font(.headline)
                    Text(weekday)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let date {
                    AnniversaryChips(date: date, tag: anniversaryTag)
                }
            }

            Spacer(minLength: 0)

            Button(action: onEdit) {
                Image(systemName: "square.and.pencil")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(6)
                    .background(Color(.tertiarySystemFill), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("journal.edit")
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onEdit)
    }

    // MARK: - 照片

    private var photoGrid: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(Array(visibleAssets.enumerated()), id: \.element.localIdentifier) { index, asset in
                thumbnail(asset, index: index)
            }
            // 收合時不足四張就補空位，縮圖才不會被撐大。
            if !isPhotosExpanded && visibleAssets.count < maxCollapsed {
                ForEach(0..<(maxCollapsed - visibleAssets.count), id: \.self) { _ in
                    Color.clear.aspectRatio(1, contentMode: .fit)
                }
            }
        }
    }

    private func thumbnail(_ asset: PHAsset, index: Int) -> some View {
        let isExpandTrigger = hiddenCount > 0 && index == maxCollapsed - 1

        return AssetThumbnail(asset: asset, size: 100, showsDuration: false)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                if isExpandTrigger {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).fill(.black.opacity(0.45))
                        Text("+\(hiddenCount)")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if isExpandTrigger {
                    // 第一次點第四張：展開看全部。
                    withAnimation(.easeInOut(duration: 0.2)) { isPhotosExpanded = true }
                } else {
                    // 其餘情況一律放大，包含展開後再點同一張。
                    zoomAsset = asset
                }
            }
            .accessibilityIdentifier(isExpandTrigger ? "journal.expand" : "journal.photo.\(index)")
    }

    // MARK: - 日期

    private var date: Date? {
        guard let parts = JournalStore.components(fromKey: entry.id) else { return nil }
        var components = DateComponents()
        components.year = parts.year
        components.month = parts.month
        components.day = parts.day
        return PhotoGrouping.calendar.date(from: components)
    }

    private var title: String {
        guard let parts = JournalStore.components(fromKey: entry.id) else { return entry.id }
        return DateTitle.dayMedium(year: parts.year, month: parts.month, day: parts.day)
    }

    private var weekday: String {
        guard let date else { return "" }
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE")
        return formatter.string(from: date)
    }
}
