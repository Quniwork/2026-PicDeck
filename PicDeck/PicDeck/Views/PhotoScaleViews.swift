import SwiftUI
import Photos

/// 會自動捲到指定錨點的捲動容器。
/// 定位完成前先把內容藏起來，避免看到畫面從頂端跳到目標位置的閃動。
struct AnchoredScrollView<Content: View>: View {
    /// 要捲到的區段 id，nil 表示從頂端開始。
    let anchorID: String?
    /// 資料是否已載入，還沒載好就不要定位。
    let isReady: Bool
    /// 右側拖拉軸要用的落點。沒給就不顯示。
    var scrub: ScrubIndex? = nil
    @ViewBuilder let content: () -> Content

    @State private var isPositioned = false

    private var needsPositioning: Bool { anchorID != nil }
    private var isHidden: Bool { needsPositioning && !isPositioned }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                content()
            }
            .opacity(isHidden ? 0 : 1)
            .overlay {
                if isHidden { ProgressView() }
            }
            .overlay(alignment: .trailing) {
                if let scrub, scrub.isUsable, !isHidden {
                    ScrubberOverlay(index: scrub, proxy: proxy)
                        .frame(width: 150)
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
                proxy.scrollTo(anchorID, anchor: .top)
                try? await Task.sleep(nanoseconds: 80_000_000)
                withAnimation(.easeIn(duration: 0.12)) { isPositioned = true }
            }
        }
    }
}

/// 分組卡片的格狀清單，年、月、日三個層級共用。
struct BucketGridView: View {
    let buckets: [PhotoGrouping.Bucket]
    var minimum: CGFloat = 100
    var compact: Bool = false
    let onSelect: (PhotoGrouping.Bucket) -> Void

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: minimum), spacing: compact ? 8 : 12)],
                      spacing: compact ? 12 : 16) {
                ForEach(buckets) { bucket in
                    Button {
                        onSelect(bucket)
                    } label: {
                        BucketCard(bucket: bucket, compact: compact)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("bucket.\(bucket.id)")
                }
            }
            .padding(compact ? 12 : 16)
            .padding(.bottom, 28)
        }
    }
}

/// 純格狀瀏覽，不帶日期資訊（對應參考 App 的「緊湊」）。
struct CompactGridView: View {
    let assets: [PHAsset]
    var columns: Int = 4
    /// 長按照片時要顯示的操作選單。
    var actions: ((PHAsset) -> AnyView?)? = nil
    /// 多選模式。
    var isSelecting: Bool = false
    var selectedIDs: Binding<Set<String>>? = nil
    /// 右側拖拉軸。
    var scrub: ScrubIndex? = nil

    var body: some View {
        AnchoredScrollView(anchorID: nil, isReady: !assets.isEmpty, scrub: scrub) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: columns),
                      spacing: 2) {
                ForEach(assets, id: \.localIdentifier) { asset in
                    SelectableThumbnail(asset: asset,
                                        size: columns == 4 ? 100 : 130,
                                        isSelecting: isSelecting,
                                        isSelected: selectedIDs?.wrappedValue.contains(asset.localIdentifier) ?? false,
                                        onToggle: { toggle(asset) },
                                        menu: { actions?(asset) })
                        .id(asset.localIdentifier)
                }
            }
            .padding(.horizontal, 2)
        }
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

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 4)

    var body: some View {
        AnchoredScrollView(anchorID: focusSectionID, isReady: !sections.isEmpty, scrub: scrub) {
            LazyVStack(alignment: .leading, spacing: 18, pinnedViews: [.sectionHeaders]) {
                ForEach(sections) { section in
                    Section {
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(section.assets, id: \.localIdentifier) { asset in
                                SelectableThumbnail(asset: asset,
                                                    size: 100,
                                                    isSelecting: isSelecting,
                                                    isSelected: selectedIDs?.wrappedValue.contains(asset.localIdentifier) ?? false,
                                                    onToggle: { toggle(asset) },
                                                    menu: { actions?(asset) })
                            }
                        }
                        .padding(.horizontal, 2)
                    } header: {
                        header(for: section)
                    }
                    .id(section.id)
                }
            }
            .padding(.bottom, 20)
        }
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

    private func header(for section: PhotoGrouping.DaySection) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(section.title)
                    .font(.headline)
                Text(section.weekday)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(section.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            // 篩選到紀念日標籤時，顯示那天過了多久。
            AnniversaryChips(date: section.date, tag: anniversaryTag)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.bar)
    }
}

// MARK: - 共用元件

/// 一張分組封面卡片：封面圖、張數、標題。
struct BucketCard: View {
    let bucket: PhotoGrouping.Bucket
    var compact: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                if let coverID = bucket.coverID {
                    CoverImage(assetID: coverID, size: compact ? 90 : 140)
                        .aspectRatio(1, contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: compact ? 10 : 12))
                } else {
                    RoundedRectangle(cornerRadius: compact ? 10 : 12)
                        .fill(Color(.secondarySystemBackground))
                        .aspectRatio(1, contentMode: .fit)
                }

                Text("\(bucket.count)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.black.opacity(0.45), in: Capsule())
                    .padding(5)
            }

            Text(bucket.title)
                .font(compact ? .caption2 : .caption)
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
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
