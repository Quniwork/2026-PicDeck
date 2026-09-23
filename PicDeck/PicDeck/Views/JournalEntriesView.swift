import SwiftUI
import Photos

/// 同一天的日記疊在一起。
private struct JournalDayGroup: Identifiable {
    let dateKey: String
    let entries: [JournalEntry]
    var id: String { dateKey }
}

/// 日記分頁：依日期分組，同一天寫的好幾篇疊在同一個日期底下。
struct JournalEntriesView: View {
    @EnvironmentObject private var journalStore: JournalStore

    /// 點某一篇（或它的編輯選單）時開啟編輯。
    let onEdit: (JournalEntry) -> Void
    /// 點日期旁邊的「＋」，新增這一天的另一篇。
    let onAddForDay: (Int, Int, Int) -> Void
    /// 目前篩選到的紀念日標籤，會顯示在日期下方。
    var anniversaryTag: PhotoTag? = nil
    /// 目前篩選允許的照片。nil 代表沒有篩選，全部都顯示。
    var allowedPhotoIDs: Set<String>? = nil
    /// 目前篩選的分類。nil 代表沒有篩選。
    var categoryID: JournalCategory.ID? = nil
    /// 由新到舊（預設）或由舊到新。
    var newestFirst: Bool = true
    /// 照片每列幾張、是否依原比例顯示。
    var columnCount: Int = 4
    var fitsAspect: Bool = false

    private var isFiltering: Bool { allowedPhotoIDs != nil || categoryID != nil }

    /// 篩選中時，只留下符合照片、符合分類的日記。
    private var visibleEntries: [JournalEntry] {
        // sortedEntries 是由新到舊（同一天內由先寫到後寫）；要由舊到新就把「天」的順序反過來，天內順序不變。
        let ordered = newestFirst ? journalStore.sortedEntries : reversedByDay(journalStore.sortedEntries)
        return ordered.filter { entry in
            if let allowedPhotoIDs, !entry.photoIDs.contains(where: { allowedPhotoIDs.contains($0) }) { return false }
            if let categoryID, entry.categoryID != categoryID { return false }
            return true
        }
    }

    /// 只把「天」的順序反過來，天底下的先後順序維持不變（新增在下面）。
    private func reversedByDay(_ entries: [JournalEntry]) -> [JournalEntry] {
        var groups: [(key: String, items: [JournalEntry])] = []
        for entry in entries {
            if groups.last?.key == entry.dateKey {
                groups[groups.count - 1].items.append(entry)
            } else {
                groups.append((entry.dateKey, [entry]))
            }
        }
        return groups.reversed().flatMap(\.items)
    }

    /// 連續同一天的分到同一組，組的順序不變（sortedEntries 已經照天分好段）。
    private var groups: [JournalDayGroup] {
        var result: [JournalDayGroup] = []
        for entry in visibleEntries {
            if result.last?.dateKey == entry.dateKey {
                result[result.count - 1] = JournalDayGroup(dateKey: entry.dateKey,
                                                            entries: result[result.count - 1].entries + [entry])
            } else {
                result.append(JournalDayGroup(dateKey: entry.dateKey, entries: [entry]))
            }
        }
        return result
    }

    /// 右側拖拉軸，一天一個落點。
    private var scrub: ScrubIndex {
        ScrubIndex(anchors: groups.compactMap { group -> ScrubAnchor? in
            guard let parts = JournalStore.components(fromKey: group.dateKey) else { return nil }
            var components = DateComponents()
            components.year = parts.year
            components.month = parts.month
            components.day = parts.day
            guard let date = PhotoGrouping.calendar.date(from: components) else { return nil }
            return ScrubAnchor(date: date, weight: 1)
        })
    }

    var body: some View {
        Group {
            if visibleEntries.isEmpty {
                AppEmptyState(icon: "book.closed",
                              title: String(localized: "No journal entries"),
                              message: isFiltering
                                ? String(localized: "No journal entries match this filter.")
                                : String(localized: "Time to add a journal entry!"))
            } else {
                AnchoredScrollView(anchorID: nil, isReady: true, scrub: scrub) {
                    LazyVStack(alignment: .leading, spacing: PageMetrics.gapXL) {
                        ForEach(groups) { group in
                            dayGroup(group)
                                .id(group.dateKey)
                        }
                    }
                    .padding(.horizontal, PageMetrics.edge)
                    .padding(.top, PageMetrics.contentTopGap)
                    .padding(.bottom, 16)
                }
            }
        }
        // 空狀態跟有內容時背景要一樣，不然切換時（或跟選集比較）顏色會跳一下。
        .background(Color(.systemBackground))
    }

    private func dayGroup(_ group: JournalDayGroup) -> some View {
        let parts = JournalStore.components(fromKey: group.dateKey)
        return VStack(alignment: .leading, spacing: PageMetrics.gapSM) {
            dayHeader(year: parts?.year ?? 1970, month: parts?.month ?? 1, day: parts?.day ?? 1)
            VStack(spacing: PageMetrics.gapSM) {
                ForEach(group.entries) { entry in
                    JournalEntryRow(entry: entry, anniversaryTag: anniversaryTag,
                                    columnCount: columnCount, fitsAspect: fitsAspect) {
                        onEdit(entry)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
                    .accessibilityIdentifier("journal.entry.\(entry.id)")
                }
            }
        }
    }

    private func dayHeader(year: Int, month: Int, day: Int) -> some View {
        let date = PhotoGrouping.calendar.date(from: DateComponents(year: year, month: month, day: day))
        let weekday: String = {
            guard let date else { return "" }
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("EEEE")
            return formatter.string(from: date)
        }()
        return HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(DateTitle.dayMedium(year: year, month: month, day: day))
                .font(.headline)
            Text(weekday)
                .font(.caption)
                .foregroundStyle(.secondary)
            if let date {
                AnniversaryChips(date: date, tag: anniversaryTag)
            }
            Spacer(minLength: 0)
            Button { onAddForDay(year, month, day) } label: {
                Image(systemName: "plus")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 44, height: 44)
                    .background(Color(.secondarySystemFill), in: Circle())
            }
            .accessibilityLabel(Text("New entry for this day"))
            .accessibilityIdentifier("journal.addForDay")
        }
    }
}

/// 一篇日記，做成一張卡片。版面由上到下是：心情與分類、文字、照片。
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
    /// 點照片打開檢視時，從縮圖位置展開。
    @Namespace private var photoZoom

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

    private var category: JournalCategory? { journalStore.category(withID: entry.categoryID) }

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
        .background(Color(.secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 16))
        .task(id: entry.photoIDs) {
            assets = library.assets(withIDs: entry.photoIDs)
            isPhotosExpanded = false
            isTextExpanded = false
        }
        .confirmationDialog(String(localized: "Delete entry"), isPresented: $confirmDelete,
                            titleVisibility: .visible) {
            Button(String(localized: "Delete entry"), role: .destructive) {
                journalStore.delete(id: entry.id)
            }
        }
        // 點日記裡的照片：跟照片分頁點一張一樣的全螢幕檢視，只是沒有「日記」。
        .fullScreenCover(item: $zoomAsset) { asset in
            PhotoDetailView(assets: assets, startID: asset.localIdentifier, showsJournal: false)
                .zoomDestination(id: asset.localIdentifier, in: photoZoom)
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

            if let category {
                HStack(spacing: 4) {
                    IconLabel(raw: category.symbol, size: 12)
                    Text(category.name)
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(.tertiarySystemFill), in: Capsule())
                .accessibilityIdentifier("journal.entry.category")
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
                    .frame(width: 44, height: 44)
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
            .zoomSource(id: asset.localIdentifier, in: photoZoom)
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
}
