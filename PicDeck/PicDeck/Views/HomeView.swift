import SwiftUI
import Photos

/// 首頁：把最常想看的東西集中在一頁。
///
/// - 日子：設了日期的標籤，卡片直接顯示「今天過了多久」，點進去就是那個標籤的照片。
/// - 標籤：其餘的標籤，卡片是封面與張數。
/// - 標籤：只有釘在首頁的標籤才會出現，例如 #美食，點進去看存下來的照片與備註，可再用其他標籤篩選。沒釘的標籤只在照片分頁的篩選裡。
/// - 那年今天：往年的今天拍的照片。
struct HomeView: View {
    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var tagStore: TagStore

    @State private var covers: [UUID: PHAsset] = [:]
    @State private var counts: [UUID: Int] = [:]
    @State private var onThisDay: [OnThisDayItem] = []

    private struct OnThisDayItem: Identifiable {
        let asset: PHAsset
        let yearsAgo: Int
        var id: String { asset.localIdentifier }
    }

    private var anniversaryTags: [PhotoTag] { tagStore.tags.filter { $0.hasAnniversary && $0.pinnedOnHome } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    if anniversaryTags.isEmpty && tagStore.homePinnedTags.isEmpty && onThisDay.isEmpty {
                        emptyState
                    }
                    if !anniversaryTags.isEmpty { anniversarySection }
                    if !tagStore.homePinnedTags.isEmpty { collectionsSection }
                    if !onThisDay.isEmpty { onThisDaySection }
                }
                .padding(.top, PageMetrics.contentTopGap)
                .padding(.bottom, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { LeadingTitleToolbar(title: String(localized: "Home"), ) }
            .task(id: tagStore.assignments.count + tagStore.tags.count) { loadCoversAndCounts() }
            .task { await loadOnThisDay() }
        }
    }

    // MARK: - 日子

    private var anniversarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Days")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(anniversaryTags) { tag in
                        Button { open(tag) } label: { anniversaryCard(tag) }
                            .buttonStyle(.plain)
                            .accessibilityElement(children: .combine)
                            .accessibilityIdentifier("home.anniversary")
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func anniversaryCard(_ tag: PhotoTag) -> some View {
        ZStack(alignment: .bottomLeading) {
            cover(for: tag)
                .frame(width: 210, height: 250)

            // 封面下方漸層，字才讀得清楚。
            LinearGradient(colors: [.clear, .black.opacity(0.72)],
                           startPoint: .center, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    IconLabel(raw: tag.symbol, size: 17)
                    Text(tag.name).font(.headline)
                }
                if let text = tag.anniversaryText(on: Date()) {
                    Text(text)
                        .font(.title3.weight(.bold))
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
                Text("\(counts[tag.id] ?? 0) photos")
                    .font(.caption)
                    .opacity(0.85)
            }
            .foregroundStyle(.white)
            .padding(14)
        }
        .frame(width: 210, height: 250)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
    }

    // MARK: - 釘選在首頁的標籤

    private var collectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Tags")

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                      spacing: 12) {
                ForEach(tagStore.homePinnedTags) { tag in
                    NavigationLink {
                        TagCollectionView(tag: tag)
                    } label: {
                        tagCard(tag)
                    }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("home.collection")
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func tagCard(_ tag: PhotoTag) -> some View {
        HStack(spacing: 10) {
            cover(for: tag)
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    IconLabel(raw: tag.symbol, size: 13)
                    Text(tag.name).font(.subheadline.weight(.semibold)).lineLimit(2).fixedSize(horizontal: false, vertical: true)
                }
                Text("\(counts[tag.id] ?? 0) photos")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        // 淺色底上卡片邊界不明顯，加一圈很淡的線。
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1))
        .contentShape(Rectangle())
    }

    // MARK: - 那年今天

    private var onThisDaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("On this day")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(onThisDay) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            AssetThumbnail(asset: item.asset, size: 160, showsDuration: false)
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            Text("\(item.yearsAgo) years ago")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - 空狀態

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Nothing pinned yet", systemImage: "house")
        } description: {
            Text("Create a tag in Organize and pin it to Home, or give it a start date such as a child's birthday, and it shows up here as a card.")
        } actions: {
            // 直接帶到管理標籤，不用自己找。
            Button("Manage tags") {
                model.organizeSection = .tags
                model.selectedTab = 3
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("home.manageTags")
        }
        .padding(.top, 40)
    }

    // MARK: - 共用

    private func sectionTitle(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.title3.weight(.bold))
            .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func cover(for tag: PhotoTag) -> some View {
        if let asset = covers[tag.id] {
            // 填滿的封面。AssetThumbnail 固定是正方形，放進直的卡片會留一塊空。
            CoverImage(assetID: asset.localIdentifier, size: 400)
        } else {
            ZStack {
                Rectangle().fill(Color(.tertiarySystemFill))
                IconLabel(raw: tag.symbol, size: 26)
            }
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
            let assets = library.assets(withIDs: ids)
            if let latest = assets.max(by: { ($0.creationDate ?? .distantPast) < ($1.creationDate ?? .distantPast) }) {
                newCovers[tag.id] = latest
            }
        }
        covers = newCovers
        counts = newCounts
    }

    /// 往年的今天拍的照片，最多十二張，越近的年份越前面。
    private func loadOnThisDay() async {
        let all = await library.assets(matching: .all)
        let calendar = PhotoGrouping.calendar
        let today = calendar.dateComponents([.year, .month, .day], from: Date())

        let found = await Task.detached(priority: .utility) { () -> [(PHAsset, Int)] in
            var output: [(PHAsset, Int)] = []
            for asset in all {
                guard let date = asset.creationDate else { continue }
                let parts = calendar.dateComponents([.year, .month, .day], from: date)
                guard parts.month == today.month, parts.day == today.day,
                      let year = parts.year, let thisYear = today.year, year < thisYear else { continue }
                output.append((asset, thisYear - year))
            }
            return output.sorted { $0.1 < $1.1 }
        }.value

        onThisDay = found.prefix(12).map { OnThisDayItem(asset: $0.0, yearsAgo: $0.1) }
    }
}
