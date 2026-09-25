import SwiftUI
import Photos

/// 整理分頁：固定三個入口，底下接未整理照片依月份分組。
struct OrganizeTabView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var organized: OrganizedStore

    @State private var summary = UnorganizedSummary()
    @State private var isLoading = false
    @State private var selectedBucket: OrganizeBucket?
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            Group {
                switch model.organizeSection {
                case .photos: photosContent
                case .tags: TagManagerList()
                case .albums: AlbumManagerList()
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: dynamicTypeSize.isAccessibilitySize ? 0 : PageMetrics.largeTitleBodyOffset)
                    .accessibilityHidden(true)
            }
            .navigationTitle("整理")
            .failureToast()
            .navigationBarTitleDisplayMode(dynamicTypeSize.isAccessibilitySize ? .large : .inline)
            .toolbar {
                if !dynamicTypeSize.isAccessibilitySize {
                    LeadingTitleToolbar(title: "整理", font: .largeTitle)
                }
            }
            // 只有照片子層需要載入，而且不能掛在會消失又出現的清單上，不然會一直重載。
            .task(id: model.organizeSection) {
                if model.organizeSection == .photos { await reload() }
            }
            .navigationDestination(item: $selectedBucket) { bucket in
                ReviewSessionView(bucket: bucket, initialSummary: summary)
            }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            // 三個子層放在底部分頁列上方，跟照片分頁的子分類同一種浮動玻璃樣式。
            .safeAreaInset(edge: .bottom, spacing: 0) { sectionPicker }
        }
    }

    /// 照片：固定三個入口，底下接未整理照片依月份分組。
    @ViewBuilder
    private var photosContent: some View {
        if isLoading {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                Section {
                    bucketRow(.allUnorganized, count: summary.allCount, icon: PhotoFilter.all.systemImage)
                    bucketRow(.unorganizedPhotos, count: summary.photoCount, icon: PhotoFilter.photos.systemImage)
                    bucketRow(.unorganizedVideos, count: summary.videoCount, icon: PhotoFilter.videos.systemImage)
                    bucketRow(.unorganizedScreenshots, count: summary.screenshotCount, icon: PhotoFilter.screenshots.systemImage)
                }

                Section {
                    ForEach(summary.months) { month in
                        bucketRow(.month(year: month.year, month: month.month),
                                  count: month.count,
                                  title: month.title)
                    }
                } header: {
                    Text("依月份整理")
                }
            }
            .pageList()
            .refreshable { await reload() }
        }
    }

    private var sectionPicker: some View {
        HStack(spacing: 0) {
            ForEach(OrganizeSection.allCases) { option in
                Button {
                    model.organizeSection = option
                } label: {
                    Text(option.title)
                        .font(.footnote.weight(model.organizeSection == option ? .semibold : .regular))
                        .foregroundStyle(model.organizeSection == option ? Color.accentColor : Color.primary.opacity(0.78))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("organize.section.\(option.rawValue)")
            }
        }
        .padding(.horizontal, PageMetrics.gapSM)
        .floatingGlass(in: Capsule())
        .padding(.horizontal, PageMetrics.edge)
        .padding(.vertical, 6)
    }

    private func bucketRow(_ bucket: OrganizeBucket,
                           count: Int,
                           icon: String? = nil,
                           title: String? = nil) -> some View {
        Button {
            if model.canUse(bucket) {
                selectedBucket = bucket
            } else {
                showPaywall = true
            }
        } label: {
            HStack(spacing: 12) {
                // 四個固定入口的左邊放跟照片分頁篩選一樣的圖標，文字往右推；月份列沒有圖標。
                if let icon {
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .frame(width: 24)
                }
                Text(title ?? bucket.title)
                Spacer()
                if !model.canUse(bucket) {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text("\(count)")
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .pageRowInsets()
        .disabled(count == 0 && model.canUse(bucket))
    }

    private func reload() async {
        isLoading = summary.months.isEmpty
        defer { isLoading = false }

        let all = await library.assets(matching: .all)
        await organized.refresh(allAssets: all)
        let trashed = Set(model.trashedAssetIDs)
        let unorganized = all.filter { !organized.isOrganized($0) && !trashed.contains($0.localIdentifier) }

        summary = await UnorganizedSummary.build(from: unorganized)
    }
}

/// 整理分頁需要的統計。
struct UnorganizedSummary {
    struct MonthBucket: Identifiable {
        let id: String
        let year: Int
        let month: Int
        let title: String
        let count: Int
        let tint: Color
    }

    var allCount = 0
    var photoCount = 0
    var videoCount = 0
    var screenshotCount = 0
    var months: [MonthBucket] = []

    static func build(from assets: [PHAsset]) async -> UnorganizedSummary {
        let screenshotIDs = await Task.detached(priority: .userInitiated) { () -> Set<String> in
            var ids = Set<String>()
            let albums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                 subtype: .smartAlbumScreenshots,
                                                                 options: nil)
            albums.enumerateObjects { collection, _, _ in
                PHAsset.fetchAssets(in: collection, options: nil).enumerateObjects { asset, _, _ in
                    ids.insert(asset.localIdentifier)
                }
            }
            return ids
        }.value

        return await Task.detached(priority: .userInitiated) {
            var summary = UnorganizedSummary()
            summary.allCount = assets.count
            summary.photoCount = assets.filter { $0.mediaType == .image }.count
            summary.videoCount = assets.filter { $0.mediaType == .video }.count
            summary.screenshotCount = assets.filter { screenshotIDs.contains($0.localIdentifier) }.count

            let calendar = Calendar.current
            var monthMap: [DateComponents: Int] = [:]
            for asset in assets {
                guard let date = asset.creationDate else { continue }
                let parts = calendar.dateComponents([.year, .month], from: date)
                monthMap[parts, default: 0] += 1
            }

            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("yyyyMMMM")

            let palette: [Color] = [
                Color.green.opacity(0.25), Color.pink.opacity(0.22), Color.orange.opacity(0.22),
                Color.yellow.opacity(0.25), Color.mint.opacity(0.25), Color.blue.opacity(0.2),
                Color.purple.opacity(0.2)
            ]

            summary.months = monthMap
                .compactMap { parts, count -> (DateComponents, Int, Date)? in
                    guard let date = calendar.date(from: parts) else { return nil }
                    return (parts, count, date)
                }
                .sorted { $0.2 > $1.2 }
                .enumerated()
                .map { index, entry in
                    let (parts, count, date) = entry
                    return MonthBucket(id: "\(parts.year ?? 0)-\(parts.month ?? 0)",
                                       year: parts.year ?? 0,
                                       month: parts.month ?? 0,
                                       title: formatter.string(from: date),
                                       count: count,
                                       tint: palette[index % palette.count])
                }

            return summary
        }.value
    }
}
