import SwiftUI
import UIKit

// MARK: - 資料

/// 拖拉軸上的一個落點，對應內容裡的一段（一張照片、一天、一個月或一篇日記）。
struct ScrubAnchor {
    let date: Date
    /// 這一段大約佔多少內容高度。用來把「捲了多少比例」換算成日期。
    let weight: Double
}

/// 拖拉軸要用的資料。建立時就把累計權重算好，拖動時只需要二分搜尋。
struct ScrubIndex {
    let anchors: [ScrubAnchor]
    /// 每個落點之前的累計權重。
    private let starts: [Double]
    let totalWeight: Double
    /// 每個年份第一次出現的累計權重。
    let yearStarts: [(year: Int, start: Double)]

    init(anchors: [ScrubAnchor]) {
        self.anchors = anchors

        var starts: [Double] = []
        starts.reserveCapacity(anchors.count)
        var running = 0.0
        var years: [(Int, Double)] = []
        var seen = Set<Int>()
        let calendar = PhotoGrouping.calendar

        for anchor in anchors {
            starts.append(running)
            let year = calendar.component(.year, from: anchor.date)
            if seen.insert(year).inserted { years.append((year, running)) }
            running += max(anchor.weight, 0.0001)
        }
        self.starts = starts
        self.totalWeight = running
        self.yearStarts = years
    }

    var isUsable: Bool { anchors.count > 1 }

    /// 累計權重落在哪一個落點。
    func anchor(atWeight weight: Double) -> ScrubAnchor? {
        guard !anchors.isEmpty else { return nil }
        var low = 0
        var high = starts.count - 1
        while low < high {
            let mid = (low + high + 1) / 2
            if starts[mid] <= weight { low = mid } else { high = mid - 1 }
        }
        return anchors[low]
    }
}

// MARK: - 抓到底層的 UIScrollView

/// 追蹤捲動位置，也負責把捲動位置設到指定比例。
///
/// SwiftUI 沒有公開「目前捲到哪」這件事，而每一格畫面都重算內容太貴，
/// 所以直接抓底層的 UIScrollView。捲動位置只會更新拖拉軸自己，不會讓照片格子重繪。
@MainActor
final class ScrubController: ObservableObject {

    struct Metrics: Equatable {
        /// 已經捲過的距離，頂端是 0。
        var offset: CGFloat = 0
        /// 內容總高度。
        var content: CGFloat = 1
        /// 可視範圍高度。
        var viewport: CGFloat = 1

        /// 最多能捲多遠。
        var range: CGFloat { max(content - viewport, 0) }
        /// 捲到哪個比例，0 到 1。
        var fraction: CGFloat { range > 0 ? min(max(offset / range, 0), 1) : 0 }
    }

    @Published private(set) var metrics = Metrics()
    /// 使用者用手指捲動（包含放開後的慣性滑動）時加一。
    /// 程式自己把畫面捲到定位點、內容載入撐高，都不算，所以把手一開始不會冒出來。
    @Published private(set) var userScrollTick = 0

    private weak var scrollView: UIScrollView?
    private var observations: [NSKeyValueObservation] = []

    func attach(_ view: UIScrollView) {
        guard scrollView !== view else { return }
        scrollView = view
        observations = [
            view.observe(\.contentOffset, options: [.new]) { [weak self] _, _ in
                MainActor.assumeIsolated { self?.refresh() }
            },
            view.observe(\.contentSize, options: [.new]) { [weak self] _, _ in
                MainActor.assumeIsolated { self?.refresh() }
            }
        ]
        DispatchQueue.main.async { [weak self] in self?.refresh() }
    }

    private func refresh() {
        guard let view = scrollView else { return }
        let top = view.adjustedContentInset.top
        let bottom = view.adjustedContentInset.bottom
        let next = Metrics(offset: view.contentOffset.y + top,
                           content: max(view.contentSize.height + top + bottom, 1),
                           viewport: max(view.bounds.height, 1))
        let userDriven = view.isDragging || view.isDecelerating

        // 內容大小與位移的變化常常發生在 SwiftUI 正在排版的時候，這時候直接改 @Published 會觸發
        // 「在視圖更新中發布變更」的錯誤，嚴重時整個畫面會空白。所以延到下一輪再發布。
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let moved = next.offset != self.metrics.offset
            if next != self.metrics { self.metrics = next }
            if moved && userDriven { self.userScrollTick &+= 1 }
        }
    }

    /// 捲到內容的某個比例。直接設位移，所以拖動是連續的，不會一段一段跳。
    func scroll(toFraction fraction: CGFloat) {
        guard let view = scrollView else { return }
        let top = view.adjustedContentInset.top
        let bottom = view.adjustedContentInset.bottom
        let minY = -top
        let maxY = max(minY, view.contentSize.height + bottom - view.bounds.height)
        let target = minY + (maxY - minY) * min(max(fraction, 0), 1)
        view.setContentOffset(CGPoint(x: view.contentOffset.x, y: target), animated: false)
    }
}

/// 放在捲動內容裡，一被掛上畫面就往上找出包住它的 UIScrollView。
private struct ScrollViewBridge: UIViewRepresentable {
    let controller: ScrubController

    func makeUIView(context: Context) -> BridgeView {
        let view = BridgeView()
        view.isUserInteractionEnabled = false
        view.controller = controller
        return view
    }

    func updateUIView(_ view: BridgeView, context: Context) {
        view.controller = controller
        view.attachIfNeeded()
    }

    final class BridgeView: UIView {
        weak var controller: ScrubController?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            attachIfNeeded()
        }

        func attachIfNeeded() {
            guard window != nil, let controller else { return }
            var current: UIView? = superview
            while let view = current {
                if let scroll = view as? UIScrollView {
                    MainActor.assumeIsolated { controller.attach(scroll) }
                    return
                }
                current = view.superview
            }
        }
    }
}

extension View {
    /// 讓拖拉軸可以追蹤與控制這個內容所在的捲動視圖。
    func trackedByScrubber(_ controller: ScrubController) -> some View {
        background(ScrollViewBridge(controller: controller))
    }
}

// MARK: - 畫面

/// 照片右側的拖拉軸，做法參考 Google 相簿。
///
/// - 一般捲動時，把手會出現並跟著目前位置走，停下來一下就淡出。
/// - 按住把手拖動，內容跟著手連續捲動。
/// - 拖動時，把手旁邊顯示目前位置的年月，沿著軌道顯示年份刻度，
///   畫面上方顯示目前看到的日期區間。
struct ScrubberOverlay: View {
    let index: ScrubIndex
    @ObservedObject var controller: ScrubController
    var topInset: CGFloat = 10

    @State private var isDragging = false
    @State private var isScrolling = false
    @State private var isExpanded = false
    @State private var grabOffset: CGFloat = 0
    /// 手指拖到的位置，0 到 1。內容捲不動（照片太少一屏放得下）時，把手也要跟著手指走，
    /// 不能只看捲動位置。用手指捲動內容時會清掉，回到跟著捲動位置。
    @State private var dragFraction: CGFloat?
    @State private var hideTask: Task<Void, Never>?
    @State private var collapseTask: Task<Void, Never>?

    private let inset: CGFloat = 10
    private let handleSize = CGSize(width: 44, height: 44)
    private let hitWidth: CGFloat = 56
    private let space = "scrubberTrack"

    private var showsHandle: Bool { isDragging || isScrolling }

    var body: some View {
        GeometryReader { geo in
            let track = max(geo.size.height - topInset - inset - handleSize.height, 1)
            let metrics = controller.metrics
            let shown = dragFraction ?? metrics.fraction
            let handleTop = topInset + shown * track
            let handleCenter = handleTop + handleSize.height / 2

            ZStack(alignment: .topTrailing) {
                if isExpanded {
                    yearRail(track: track, metrics: metrics, handleCenter: handleCenter)
                    monthBubble(metrics: metrics, shown: shown, handleCenter: handleCenter)
                    // 把手靠近頂端時，日期區間改放到下方，不要蓋住把手旁邊的年月。
                    rangePill(metrics: metrics, shown: shown,
                              atTop: handleCenter > 110 || geo.size.height - handleCenter < 110)
                }

                if showsHandle {
                    handle
                        .offset(y: handleTop - (hitHeight - handleSize.height) / 2)
                        .gesture(drag(track: track, currentCenter: handleCenter))
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .coordinateSpace(name: space)
        }
        // 拖動時每跨過一個月輕輕震一下，像轉動刻度盤。
        .sensoryFeedback(trigger: monthKey) { _, _ in isDragging ? .selection : nil }
        .onChange(of: controller.userScrollTick) { _ in
            guard !isDragging, index.isUsable else { return }
            dragFraction = nil
            revealHandle()
        }
    }

    private var hitHeight: CGFloat { handleSize.height + 16 }

    /// 目前所在的年月，換月份就會變。給觸覺回饋當觸發條件。
    private var monthKey: Int {
        let shown = dragFraction ?? controller.metrics.fraction
        guard let anchor = topAnchor(controller.metrics, shown: shown) else { return 0 }
        let parts = PhotoGrouping.calendar.dateComponents([.year, .month], from: anchor.date)
        return (parts.year ?? 0) * 100 + (parts.month ?? 0)
    }

    // MARK: - 元件

    /// 跟右上角篩選鈕同一種樣式：玻璃圓形，黑色的線條圖示。
    private var handle: some View {
        Image(systemName: "chevron.up.chevron.down")
            .font(.body.weight(.medium))
            .foregroundStyle(isDragging ? Color.accentColor : Color.primary)
            .frame(width: handleSize.width, height: handleSize.height)
            .floatingGlass(in: Circle())
            // 抓取範圍比看得到的大，拇指比較好點中。
            .frame(width: hitWidth, height: hitHeight, alignment: .trailing)
            .padding(.trailing, 6)
            .contentShape(Rectangle())
            .accessibilityElement()
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(Text("Jump to date"))
            .accessibilityIdentifier("photos.scrubber")
    }

    /// 沿著軌道排的年份。跟把手太近或彼此太擠的就不畫。
    private func yearRail(track: CGFloat,
                          metrics: ScrubController.Metrics,
                          handleCenter: CGFloat) -> some View {
        let marks = spacedYearMarks(track: track, metrics: metrics)

        return ZStack(alignment: .topTrailing) {
            ForEach(marks, id: \.year) { mark in
                if abs(mark.center - handleCenter) > 26 {
                    Text(verbatim: "\(mark.year)")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.regularMaterial, in: Capsule())
                        .overlay(Capsule().stroke(Color.primary.opacity(0.06)))
                        .offset(y: mark.center - 11)
                        .accessibilityIdentifier("scrubber.year")
                }
            }
        }
        .padding(.trailing, 64)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .allowsHitTesting(false)
        .transition(.opacity)
    }

    /// 把手旁邊的年月。
    private func monthBubble(metrics: ScrubController.Metrics, shown: CGFloat, handleCenter: CGFloat) -> some View {
        Group {
            if let anchor = topAnchor(metrics, shown: shown) {
                let parts = PhotoGrouping.calendar.dateComponents([.year, .month], from: anchor.date)
                Text(DateTitle.month(year: parts.year ?? 0, month: parts.month ?? 1))
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(.regularMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Color.primary.opacity(0.08)))
                    .shadow(color: .black.opacity(0.14), radius: 6, y: 2)
                    .offset(y: handleCenter - 19)
                    .accessibilityIdentifier("scrubber.month")
            }
        }
        .padding(.trailing, 64)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .allowsHitTesting(false)
        .transition(.opacity)
    }

    /// 畫面上方的日期區間，也就是現在畫面裡看得到哪一段。
    private func rangePill(metrics: ScrubController.Metrics, shown: CGFloat, atTop: Bool) -> some View {
        Group {
            if let top = topAnchor(metrics, shown: shown), let bottom = bottomAnchor(metrics, shown: shown) {
                Text(DateTitle.range(from: top.date, to: bottom.date))
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.regularMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Color.primary.opacity(0.08)))
                    .shadow(color: .black.opacity(0.14), radius: 6, y: 2)
                    .accessibilityIdentifier("scrubber.range")
            }
        }
        .padding(atTop ? .top : .bottom, atTop ? topInset : 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: atTop ? .top : .bottom)
        .allowsHitTesting(false)
        .transition(.opacity)
    }

    // MARK: - 位置換算

    /// 畫面最上面對到哪一段。內容捲得動就用真實的捲動位置；
    /// 一屏放得下、捲不動時，改用把手（手指）所在的比例。
    private func topAnchor(_ metrics: ScrubController.Metrics, shown: CGFloat) -> ScrubAnchor? {
        let weight: Double
        if metrics.range > 0 {
            weight = Double(metrics.offset / metrics.content) * index.totalWeight
        } else {
            weight = Double(shown) * index.totalWeight
        }
        return index.anchor(atWeight: max(0, min(weight, index.totalWeight - 0.0001)))
    }

    /// 畫面最下面對到哪一段。捲不動時，畫面裡看得到的就是全部。
    private func bottomAnchor(_ metrics: ScrubController.Metrics, shown: CGFloat) -> ScrubAnchor? {
        let weight: Double
        if metrics.range > 0 {
            weight = Double((metrics.offset + metrics.viewport) / metrics.content) * index.totalWeight
        } else {
            weight = index.totalWeight
        }
        return index.anchor(atWeight: max(0, min(weight, index.totalWeight - 0.0001)))
    }

    /// 每個年份在軌道上的位置。太擠的丟掉，優先留下比較新的。
    private func spacedYearMarks(track: CGFloat,
                                 metrics: ScrubController.Metrics) -> [(year: Int, center: CGFloat)] {
        guard index.totalWeight > 0 else { return [] }
        let scale = metrics.range > 0 ? metrics.content / metrics.range : 1

        var marks: [(year: Int, center: CGFloat)] = index.yearStarts.map { entry in
            let fraction = min(CGFloat(entry.start / index.totalWeight) * scale, 1)
            return (entry.year, topInset + handleSize.height / 2 + fraction * track)
        }
        marks.sort { $0.center < $1.center }

        let minimumGap: CGFloat = 26
        var kept: [(year: Int, center: CGFloat)] = []
        for mark in marks {
            if let last = kept.last, mark.center - last.center < minimumGap { continue }
            kept.append(mark)
        }
        return kept
    }

    // MARK: - 手勢與顯示時機

    private func drag(track: CGFloat, currentCenter: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named(space))
            .onChanged { value in
                if !isDragging {
                    hideTask?.cancel()
                    collapseTask?.cancel()
                    // 記下手指抓在把手的哪個位置，開始拖的時候畫面才不會跳一下。
                    grabOffset = value.startLocation.y - currentCenter
                    withMotion(.easeOut(duration: 0.15)) {
                        isDragging = true
                        isExpanded = true
                    }
                }
                let center = value.location.y - grabOffset
                let top = center - handleSize.height / 2 - topInset
                let fraction = min(max(top / track, 0), 1)
                dragFraction = fraction
                controller.scroll(toFraction: fraction)
            }
            .onEnded { _ in
                withMotion(.easeOut(duration: 0.2)) { isDragging = false }
                scheduleCollapse()
                scheduleHide()
            }
    }

    /// 一般捲動時讓把手出現，停下來一下再收。
    private func revealHandle() {
        if !isScrolling {
            withMotion(.easeOut(duration: 0.15)) { isScrolling = true }
        }
        scheduleHide()
    }

    private func scheduleHide() {
        hideTask?.cancel()
        hideTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            guard !Task.isCancelled, !isDragging else { return }
            withMotion(.easeOut(duration: 0.3)) { isScrolling = false }
            dragFraction = nil
        }
    }

    /// 放開後年月與日期先留一下再收起來，方便確認自己停在哪裡。
    private func scheduleCollapse() {
        collapseTask?.cancel()
        collapseTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            guard !Task.isCancelled, !isDragging else { return }
            withMotion(.easeOut(duration: 0.25)) { isExpanded = false }
        }
    }
}
