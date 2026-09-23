import SwiftUI
import Photos

/// 月檢視：依年份分段，每個月一張卡片，卡片下方是小月曆，
/// 有照片的日期亮起，今天標紅。
struct MonthCalendarGridView: View {
    let years: [PhotoGrouping.YearOfMonths]
    /// 指定要捲到哪一年，之後仍可上下滑動看其他年。
    var focusYearID: String? = nil
    var onScrollOffsetChange: ((CGFloat) -> Void)? = nil
    let onSelect: (PhotoGrouping.MonthCalendar) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var columns: [GridItem] {
        // 月曆日期在輔助使用字級下需要足夠的欄寬；改成單欄卡片，日期不會擠在 7 個窄格裡。
        let minimum: CGFloat = dynamicTypeSize.isAccessibilitySize ? 216 : (dynamicTypeSize >= .xxLarge ? 168 : 148)
        return [GridItem(.adaptive(minimum: minimum), spacing: 10, alignment: .top)]
    }

    var body: some View {
        AnchoredScrollView(anchorID: focusYearID, isReady: !years.isEmpty,
                           onScrollOffsetChange: { offset, _ in onScrollOffsetChange?(offset) }) {
            LazyVStack(alignment: .leading, spacing: PageMetrics.photoSectionSpacing) {
                ForEach(years) { group in
                    VStack(alignment: .leading, spacing: PageMetrics.photoSectionGap) {
                        Text(String(group.year))
                            .font(TypeScale.photoSectionTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(group.months) { month in
                                Button {
                                    onSelect(month)
                                } label: {
                                    MonthCalendarCard(month: month)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(Text(month.title))
                                .accessibilityValue(Text("\(month.count) photos"))
                                .accessibilityIdentifier("bucket.m\(month.year)-\(month.month)")
                            }
                        }
                    }
                    .padding(.horizontal, PageMetrics.edge)
                    .id(group.id)
                }
            }
            .padding(.top, PageMetrics.contentTopGap)
            .padding(.bottom, 24)
        }
    }
}

/// 單一月份的卡片：月份名稱、封面、張數、小月曆。
struct MonthCalendarCard: View {
    let month: PhotoGrouping.MonthCalendar

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(month.title)
                .font(.subheadline.weight(.semibold))

            ZStack(alignment: .bottomTrailing) {
                // 用透明容器鎖住 4:3，讓每張卡片的封面高度一致。
                Color.clear
                    .aspectRatio(4 / 3, contentMode: .fit)
                    .overlay {
                        if let coverID = month.coverID {
                            CoverImage(assetID: coverID, size: 160)
                        } else {
                            Rectangle().fill(Color(.secondarySystemBackground))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text("\(month.count)")
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.6), radius: 2)
                    .padding(4)
            }

            MiniMonthCalendar(month: month)
        }
    }
}

/// 小月曆：七欄，有照片的日期亮起，沒有的變淡，今天標紅。
struct MiniMonthCalendar: View {
    let month: PhotoGrouping.MonthCalendar
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
    private var calendar: Calendar { PhotoGrouping.calendar }

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                Text(accessibilitySummary)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("month.accessibilitySummary")
            } else {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(cells, id: \.id) { entry in
                        if let day = entry.day {
                            Text("\(day)")
                                .font(.system(.caption2, design: .rounded, weight: weight(for: day)))
                                .foregroundStyle(color(for: day))
                                .frame(maxWidth: .infinity)
                        } else {
                            Text(" ")
                                .font(.system(.caption2, design: .rounded))
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }

    private var accessibilitySummary: String {
        let days = month.daysWithPhotos.sorted().map(String.init).joined(separator: ", ")
        guard !days.isEmpty else { return String(localized: "No photos") }
        return String.localizedStringWithFormat(String(localized: "Photo dates: %@"), days)
    }

    /// 月初補空格讓 1 號落在正確星期。
    /// 空格與日期必須用不同的 id，否則會互相覆蓋，導致月初幾天不顯示。
    private var cells: [(id: String, day: Int?)] {
        var result: [(id: String, day: Int?)] = (0..<leadingBlanks).map {
            ("b\(month.id)-\($0)", nil)
        }
        result += (1...month.dayCount).map { ("d\(month.id)-\($0)", $0) }
        return result
    }

    /// Calendar 的 weekday 是 1 起算，換成 0 起算的欄位位移。
    private var leadingBlanks: Int {
        (month.firstWeekday - calendar.firstWeekday + 7) % 7
    }

    private func hasPhotos(_ day: Int) -> Bool {
        month.daysWithPhotos.contains(day)
    }

    private func isToday(_ day: Int) -> Bool {
        let today = calendar.dateComponents([.year, .month, .day], from: Date())
        return today.year == month.year && today.month == month.month && today.day == day
    }

    private func weight(for day: Int) -> Font.Weight {
        if isToday(day) { return .bold }
        return hasPhotos(day) ? .semibold : .regular
    }

    private func color(for day: Int) -> Color {
        if isToday(day) { return Color.accentColor }
        // 沒有照片的日子要淡，但不能淡到看不見，深色模式下尤其容易消失。
        return hasPhotos(day) ? .primary : .secondary.opacity(0.75)
    }
}
