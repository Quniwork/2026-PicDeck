import SwiftUI

/// 拖拉軸上的一個落點。
struct ScrubAnchor: Hashable {
    /// 捲動要對到的 id，必須跟畫面上的 `.id(...)` 一致。
    let id: String
    let date: Date
    /// 這個落點代表幾張照片，用來估算一個畫面看得到多少。
    let count: Int
}

/// 拖拉軸要用的資料。
struct ScrubIndex: Equatable {
    var anchors: [ScrubAnchor] = []
    /// 一個畫面大約放得下幾張照片。用來算「目前畫面的區間」。
    var itemsPerScreen: Int = 28

    static func == (lhs: ScrubIndex, rhs: ScrubIndex) -> Bool {
        lhs.itemsPerScreen == rhs.itemsPerScreen && lhs.anchors == rhs.anchors
    }

    var isUsable: Bool { anchors.count > 1 }

    /// 每個年份第一次出現的位置，回傳 0 到 1 的比例。
    var yearMarks: [(year: Int, fraction: CGFloat)] {
        guard anchors.count > 1 else { return [] }
        var seen = Set<Int>()
        var marks: [(Int, CGFloat)] = []
        let last = CGFloat(anchors.count - 1)

        for (index, anchor) in anchors.enumerated() {
            let year = PhotoGrouping.calendar.component(.year, from: anchor.date)
            guard seen.insert(year).inserted else { continue }
            marks.append((year, CGFloat(index) / last))
        }
        return marks
    }

    /// 拖到某個比例時，畫面上大約會是哪一段日期。
    func range(atFraction fraction: CGFloat) -> (top: ScrubAnchor, bottom: ScrubAnchor)? {
        guard !anchors.isEmpty else { return nil }
        let clamped = min(max(fraction, 0), 1)
        let start = Int((clamped * CGFloat(anchors.count - 1)).rounded())
        let top = anchors[start]

        var used = 0
        var end = start
        while end < anchors.count - 1 && used < itemsPerScreen {
            used += anchors[end].count
            end += 1
        }
        return (top, anchors[end])
    }
}

/// 照片右側的拖拉軸。平常只有一顆小把手，按住拖動時才展開年份與日期。
///
/// 目前把手的位置由拖動決定，一般捲動不會回推把手，
/// 這是為了避免為了追蹤捲動位置而在每張縮圖上再掛一層量測。
struct ScrubberOverlay: View {
    let index: ScrubIndex
    let proxy: ScrollViewProxy

    @State private var fraction: CGFloat = 0.66
    @State private var isDragging = false
    @State private var isExpanded = false
    @State private var lastTargetID: String?
    @State private var collapseTask: Task<Void, Never>?

    private let handleSize = CGSize(width: 26, height: 46)
    private let trackInset: CGFloat = 24
    private let trackSpace = "scrubTrack"
    /// 沒在拖的時候把手停的位置。放在中下方，單手拿手機時拇指構得到。
    private let restingFraction: CGFloat = 0.66

    var body: some View {
        GeometryReader { geo in
            let height = max(geo.size.height - trackInset * 2, 1)

            ZStack(alignment: .topTrailing) {
                if isExpanded {
                    yearRail(height: height)
                    rangePill(height: height)
                }
                handle
                    .offset(y: trackInset + handleFraction * height - handleSize.height / 2)
                    .gesture(drag(height: height))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .coordinateSpace(name: trackSpace)
        }
        // 只有把手吃手勢，其他地方要讓照片本身照常捲動與點選。
        .allowsHitTesting(index.isUsable)
    }

    /// 把手實際畫在哪。放開收起來之後回到好按的位置。
    private var handleFraction: CGFloat {
        isExpanded ? fraction : restingFraction
    }

    // MARK: - 元件

    private var handle: some View {
        Image(systemName: "arrow.up.arrow.down")
            .font(.caption2.weight(.bold))
            .foregroundStyle(isExpanded ? Color.white : Color.secondary)
            .frame(width: handleSize.width, height: handleSize.height)
            .background(isExpanded ? Color.accentColor : Color(.tertiarySystemFill),
                        in: Capsule())
            .overlay(Capsule().stroke(Color.primary.opacity(0.06)))
            .padding(.trailing, 4)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .opacity(index.isUsable ? 1 : 0)
            .accessibilityElement()
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(Text("Jump to date"))
            .accessibilityIdentifier("photos.scrubber")
    }

    /// 年份刻度，沿著軌道排。太密的話會疊在一起，所以只留隔得開的。
    private func yearRail(height: CGFloat) -> some View {
        ZStack(alignment: .topTrailing) {
            ForEach(spacedYearMarks, id: \.year) { mark in
                Text(verbatim: "\(mark.year)")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(.regularMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Color.primary.opacity(0.06)))
                    .offset(x: -34, y: trackInset + mark.fraction * height - 10)
                    .accessibilityIdentifier("scrubber.year")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .transition(.opacity)
        .allowsHitTesting(false)
    }

    /// 目前畫面的區間。
    private func rangePill(height: CGFloat) -> some View {
        Group {
            if let text = rangeText {
                Text(text)
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(.regularMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Color.primary.opacity(0.08)))
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
                    .offset(x: -96, y: trackInset + fraction * height - 16)
                    .accessibilityIdentifier("scrubber.range")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .transition(.opacity)
        .allowsHitTesting(false)
    }

    // MARK: - 資料

    /// 年份太多時只留隔得開的，避免標籤重疊。
    private var spacedYearMarks: [(year: Int, fraction: CGFloat)] {
        let marks = index.yearMarks
        guard marks.count > 1 else { return marks }

        let minimumGap: CGFloat = 0.055
        var kept: [(year: Int, fraction: CGFloat)] = []
        for mark in marks {
            if let last = kept.last, mark.fraction - last.fraction < minimumGap { continue }
            kept.append(mark)
        }
        // 最後一個一定要留，不然軸的底部沒有標示。
        if let last = marks.last, kept.last?.year != last.year {
            if let previous = kept.last, last.fraction - previous.fraction < minimumGap {
                kept.removeLast()
            }
            kept.append(last)
        }
        return kept
    }

    private var rangeText: String? {
        guard let pair = index.range(atFraction: fraction) else { return nil }
        return DateTitle.range(from: pair.top.date, to: pair.bottom.date)
    }

    // MARK: - 拖動

    private func drag(height: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(trackSpace))
            .onChanged { value in
                collapseTask?.cancel()
                if !isDragging {
                    withAnimation(.easeOut(duration: 0.15)) {
                        isDragging = true
                        isExpanded = true
                    }
                }
                fraction = min(max((value.location.y - trackInset) / height, 0), 1)
                scrollToCurrent()
            }
            .onEnded { _ in
                withAnimation(.easeOut(duration: 0.2)) { isDragging = false }
                scheduleCollapse()
            }
    }

    /// 放開後年份與日期先留一下再收起來，方便確認自己停在哪裡。
    private func scheduleCollapse() {
        collapseTask?.cancel()
        collapseTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.25)) {
                isExpanded = false
                fraction = restingFraction
            }
            lastTargetID = nil
        }
    }

    private func scrollToCurrent() {
        guard let pair = index.range(atFraction: fraction) else { return }
        // 同一個落點就不要重複捲，不然拖動會很鈍。
        guard pair.top.id != lastTargetID else { return }
        lastTargetID = pair.top.id
        proxy.scrollTo(pair.top.id, anchor: .top)
    }
}
