import SwiftUI
import Photos

/// 日檢視：一個月一段，週一到週日的月曆格狀。
/// 有照片的日子顯示當天第一張照片，右下角是張數，右上角預留日記心情表情。
struct DayCalendarGridView: View {
    @EnvironmentObject private var journalStore: JournalStore

    let months: [PhotoGrouping.MonthOfDays]
    /// 指定要捲到哪個月份，之後仍可上下滑動看其他月。
    var focusMonthID: String? = nil
    let onSelect: (Int, Int, Int) -> Void   // year, month, day

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    /// 右側拖拉軸。
    var scrub: ScrubIndex? = nil

    var body: some View {
        AnchoredScrollView(anchorID: focusMonthID, isReady: !months.isEmpty, scrub: scrub) {
            LazyVStack(alignment: .leading, spacing: 26) {
                ForEach(months) { month in
                    Section {
                        VStack(spacing: 10) {
                            weekdayHeader

                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(cells(for: month), id: \.id) { entry in
                                    if let day = entry.day {
                                        DayCalendarCell(day: day,
                                                        cell: month.cells[day],
                                                        mood: journalStore.mood(year: month.year,
                                                                                month: month.month,
                                                                                day: day),
                                                        isToday: isToday(year: month.year,
                                                                         month: month.month,
                                                                         day: day))
                                            .onTapGesture {
                                                guard month.cells[day] != nil else { return }
                                                onSelect(month.year, month.month, day)
                                            }
                                            .accessibilityIdentifier("daycell.\(month.year)-\(month.month)-\(day)")
                                    } else {
                                        Color.clear.frame(height: 1)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                    } header: {
                        Text(month.title)
                            .font(.title3.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                    }
                    .id(month.id)
                }
            }
            .padding(.bottom, 24)
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 6) {
            ForEach(PhotoGrouping.weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    /// 月初補空格，讓一號落在正確的星期。用獨立索引當 id，避免與日期撞號。
    private func cells(for month: PhotoGrouping.MonthOfDays) -> [(id: String, day: Int?)] {
        let blanks = (month.firstWeekday - PhotoGrouping.calendar.firstWeekday + 7) % 7
        var result: [(id: String, day: Int?)] = (0..<blanks).map {
            ("blank-\(month.id)-\($0)", nil)
        }
        result += (1...month.dayCount).map { ("day-\(month.id)-\($0)", $0) }
        return result
    }

    private func isToday(year: Int, month: Int, day: Int) -> Bool {
        let today = PhotoGrouping.calendar.dateComponents([.year, .month, .day], from: Date())
        return today.year == year && today.month == month && today.day == day
    }
}

/// 單一天的格子。
struct DayCalendarCell: View {
    let day: Int
    let cell: PhotoGrouping.DayCell?
    /// 當天日記的心情表情，沒有日記就是 nil。
    var mood: String? = nil
    var isToday: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.secondarySystemBackground))
                    .aspectRatio(1, contentMode: .fit)

                if let coverID = cell?.coverID {
                    CoverImage(assetID: coverID, size: 120)
                        .aspectRatio(1, contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if let count = cell?.count {
                    Text("\(count)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.7), radius: 1.5)
                        .padding(3)
                }
            }
            .overlay(alignment: .topTrailing) {
                // 當天有寫日記就顯示心情表情。
                if let mood, !mood.isEmpty {
                    IconLabel(raw: mood, size: 12)
                        .shadow(color: .black.opacity(0.4), radius: 1)
                        .padding(2)
                }
            }
            .overlay {
                if isToday {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.red, lineWidth: 2)
                }
            }

            Text("\(day)")
                .font(.caption2)
                .foregroundStyle(isToday ? .red : (cell == nil ? .secondary : .primary))
        }
    }
}
