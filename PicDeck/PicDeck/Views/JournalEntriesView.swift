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
    /// 由新到舊（預設）或由舊到新。
    var newestFirst: Bool = true
    /// 照片每列幾張、是否依原比例顯示。
    var columnCount: Int = 4
    var fitsAspect: Bool = false

    /// 右側拖拉軸。依目前看得到的日記重新算。
    private var scrub: ScrubIndex {
        ScrubIndex(anchors: visibleEntries.compactMap { entry -> ScrubAnchor? in
            guard let parts = JournalStore.components(fromKey: entry.id) else { return nil }
            var components = DateComponents()
            components.year = parts.year
            components.month = parts.month
            components.day = parts.day
            guard let date = PhotoGrouping.calendar.date(from: components) else { return nil }
            return ScrubAnchor(date: date, weight: 1)
        })
    }

    /// 篩選中時，只留下有照片落在篩選結果裡的日記。
    private var visibleEntries: [JournalEntry] {
        // sortedEntries 是由新到舊；要由舊到新就反過來。
        let ordered = newestFirst ? journalStore.sortedEntries : journalStore.sortedEntries.reversed()
        guard let allowedPhotoIDs else { return Array(ordered) }
        return ordered.filter { entry in
            entry.photoIDs.contains { allowedPhotoIDs.contains($0) }
        }
    }

    var body: some View {
        Group {
            if visibleEntries.isEmpty {
                ContentUnavailableView {
                    Label("No journal entries", systemImage: "book.closed")
                } description: {
                    // 新增在右上角的「＋」，這裡只是提醒。副標比預設小兩級。
                    Group {
                        if allowedPhotoIDs == nil {
                            Text("Time to add a journal entry!")
                        } else {
                            Text("No journal entries match this filter.")
                        }
                    }
                    .font(.footnote)
                }
            } else {
                AnchoredScrollView(anchorID: nil, isReady: true, scrub: scrub) {
                    LazyVStack(spacing: 8) {
                        ForEach(visibleEntries) { entry in
                            JournalEntryRow(entry: entry, anniversaryTag: anniversaryTag,
                                            columnCount: columnCount, fitsAspect: fitsAspect) {
                                guard let parts = JournalStore.components(fromKey: entry.id) else { return }
                                onEdit(parts.year, parts.month, parts.day)
                            }
                            .id(entry.id)
                            .transition(.opacity.combined(with: .scale(scale: 0.97)))
                            .accessibilityIdentifier("journal.entry.\(entry.id)")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, PageMetrics.contentTopGap)
                    .padding(.bottom, 16)
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
    var columnCount: Int = 4
    var fitsAspect: Bool = false
    let onEdit: () -> Void

    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var journalStore: JournalStore

    @State private var confirmDelete = false
    @State private var assets: [PHAsset] = []
    @State private var isPhotosExpanded = false
    @State private var isTextExpanded = false
    @State private var zoomAsset: PHAsset?

    /// 收合時只放一列。
    private var maxCollapsed: Int { columnCount }
    private let collapsedLines = 5
    /// 超過這個長度才給展開按鈕，不用去量實際有沒有被截斷。
    private let longTextThreshold = 110

    private var columns: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 2), count: columnCount) }

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
                            withMotion(.easeInOut(duration: 0.2)) { isTextExpanded.toggle() }
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
        .confirmationDialog(String(localized: "Delete entry"), isPresented: $confirmDelete,
                            titleVisibility: .visible) {
            Button(String(localized: "Delete entry"), role: .destructive) {
                journalStore.delete(forKey: entry.id)
            }
        }
        // 點日記裡的照片：跟照片分頁點一張一樣的全螢幕檢視，只是沒有「日記」。
        .fullScreenCover(item: $zoomAsset) { asset in
            PhotoDetailView(assets: assets, startID: asset.localIdentifier, showsJournal: false)
        }
    }

    // MARK: - 標題

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
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

            // 沒有底色的「…」，點開選編輯或刪除。
            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "square.and.pencil")
                }
                Button(role: .destructive) {
                    confirmDelete = true
                } label: {
                    Label("Delete", systemImage: "xmark")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            // 選單預設會染成主題藍，這顆要灰色。
            .tint(Color.secondary)
            .accessibilityLabel(Text("More"))
            .accessibilityIdentifier("journal.edit")
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onEdit)
    }

    // MARK: - 照片

    private var photoGrid: some View {
        LazyVGrid(columns: columns, spacing: 2) {
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

        return AssetThumbnail(asset: asset, size: columnCount >= 6 ? 100 : (columnCount >= 4 ? 130 : 220),
                              showsDuration: false, fitsAspect: fitsAspect)
            .clipped()
            .overlay {
                if isExpandTrigger {
                    ZStack {
                        Rectangle().fill(.black.opacity(0.45))
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
                    withMotion(.easeInOut(duration: 0.2)) { isPhotosExpanded = true }
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
