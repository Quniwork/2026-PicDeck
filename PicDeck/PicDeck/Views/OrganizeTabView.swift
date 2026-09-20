import SwiftUI
import Photos

/// 整理分頁：固定三個入口，底下接未整理照片依月份分組。
struct OrganizeTabView: View {
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
                if isLoading {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section {
                            bucketRow(.allUnorganized, count: summary.allCount, tint: Color(.systemGray4))
                            bucketRow(.unorganizedVideos, count: summary.videoCount, tint: Color(.systemGray4))
                            bucketRow(.unorganizedScreenshots, count: summary.screenshotCount, tint: Color(.systemGray4))
                        }

                        Section {
                            ForEach(summary.months) { month in
                                bucketRow(.month(year: month.year, month: month.month),
                                          count: month.count,
                                          tint: month.tint,
                                          title: month.title)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Organize")
            .task { await reload() }
            .refreshable { await reload() }
            .navigationDestination(item: $selectedBucket) { bucket in
                ReviewSessionView(bucket: bucket)
            }
            .sheet(isPresented: $showPaywall) { PaywallView() }
        }
    }

    private func bucketRow(_ bucket: OrganizeBucket,
                           count: Int,
                           tint: Color,
                           title: String? = nil) -> some View {
        Button {
            if model.canUse(bucket) {
                selectedBucket = bucket
            } else {
                showPaywall = true
            }
        } label: {
            HStack {
                Text(title ?? bucket.title)
                    .foregroundStyle(.primary)
                Spacer()
                if !model.canUse(bucket) {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text("\(count)")
                    .foregroundStyle(.secondary)
            }
        }
        .listRowBackground(tint)
        .disabled(count == 0 && model.canUse(bucket))
    }

    private func reload() async {
        isLoading = summary.months.isEmpty
        defer { isLoading = false }

        let all = await library.assets(matching: .all)
        await organized.refresh(allAssets: all)
        let unorganized = all.filter { !organized.isOrganized($0) }

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
