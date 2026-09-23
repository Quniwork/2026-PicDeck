import SwiftUI
import Photos

private struct ScrollContentMinYKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

private struct ScrollVisibleMetrics: Equatable {
    let offset: CGFloat
    let viewportHeight: CGFloat
}

/// 會自動捲到指定錨點的捲動容器。
/// 定位完成前先把內容藏起來，避免看到畫面從頂端跳到目標位置的閃動。
struct AnchoredScrollView<Content: View>: View {
    /// 要捲到的區段 id，nil 表示從頂端開始。
    let anchorID: String?
    /// 資料是否已載入，還沒載好就不要定位。
    let isReady: Bool
    /// 右側拖拉軸要用的落點。沒給就不顯示。
    var scrub: ScrubIndex? = nil
    var scrubTopInset: CGFloat = 10
    var onScrollOffsetChange: ((CGFloat, CGFloat) -> Void)? = nil
    var scrollToAnchor: UnitPoint = .top
    @ViewBuilder let content: () -> Content

    @State private var isPositioned = false
    /// 拖拉軸用。放在 @State 裡但這個 View 不訂閱它，捲動時只有拖拉軸自己會更新。
    @State private var scrubController = ScrubController()

    private var needsPositioning: Bool { anchorID != nil }
    private var isHidden: Bool { needsPositioning && !isPositioned }

    var body: some View {
        ScrollViewReader { proxy in
            // 有拖拉把手的畫面就不用系統捲軸，兩個並排會打架。
            let scrollView = ScrollView(showsIndicators: !(scrub?.isUsable ?? false)) {
                content()
                    .trackedByScrubber(scrubController)
                    .background {
                        GeometryReader { geometry in
                            Color.clear.preference(key: ScrollContentMinYKey.self,
                                                   value: geometry.frame(in: .named("anchored-scroll-content")).minY)
                        }
                    }
            }
            .coordinateSpace(name: "anchored-scroll-content")

            Group {
                if #available(iOS 18.0, *) {
                    scrollView.onScrollGeometryChange(for: ScrollVisibleMetrics.self) { geometry in
                        ScrollVisibleMetrics(offset: geometry.contentOffset.y,
                                             viewportHeight: geometry.containerSize.height)
                    } action: { _, metrics in
                        onScrollOffsetChange?(metrics.offset, metrics.viewportHeight)
                    }
                } else {
                    scrollView
                }
            }
            .onPreferenceChange(ScrollContentMinYKey.self) { minY in
                if #unavailable(iOS 18.0) { onScrollOffsetChange?(-minY, 0) }
            }
            .opacity(isHidden ? 0 : 1)
            .overlay {
                if isHidden { ProgressView() }
            }
            .overlay(alignment: .trailing) {
                if let scrub, scrub.isUsable, !isHidden {
                    ScrubberOverlay(index: scrub, controller: scrubController, topInset: scrubTopInset)
                }
            }
            .task(id: "\(anchorID ?? "")-\(isReady)") {
                guard let anchorID else {
                    isPositioned = true
                    return
                }
                guard isReady else { return }

                isPositioned = false
                // 讓延遲載入的版面先排好，否則捲不到還沒實體化的區段。
                await Task.yield()
                try? await Task.sleep(nanoseconds: 120_000_000)
                proxy.scrollTo(anchorID, anchor: scrollToAnchor)
                try? await Task.sleep(nanoseconds: 80_000_000)
                withMotion(.easeIn(duration: 0.12)) { isPositioned = true }
            }
        }
    }
}

/// 分組卡片的格狀清單，年、月、日三個層級共用。
struct BucketGridView: View {
    let buckets: [PhotoGrouping.Bucket]
    var minimum: CGFloat = 100
    var columns: Int? = nil
    var compact: Bool = false
    var onScrollOffsetChange: ((CGFloat) -> Void)? = nil
    let onSelect: (PhotoGrouping.Bucket) -> Void

    var body: some View {
        AnchoredScrollView(anchorID: nil, isReady: true,
                           onScrollOffsetChange: { offset, _ in onScrollOffsetChange?(offset) }) {
            LazyVGrid(columns: gridColumns,
                      spacing: compact ? 12 : 16) {
                ForEach(buckets) { bucket in
                    Button {
                        onSelect(bucket)
                    } label: {
                        BucketCard(bucket: bucket, compact: compact, titleColumnCount: columns)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("bucket.\(bucket.id)")
                }
            }
            .padding(.horizontal, PageMetrics.edge)
            .padding(.top, PageMetrics.contentTopGap)
            .padding(.bottom, 28)
        }
    }

    private var gridColumns: [GridItem] {
        guard let columns else {
            return [GridItem(.adaptive(minimum: minimum), spacing: compact ? 8 : 12)]
        }
        return Array(repeating: GridItem(.flexible(), spacing: compact ? 8 : 12), count: max(1, columns))
    }
}

/// 純格狀瀏覽，不帶日期資訊（對應參考 App 的「緊湊」）。
struct CompactGridView: View {
    let assets: [PHAsset]
    var columns: Int = 4
    var fitsAspect: Bool = false
    var onOpen: ((PHAsset) -> Void)? = nil
    /// 長按照片時要顯示的操作選單。
    var actions: ((PHAsset) -> AnyView?)? = nil
    /// 多選模式。
    var isSelecting: Bool = false
    var selectedIDs: Binding<Set<String>>? = nil
    /// 右側拖拉軸。
    var scrub: ScrubIndex? = nil
    var onVisibleDateRangeChange: ((CGFloat, Date?, Date?) -> Void)? = nil
    /// 點開要從縮圖位置展開，跟呼叫端共用同一個 namespace。
    var zoomNamespace: Namespace.ID? = nil

    var body: some View {
        GeometryReader { proxy in
            let safeColumns = max(columns, 1)
            let cellWidth = max(1, (proxy.size.width - CGFloat(safeColumns - 1) * 2) / CGFloat(safeColumns))
            AnchoredScrollView(anchorID: assets.last?.localIdentifier, isReady: !assets.isEmpty, scrub: scrub,
                               scrubTopInset: 160,
                               onScrollOffsetChange: { offset, viewportHeight in
                let cellExtent = cellWidth + 2
                let firstRow = max(0, Int(max(0, offset) / max(cellExtent, 1)))
                let visibleHeight = viewportHeight > 0 ? viewportHeight : proxy.size.height
                let lastRow = max(firstRow, Int((max(0, offset) + visibleHeight) / max(cellExtent, 1)))
                let firstIndex = min(firstRow * safeColumns, assets.count - 1)
                let lastIndex = min((lastRow + 1) * safeColumns - 1, assets.count - 1)
                let firstDate = assets.indices.contains(firstIndex) ? assets[firstIndex].creationDate : nil
                let lastDate = assets.indices.contains(lastIndex) ? assets[lastIndex].creationDate : nil
                onVisibleDateRangeChange?(offset, firstDate, lastDate)
            }, scrollToAnchor: .bottom) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2,
                                                             alignment: fitsAspect ? .top : .center), count: safeColumns),
                          spacing: 2) {
                    ForEach(assets, id: \.localIdentifier) { asset in
                        thumbnail(asset, size: cellWidth)
                    }
                }
                .padding(.top, assets.count > max(columns, 1) * 4 ? 0 : 12)
            }
            .softScrollEdges()
            // A short library cannot scroll its first row back out from under the title.
            .ignoresSafeArea(edges: assets.count > max(columns, 1) * 4 ? .top : [])
        }
    }

    private func thumbnail(_ asset: PHAsset, size: CGFloat) -> some View {
        SelectableThumbnail(asset: asset,
                            size: size,
                            isSelecting: isSelecting,
                            isSelected: selectedIDs?.wrappedValue.contains(asset.localIdentifier) ?? false,
                            onToggle: { toggle(asset) },
                            menu: { actions?(asset) },
                            fitsAspect: fitsAspect,
                            onOpen: { onOpen?(asset) },
                            zoomNamespace: zoomNamespace)
            .id(asset.localIdentifier)
    }

    private func toggle(_ asset: PHAsset) {
        guard let selectedIDs else { return }
        let id = asset.localIdentifier
        if selectedIDs.wrappedValue.contains(id) {
            selectedIDs.wrappedValue.remove(id)
        } else {
            selectedIDs.wrappedValue.insert(id)
        }
    }
}

extension View {
    /// 長按照片跳出操作選單，內容由呼叫端決定。
    @ViewBuilder
    func photoActions<Menu: View>(@ViewBuilder _ menu: () -> Menu?) -> some View {
        if let content = menu() {
            self.contextMenu { content }
        } else {
            self
        }
    }
}

/// 依日期分段的瀏覽，每段有日期標題與張數（對應參考 App 的「展開」）。
struct TimelineView: View {
    let sections: [PhotoGrouping.DaySection]
    /// 指定要捲到哪一天，之後仍可上下滑動看其他天。
    var focusSectionID: String? = nil
    /// 長按照片時要顯示的操作選單。
    var actions: ((PHAsset) -> AnyView?)? = nil
    /// 多選模式。
    var isSelecting: Bool = false
    var selectedIDs: Binding<Set<String>>? = nil
    /// 目前篩選到的紀念日標籤，會顯示在每一天的日期標題下方。
    var anniversaryTag: PhotoTag? = nil
    /// 右側拖拉軸。
    var scrub: ScrubIndex? = nil
    /// 每列幾張、是否依原比例顯示。
    var columnCount: Int = 4
    var fitsAspect: Bool = false
    var onScrollOffsetChange: ((CGFloat) -> Void)? = nil
    var onOpen: ((PHAsset) -> Void)? = nil
    /// 點開要從縮圖位置展開，跟呼叫端共用同一個 namespace。
    var zoomNamespace: Namespace.ID? = nil

    private var columns: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 2), count: columnCount) }

    var body: some View {
        AnchoredScrollView(anchorID: focusSectionID, isReady: !sections.isEmpty, scrub: scrub,
                           onScrollOffsetChange: { offset, _ in onScrollOffsetChange?(offset) }) {
            LazyVStack(alignment: .leading, spacing: PageMetrics.photoSectionSpacing) {
                ForEach(sections) { section in
                    daySection(section)
                        .id(section.id)
                }
            }
            .padding(.top, PageMetrics.contentTopGap)
            .padding(.bottom, 20)
        }
    }

    private func daySection(_ section: PhotoGrouping.DaySection) -> some View {
        VStack(alignment: .leading, spacing: PageMetrics.photoSectionGap) {
            header(for: section)

            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(section.assets, id: \.localIdentifier) { asset in
                    SelectableThumbnail(asset: asset,
                                        size: columnCount >= 6 ? 100 : (columnCount >= 4 ? 130 : 220),
                                        isSelecting: isSelecting,
                                        isSelected: selectedIDs?.wrappedValue.contains(asset.localIdentifier) ?? false,
                                        onToggle: { toggle(asset) },
                                        menu: { actions?(asset) },
                                        fitsAspect: fitsAspect,
                                        onOpen: { onOpen?(asset) },
                                        zoomNamespace: zoomNamespace)
                }
            }
        }
        .padding(.horizontal, PageMetrics.edge)
    }

    private func toggle(_ asset: PHAsset) {
        guard let selectedIDs else { return }
        let id = asset.localIdentifier
        if selectedIDs.wrappedValue.contains(id) {
            selectedIDs.wrappedValue.remove(id)
        } else {
            selectedIDs.wrappedValue.insert(id)
        }
    }

    /// 有篩選到紀念日標籤：「6年4個月5天 2026年1月4日 星期六」。
    /// 沒有：「2026年1月4日 星期六」。標籤名稱不重複顯示，標題已經是那個標籤了。
    private func header(for section: PhotoGrouping.DaySection) -> some View {
        let elapsed = anniversaryTag?.anniversaryText(on: section.date)

        return HStack(alignment: .firstTextBaseline, spacing: 8) {
            if let elapsed {
                Text(elapsed)
                    .font(TypeScale.photoSectionTitle)
                    .accessibilityIdentifier("anniversary.chip")
                Text("\(section.title) \(section.weekday)")
                    .font(TypeScale.subtitle)
                    .foregroundStyle(.secondary)
            } else {
                Text(section.title)
                    .font(TypeScale.photoSectionTitle)
                Text(section.weekday)
                    .font(TypeScale.subtitle)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            if elapsed == nil {
                Text("\(section.count)")
                    .font(TypeScale.subtitle)
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 共用元件

/// 一張分組封面卡片：封面圖、張數、標題。
struct BucketCard: View {
    let bucket: PhotoGrouping.Bucket
    var compact: Bool = false
    var titleColumnCount: Int? = nil
    @ScaledMetric(relativeTo: .headline) private var baseYearTitleSize: CGFloat = 17

    private var titleOverCover: Bool { titleColumnCount != nil }
    /// Keep the widest year tile at a landscape thumbnail proportion, like the largest Library tiles.
    private var coverAspectRatio: CGFloat { titleColumnCount == 1 ? 4.0 / 3.0 : 1 }
    private var yearTitleSize: CGFloat {
        guard let titleColumnCount else { return baseYearTitleSize }
        let scale = min(3 / CGFloat(max(titleColumnCount, 1)), 1.5)
        return baseYearTitleSize * scale
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                if let coverID = bucket.coverID {
                    CoverImage(assetID: coverID, size: compact ? 90 : 140)
                        .aspectRatio(coverAspectRatio, contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: compact ? 10 : 12))
                } else {
                    RoundedRectangle(cornerRadius: compact ? 10 : 12)
                        .fill(Color(.secondarySystemBackground))
                        .aspectRatio(coverAspectRatio, contentMode: .fit)
                }

                if titleOverCover {
                    RoundedRectangle(cornerRadius: compact ? 10 : 12)
                        .fill(LinearGradient(colors: [.clear, .black.opacity(0.48)],
                                             startPoint: .center, endPoint: .bottom))
                        .allowsHitTesting(false)

                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(bucket.title)
                            .font(.system(size: yearTitleSize, weight: .semibold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.55), radius: 3, y: 1)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)

                        Spacer(minLength: 0)

                        countLabel
                    }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                } else {
                    countLabel
                        .padding(5)
                }
            }

            if !titleOverCover {
                Text(bucket.title)
                    .font(compact ? .caption2 : .caption)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
        }
    }

    private var countLabel: some View {
        Text("\(bucket.count)")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.black.opacity(0.45), in: Capsule())
    }
}

/// 依 localIdentifier 取回照片再顯示縮圖。
struct CoverImage: View {
    let assetID: String
    var size: CGFloat

    @State private var image: UIImage?

    var body: some View {
        Rectangle()
            .fill(Color(.secondarySystemBackground))
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                }
            }
            .clipped()
            .task(id: assetID) {
                guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetID],
                                                      options: nil).firstObject else { return }
                image = await ThumbnailLoader.shared.image(for: asset, size: size)
            }
    }
}
