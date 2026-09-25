import SwiftUI
import Photos

/// 首頁：把最常想看的東西集中在一頁。
///
/// - 日子：設了日期的標籤，卡片直接顯示「今天過了多久」，點進去就是那個標籤的照片。
/// - 標籤：其餘的標籤，卡片是封面與張數。
/// - 標籤：只有釘在首頁的標籤才會出現，例如 #美食，點進去看存下來的照片與備註，可再用其他標籤篩選。沒釘的標籤只在照片分頁的篩選裡。
/// - 那年今天：往年的今天拍的照片。
struct HomeView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var tagStore: TagStore

    @State private var openedCollection: PhotoTag?
    /// 這個畫面會跳出的表單，合成一個 sheet，避免多個 .sheet 疊在同一個畫面上。
    private enum HomeSheet: Identifiable {
        case cardStyle, arrange
        case editTag(PhotoTag)
        case editCover(PhotoTag)
        var id: String {
            switch self {
            case .cardStyle: return "cardStyle"
            case .arrange: return "arrange"
            case .editTag(let tag): return "edit-\(tag.id)"
            case .editCover(let tag): return "cover-\(tag.id)"
            }
        }
    }
    @State private var sheet: HomeSheet?
    /// 編輯標籤模式：卡片上出現鉛筆，點了改成編輯那個標籤。
    @State private var isEditingTags = false
    /// 選集內容的寬度，卡片依它算大小。
    @State private var contentWidth: CGFloat = 390
    @State private var covers: [UUID: PHAsset] = [:]
    @State private var counts: [UUID: Int] = [:]
    @State private var onThisDay: [OnThisDayGroup] = []
    /// 點選某個年份群組時，進入該日照片集合頁面（圖 1）。
    @State private var selectedOnThisDayGroup: OnThisDayGroup?
    /// 點那年今天的照片打開檢視時，從縮圖位置展開。
    @Namespace private var photoZoom

    private func tags(of block: HomeBlock) -> [PhotoTag] {
        block.tagIDs.compactMap { tagStore.tag(withID: $0) }
    }

    /// 區塊有沒有東西可以顯示。空的日子、標籤區塊不占位置。
    private func hasContent(_ block: HomeBlock) -> Bool {
        block.mode == .onThisDay ? !onThisDay.isEmpty : !tags(of: block).isEmpty
    }

    private var isEmpty: Bool {
        !model.homeBlocks.contains { !$0.isHidden && hasContent($0) }
    }

    /// 使用者取的標題；沒取就用種類的預設名稱。
    private func title(for block: HomeBlock) -> String {
        if !block.title.trimmingCharacters(in: .whitespaces).isEmpty { return block.title }
        return HomeBlockNames.defaultTitle(for: block.mode)
    }

    @ViewBuilder
    private func blockView(_ block: HomeBlock) -> some View {
        if hasContent(block) {
            switch block.mode {
            case .days: daysBlock(block)
            case .tags: tagsBlock(block)
            case .monthCalendar, .weekCalendar: calendarBlock(block)
            case .onThisDay: onThisDayBlock(block)
            }
        }
    }

    private var anniversaryTags: [PhotoTag] { tagStore.tags.filter { $0.hasAnniversary && $0.pinnedOnHome } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: PageMetrics.gapLG) {
                    if isEmpty { emptyState }
                    // 依使用者排的順序，一個區塊一個區塊往下放。
                    ForEach(model.homeBlocks.filter { !$0.isHidden }) { block in blockView(block) }
                }
                .padding(.top, PageMetrics.contentTopGap)
                .padding(.bottom, 12)
            }
            .background(Color(.systemBackground))
            .background(GeometryReader { proxy in
                Color.clear.onAppear { contentWidth = proxy.size.width }
                    .onChange(of: proxy.size.width) { _, width in contentWidth = width }
            })
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: dynamicTypeSize.isAccessibilitySize ? 0 : PageMetrics.largeTitleBodyOffset)
                    .accessibilityHidden(true)
            }
            .navigationDestination(item: $openedCollection) { tag in
                TagCollectionView(tag: tag)
            }
            .onAppear {
                reconcileSections()
                openRequestedCollection()
            }
            .onChange(of: tagStore.tags) { _, _ in reconcileSections() }
            .onChange(of: model.requestedCollectionTagID) { _, _ in openRequestedCollection() }
            .navigationTitle("選集")
            .navigationBarTitleDisplayMode(dynamicTypeSize.isAccessibilitySize ? .large : .inline)
            .toolbar {
                if !dynamicTypeSize.isAccessibilitySize {
                    LeadingTitleToolbar(title: "選集", font: .largeTitle)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { sheet = .cardStyle } label: {
                            Label("卡片樣式", systemImage: "slider.horizontal.3")
                        }
                        .accessibilityIdentifier("home.cardStyle")
                        Button { sheet = .arrange } label: {
                            Label("管理區塊", systemImage: "square.stack.3d.up")
                        }
                        .accessibilityIdentifier("home.arrange")
                        Button { withMotion { isEditingTags.toggle() } } label: {
                            Label(isEditingTags ? "完成編輯標籤" : "編輯標籤",
                                  systemImage: isEditingTags ? "checkmark" : "pencil")
                        }
                        .accessibilityIdentifier("home.editTags")
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .accessibilityLabel(Text("自訂版面"))
                    .accessibilityIdentifier("home.cardSettings")
                }
            }
            .fullScreenCover(item: $selectedOnThisDayGroup) { group in
                OnThisDayDetailView(group: group)
            }
            .sheet(item: $sheet) { which in
                switch which {
                case .arrange:
                    HomeArrangeView()
                case .cardStyle:
                    CardSettingsView(sampleTag: anniversaryTags.first,
                                     sampleCover: anniversaryTags.first.flatMap { covers[$0.id] })
                        .presentationDetents([.large])
                case .editTag(let tag):
                    TagFormView(mode: .edit(tag))
                case .editCover(let tag):
                    NavigationStack { TagCoverEditorView(tagID: tag.id) }
                }
            }
            .task(id: tagStore.assignments.count + tagStore.tags.count) { loadCoversAndCounts() }
            .task { await loadOnThisDay() }
        }
    }

    // MARK: - 日子

    private func daysBlock(_ block: HomeBlock) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle(title(for: block))
            cardsLayout(tags(of: block), block: block) { tag, dimension in
                Button { activate(tag, opensCollection: false) } label: {
                    coverCard(tag, dimension: dimension,
                              primary: tag.anniversaryText(on: Date()) ?? "",
                              secondary: String(format: String(localized: "%lld photos"), counts[tag.id] ?? 0))
                        .editBadge(isEditingTags)
                }
                .buttonStyle(.plain)
                .contextMenu { editMenu(tag) }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("home.anniversary")
            }
        }
        .motionAnimation(value: block.size)
        .motionAnimation(value: block.wraps)
    }

    /// 卡片的排法：自動換行就是一格一格往下排；橫向捲動就是一列往右滑，最右邊那張被切掉一截，提示還可以滑。
    @ViewBuilder
    private func cardsLayout<Content: View>(_ items: [PhotoTag], block: HomeBlock,
                                            @ViewBuilder content: @escaping (PhotoTag, CGSize) -> Content) -> some View {
        let dimension = block.size.dimensions(contentWidth: contentWidth, wraps: block.wraps)
        if block.wraps {
            let columns = Array(repeating: GridItem(.fixed(dimension.width), spacing: 12), count: block.size == .large ? 1 : 2)
            LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                ForEach(items) { tag in content(tag, dimension) }
            }
            .padding(.horizontal, PageMetrics.edge)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(items) { tag in content(tag, dimension) }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.leading, PageMetrics.edge, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .frame(height: dimension.height + 8)
        }
    }

    // MARK: - 標籤

    private func tagsBlock(_ block: HomeBlock) -> some View {
        let items = tags(of: block)
        return VStack(alignment: .leading, spacing: 8) {
            sectionTitle(title(for: block))
            if block.layout == .cards {
                cardsLayout(items, block: block) { tag, dimension in
                    Button { activate(tag, opensCollection: true) } label: {
                        coverCard(tag, dimension: dimension,
                                  primary: String(format: String(localized: "%lld photos"), counts[tag.id] ?? 0),
                                  secondary: nil)
                            .editBadge(isEditingTags)
                    }
                    .buttonStyle(.plain)
                    .contextMenu { editMenu(tag) }
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("home.collection")
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, tag in
                        Button { activate(tag, opensCollection: true) } label: {
                            tagRow(tag).editBadge(isEditingTags)
                        }
                        .buttonStyle(.plain)
                        .contextMenu { editMenu(tag) }
                        .accessibilityElement(children: .combine)
                        .accessibilityIdentifier("home.collection")
                        if index < items.count - 1 { Divider().padding(.leading, 64 - 16 + PageMetrics.edge) }
                    }
                }
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, PageMetrics.edge)
            }
        }
        .motionAnimation(value: block.layout)
        .motionAnimation(value: block.size)
        .motionAnimation(value: block.wraps)
    }

    private func tagRow(_ tag: PhotoTag) -> some View {
        HStack(spacing: 12) {
            cover(for: tag)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            HStack(spacing: 6) {
                IconLabel(raw: tag.symbol, size: 16)
                Text(tag.name).font(.body)
            }
            Spacer()
            Text("\(counts[tag.id] ?? 0)").foregroundStyle(.secondary)
            Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }

    // MARK: - 月曆、週曆

    private func calendarBlock(_ block: HomeBlock) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(title(for: block))
            let items = tags(of: block)
            ForEach(items) { tag in
                // 區塊標題跟標籤名稱一樣（或只有一個標籤且標題就是它）就不重複顯示標籤名稱。
                let sameAsTitle = title(for: block).trimmingCharacters(in: .whitespaces)
                    .caseInsensitiveCompare(tag.name) == .orderedSame
                TagPeriodSection(tag: tag, period: block.mode == .weekCalendar ? .week : .month,
                                 showsTagName: !sameAsTitle)
            }
        }
    }

    // MARK: - 共用卡片

    /// 封面滿版，疊上名稱與文字。日子卡片、標籤卡片、桌面小工具同一種樣子。
    private func coverCard(_ tag: PhotoTag, dimension: CGSize,
                           primary: String, secondary: String?) -> some View {
        let scale = CardSize.textScale(for: dimension)
        return ZStack {
            cover(for: tag)
            CardTextOverlay(name: tag.name,
                            primary: primary,
                            secondary: secondary,
                            position: model.cardTextPosition,
                            style: model.cardTextStyle,
                            scale: scale) {
                IconLabel(raw: tag.symbol, size: 17 * scale)
            }
        }
        .frame(width: dimension.width, height: dimension.height)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
    }

    // MARK: - 那年今天

    private func onThisDayBlock(_ block: HomeBlock) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle(title(for: block))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(onThisDay) { group in
                        Button {
                            selectedOnThisDayGroup = group
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                ZStack(alignment: .bottomLeading) {
                                    if let cover = group.assets.first {
                                        AssetThumbnail(asset: cover, size: 240, showsDuration: false)
                                            .frame(width: 140, height: 140)
                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    } else {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(Color(.tertiarySystemFill))
                                            .frame(width: 140, height: 140)
                                    }

                                    Text("\(group.yearsAgo) 年前")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.ultraThinMaterial, in: Capsule())
                                        .padding(8)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(group.year)年")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)

                                    Text(String(format: String(localized: "%lld photos"), group.assets.count))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("home.onthisday.group.\(group.id)")
                    }
                }
                .padding(.horizontal, PageMetrics.edge)
            }
        }
    }

    // MARK: - 空狀態

    private var emptyState: some View {
        AppEmptyState(icon: "house",
                      title: String(localized: "Nothing pinned yet"),
                      message: String(localized: "Create a tag in Organize and pin it to Home, or give it a start date such as a child's birthday, and it shows up here as a card."),
                      actionTitle: String(localized: "Manage tags"),
                      actionIdentifier: "home.manageTags") {
            model.organizeSection = .tags
            model.selectedTab = 3
        }
    }

    // MARK: - 共用

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.title3.weight(.bold))
            .padding(.horizontal, PageMetrics.edge)
    }

    @ViewBuilder
    private func cover(for tag: PhotoTag) -> some View {
        if let asset = covers[tag.id] {
            // 填滿的封面。AssetThumbnail 固定是正方形，放進直的卡片會留一塊空。
            TagCoverImage(assetID: asset.localIdentifier, size: 500, framing: tag.coverFraming)
        } else {
            // 沒有照片時放灰底加圖標。圖標放右上角，不會壓到底下的文字。
            ZStack(alignment: .topTrailing) {
                Rectangle().fill(Color(.tertiarySystemFill))
                IconLabel(raw: tag.symbol, size: 22).padding(12)
            }
        }
    }

    /// 區塊清單跟著標籤變動：新釘選的標籤自動出現，不再符合的消失。
    private func reconcileSections() {
        model.reconcileHomeBlocks(tags: tagStore.tags)
    }

    /// 小工具點進來：直接打開那個標籤的選集頁。
    private func openRequestedCollection() {
        guard let id = model.requestedCollectionTagID else { return }
        model.requestedCollectionTagID = nil
        if let tag = tagStore.tag(withID: id) { openedCollection = tag }
    }

    /// 點卡片：編輯模式就改標籤，平常是打開那個標籤的收藏頁。
    /// 日子卡片跳到照片分頁並套用標籤；釘選標籤卡片打開收藏頁。
    private func activate(_ tag: PhotoTag, opensCollection: Bool) {
        if isEditingTags { sheet = .editTag(tag) }
        else if opensCollection { openedCollection = tag }
        else { open(tag) }
    }

    /// 長按卡片的選單，不用先進編輯模式。
    @ViewBuilder
    private func editMenu(_ tag: PhotoTag) -> some View {
        Button { sheet = .editTag(tag) } label: {
            Label("編輯標籤", systemImage: "pencil")
        }
        Button { sheet = .editCover(tag) } label: {
            Label("設定封面", systemImage: "photo")
        }
    }

    /// 點卡片：切到照片分頁，並套用那個標籤。
    private func open(_ tag: PhotoTag) {
        model.requestedSelection = .tag(tag.id)
        model.selectedTab = 2
    }

    // MARK: - 載入

    /// 每個標籤最新的一張當封面，並算張數。
    private func loadCoversAndCounts() {
        var newCovers: [UUID: PHAsset] = [:]
        var newCounts: [UUID: Int] = [:]
        for tag in tagStore.tags {
            let ids = tagStore.assetIDs(withTag: tag.id)
            newCounts[tag.id] = ids.count
            // 自己選的封面優先，沒選（或那張已經不在）就用最新一張。
            if let custom = tag.coverAssetID, let asset = library.asset(withID: custom) {
                newCovers[tag.id] = asset
                continue
            }
            let assets = library.assets(withIDs: ids)
            if let latest = assets.max(by: { ($0.creationDate ?? .distantPast) < ($1.creationDate ?? .distantPast) }) {
                newCovers[tag.id] = latest
            }
        }
        covers = newCovers
        counts = newCounts
    }

    /// 往年的今天拍的照片，依年份集合在同一天，越近的年份越前面。
    private func loadOnThisDay() async {
        let all = await library.assets(matching: .all)
        let calendar = PhotoGrouping.calendar
        let today = calendar.dateComponents([.year, .month, .day], from: Date())

        let groups = await Task.detached(priority: .utility) { () -> [OnThisDayGroup] in
            var byYear: [Int: [PHAsset]] = [:]
            for asset in all {
                guard let date = asset.creationDate else { continue }
                let parts = calendar.dateComponents([.year, .month, .day], from: date)
                guard parts.month == today.month, parts.day == today.day,
                      let year = parts.year, let thisYear = today.year, year < thisYear else { continue }
                byYear[year, default: []].append(asset)
            }
            guard let thisYear = today.year, let todayMonth = today.month, let todayDay = today.day else { return [] }
            return byYear.keys.sorted(by: >).compactMap { year -> OnThisDayGroup? in
                guard let items = byYear[year], !items.isEmpty else { return nil }
                var comp = DateComponents()
                comp.year = year
                comp.month = todayMonth
                comp.day = todayDay
                let date = calendar.date(from: comp) ?? Date()
                return OnThisDayGroup(year: year,
                                     month: todayMonth,
                                     day: todayDay,
                                     yearsAgo: thisYear - year,
                                     date: date,
                                     assets: items)
            }
        }.value

        onThisDay = groups
    }
}

private extension View {
    /// 編輯標籤模式下，卡片右上角的鉛筆。
    @ViewBuilder
    func editBadge(_ isOn: Bool) -> some View {
        if isOn {
            overlay(alignment: .topTrailing) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, Color.accentColor)
                    .shadow(radius: 2)
                    .padding(8)
            }
        } else {
            self
        }
    }
}

// MARK: - 那年今天群組與單日集合頁面（圖 1）

struct OnThisDayGroup: Identifiable {
    let year: Int
    let month: Int
    let day: Int
    let yearsAgo: Int
    let date: Date
    let assets: [PHAsset]
    var id: String { "\(year)-\(month)-\(day)" }
}

struct OnThisDayDetailView: View {
    let group: OnThisDayGroup
    @Environment(\.dismiss) private var dismiss

    @State private var detailAssetID: String?
    @Namespace private var photoZoom

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(group.assets, id: \.localIdentifier) { asset in
                            Button {
                                detailAssetID = asset.localIdentifier
                            } label: {
                                AssetThumbnail(asset: asset, size: 240, showsDuration: true)
                                    .aspectRatio(1, contentMode: .fill)
                                    .clipped()
                                    .zoomSource(id: asset.localIdentifier, in: photoZoom)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("onthisday.detail.photo.\(asset.localIdentifier)")
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(item: Binding(get: { detailAssetID.map { DetailViewerItem(id: $0) } },
                                      set: { detailAssetID = $0?.id })) { item in
            PhotoDetailView(assets: group.assets, startID: item.id)
                .zoomDestination(id: item.id, in: photoZoom)
        }
    }

    private struct DetailViewerItem: Identifiable {
        let id: String
    }

    // MARK: - 頁首導覽列（圖 1）

    private var header: some View {
        HStack {
            GlassCircleButton {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
            }
            .accessibilityLabel(Text("返回"))
            .accessibilityIdentifier("onthisday.detail.back")

            Spacer()

            VStack(spacing: 2) {
                Text(dateTitle)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(String(format: "%lld 張照片", group.assets.count))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .accessibilityIdentifier("onthisday.detail.title")

            Spacer()

            Menu {
                Text("\(group.yearsAgo) 年前的今天")
                Text(dateTitle)
            } label: {
                GlassCircleButton {} label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.body.weight(.semibold))
                }
            }
            .accessibilityLabel(Text("選單"))
            .accessibilityIdentifier("onthisday.detail.menu")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var dateTitle: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: group.date)
    }
}
