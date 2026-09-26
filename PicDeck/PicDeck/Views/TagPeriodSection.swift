import SwiftUI
import Photos

/// 選集裡的「標籤月曆／週曆」：某個標籤在當月（或當週）拍的照片，排在對應的日子上。
/// 例如 #午餐：這個月每天吃了什麼，一格一天，點一下進到那個標籤。
struct TagPeriodSection: View {
    let tag: PhotoTag
    let period: HomeSectionConfig.Period
    /// 區塊標題已經是標籤名稱時就不再重複顯示。
    var showsTagName = true

    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var tagStore: TagStore

    /// 每一天（當天 0 點）對應的第一張照片。
    @State private var photosByDay: [Date: [PHAsset]] = [:]
    /// 點有照片的那一天打開的檢視（那天這個標籤的所有照片，沒有功能按鈕）。
    @State private var viewer: DayViewer?
    /// 點某一天打開檢視時，從那天的縮圖位置展開。
    @Namespace private var photoZoom

    private struct DayViewer: Identifiable {
        let assets: [PHAsset]
        var id: String { assets.first?.localIdentifier ?? UUID().uuidString }
    }

    private var calendar: Calendar { PhotoGrouping.calendar }

    /// 這段期間的所有日期，月曆前面補空格讓星期對齊。
    private var cells: [Date?] {
        let today = Date()
        switch period {
        case .month:
            guard let interval = calendar.dateInterval(of: .month, for: today) else { return [] }
            let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day ?? 30
            let lead = (calendar.component(.weekday, from: interval.start) - calendar.firstWeekday + 7) % 7
            return Array(repeating: nil, count: lead) + (0..<days).compactMap { calendar.date(byAdding: .day, value: $0, to: interval.start) }
        case .week:
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
            return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: interval.start) }
        }
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let start = calendar.firstWeekday - 1
        return Array(symbols[start...] + symbols[..<start])
    }

    private var title: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        switch period {
        case .month:
            formatter.setLocalizedDateFormatFromTemplate("yMMMM")
            return formatter.string(from: Date())
        case .week:
            return String(localized: "This week")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showsTagName {
                HStack(spacing: 6) {
                    IconLabel(raw: tag.symbol, size: 16)
                    Text(tag.name).font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
                }
                .padding(.horizontal, PageMetrics.edge)
            }

            card
                .padding(.horizontal, PageMetrics.edge)
                .accessibilityIdentifier("home.period")
        }
        .fullScreenCover(item: $viewer) { day in
            let startID = day.assets.last?.localIdentifier ?? ""
            PhotoDetailView(assets: day.assets, startID: startID)
                .zoomDestination(id: startID, in: photoZoom)
        }
        .task(id: tagStore.assignments.count) { reload() }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(title).font(.headline)
                Spacer()
                Text(String(format: String(localized: "%lld days recorded"), photosByDay.count))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol).font(.caption2).foregroundStyle(.secondary)
                }
                ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                    if let day { cell(day) } else { Color.clear.aspectRatio(1, contentMode: .fit) }
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    @ViewBuilder
    private func cell(_ day: Date) -> some View {
        let number = calendar.component(.day, from: day)
        let isToday = calendar.isDateInToday(day)
        Group {
            if let dayAssets = photosByDay[calendar.startOfDay(for: day)], let asset = dayAssets.last {
                Button {
                    viewer = DayViewer(assets: dayAssets)
                } label: {
                    AssetThumbnail(asset: asset, size: 120, showsDuration: false)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .zoomSource(id: asset.localIdentifier, in: photoZoom)
                        .overlay(alignment: .bottomTrailing) {
                            Text("\(number)")
                                .font(.system(.caption2, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)
                                .shadow(radius: 2)
                                .padding(3)
                                .background(.black.opacity(0.5), in: Capsule())
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(day.formatted(date: .complete, time: .omitted)))
                .accessibilityValue(Text("\(dayAssets.count) photos"))
                .accessibilityIdentifier("period.day")
            } else {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(.tertiarySystemFill))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Text("\(number)")
                            .font(.caption2)
                            .foregroundStyle(isToday ? Color.accentColor : Color.secondary)
                            .fontWeight(isToday ? .bold : .regular)
                    }
            }
        }
        .overlay {
            if isToday {
                RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(Color.accentColor, lineWidth: 2)
            }
        }
    }

    private func reload() {
        let assets = library.assets(withIDs: tagStore.assetIDs(withTag: tag.id))
        var result: [Date: [PHAsset]] = [:]
        let cellSet = Set(cells.compactMap { $0 }.map { calendar.startOfDay(for: $0) })
        // 同一天有好幾張，依拍攝時間排，縮圖用最晚拍的那一張。
        for asset in assets.sorted(by: { ($0.creationDate ?? .distantPast) < ($1.creationDate ?? .distantPast) }) {
            guard let date = asset.creationDate else { continue }
            let day = calendar.startOfDay(for: date)
            if cellSet.contains(day) { result[day, default: []].append(asset) }
        }
        photosByDay = result
    }
}
