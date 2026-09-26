import SwiftUI

/// 各分頁共用的尺寸與字級，改一處全部跟著變。
enum PageMetrics {
    /// 全 App 共用的左右邊界，與整理／更多的 insetGrouped 卡片外緣一致。
    /// Pro 使用 16pt；寬度 428pt 以上的 Pro Max 使用 20pt，補上系統卡片多出的 4pt。
    static let baseEdge: CGFloat = 16
    static var edge: CGFloat { groupedListEdge }
    static var groupedListEdge: CGFloat { baseEdge + (UIScreen.main.bounds.width >= 428 ? 4 : 0) }

    /// 間距階梯（4 點一階）。標題到內容用 md，區塊與區塊用 xl，同一區塊的列與列用 sm。
    static let gapXS: CGFloat = 4
    static let gapSM: CGFloat = 8
    static let gapMD: CGFloat = 12
    static let gapLG: CGFloat = 16
    static let gapXL: CGFloat = 24

    /// 大尺寸 iPhone 的工具列標題比清單多 4 點系統內距，依畫面寬度抵銷。
    static let titleNudge: CGFloat = 0
    /// 頂層標題列下方的內容起始位置，五個主分頁共用。
    static let largeTitleBodyOffset: CGFloat = 20
    /// 內容延伸到狀態列與透明導覽列後方時，初始項目仍從頁首控制項下方開始。
    static let headerUnderlapContentInset: CGFloat = 128
    /// 照片頁的可點擊標題本身已有額外位移，不套用功能頁的尺寸補償。
    static let photoTitleNudge: CGFloat = -1

    /// 標題（含副標）下面到第一個內容的距離；與列間距一致，讓標題和內容更緊湊。
    static let contentTopGap: CGFloat = gapXS
    /// 照片各時間層級的區段標題與內容保持同一節奏。
    static let photoSectionGap: CGFloat = gapMD
    /// 一段內容結束到下一個年月日標題的距離。
    static let photoSectionSpacing: CGFloat = gapXL
    /// 清單的第一個分組有小標題，小標題自己帶的留白，往上補回來才會跟其他頁的第一個內容同高。
    static let headerCompensation: CGFloat = -6
}

extension View {
    /// 縮圖：點下去打開檢視時，畫面從這張縮圖的位置放大展開，跟系統「照片」App 一樣，
    /// 不是從畫面下方蓋上來。iOS 18 以後才有這個 API，之前的系統退回原本的蓋板動畫。
    @ViewBuilder
    func zoomSource(id: String, in namespace: Namespace.ID) -> some View {
        if #available(iOS 18.0, *) {
            self.matchedTransitionSource(id: id, in: namespace)
        } else {
            self
        }
    }

    /// 檢視畫面本身：跟上面的 `zoomSource` 配對，同一個 id、同一個 namespace。
    @ViewBuilder
    func zoomDestination(id: String, in namespace: Namespace.ID) -> some View {
        if #available(iOS 18.0, *) {
            self.navigationTransition(.zoom(sourceID: id, in: namespace))
        } else {
            self
        }
    }
}

/// `zoomSource` 的 namespace 是可選的（不是每個縮圖元件的呼叫端都有接起來），
/// 用 modifier 包一層才能在 nil 時直接跳過，`@ViewBuilder` 擴充方法沒辦法處理可選的 namespace 參數。
struct ZoomSourceIfNeeded: ViewModifier {
    let id: String
    let namespace: Namespace.ID?

    func body(content: Content) -> some View {
        if let namespace {
            content.zoomSource(id: id, in: namespace)
        } else {
            content
        }
    }
}

/// 全 App 統一的「沒有內容」畫面：圖示、標題、說明文字，選配一顆動作按鈕。
/// 取代各頁各自兜的 `ContentUnavailableView` 或手刻版本——圖示大小、標題字級、說明文字的字級
/// 只在這裡定義一次，不然每頁看起來規格都不一樣（有的用預設字級、有的自己縮小、有的乾脆不套標題樣式）。
struct AppEmptyState: View {
    let icon: String
    let title: String
    var message: String? = nil
    var actionTitle: String? = nil
    var actionIdentifier: String = ""
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 34, weight: .regular))
                .foregroundStyle(.secondary)
                .padding(.bottom, 6)
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                    .accessibilityIdentifier(actionIdentifier)
            }
        }
        .padding(.horizontal, 36)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // 置中要含標題那塊高度，不然文案會偏低——標題是浮在上面的工具列，不是排版佔位，
        // 這裡往上蓋過去，工具列本來就疊在最上層，不會被擋住。
        .ignoresSafeArea(edges: .top)
    }
}

/// 字級規則。標題分兩組：旁邊有按鈕與副標的（照片、日記），跟單純的功能頁（首頁、整理、更多）。
enum TypeScale {
    static let titleWithActions: Font = .title2
    static let titlePlain: Font = .title
    static let subtitle: Font = .caption
    static let photoSectionTitle: Font = .title3.weight(.bold)
}

/// 選單裡標籤的圖示。選單只吃圖片，所以先把表情或圖標畫成圖片；沒解鎖顯示鎖頭。
struct TagMenuIcon: View {
    let tag: PhotoTag
    var isLocked: Bool = false

    var body: some View {
        if isLocked {
            Image(systemName: "lock.fill")
        } else {
            let renderer = ImageRenderer(content: IconLabel(raw: tag.symbol, size: 18)
                .frame(width: 22, height: 22))
            let _ = renderer.scale = 3
            if let image = renderer.uiImage {
                Image(uiImage: image).renderingMode(.original)
            } else {
                Image(systemName: "tag")
            }
        }
    }
}

/// 照片分頁、日記挑選共用的「過濾條件」選單段落：所有項目、喜好項目、已編輯、不在相簿中、媒體類型。
struct PhotoFilterMenuSection: View {
    let isSelected: (PhotoFilter) -> Bool
    let onSelect: (PhotoFilter) -> Void
    var showsSectionTitle = true

    @ViewBuilder
    var body: some View {
        if showsSectionTitle {
            Section("篩選方式：") { rows }
        } else {
            rows
        }
    }

    @ViewBuilder
    private var rows: some View {
        ForEach([PhotoFilter.all, .favorites, .edited, .notInAlbum]) { row($0) }
        Menu {
            ForEach([PhotoFilter.photos, .videos, .screenshots]) { row($0) }
        } label: {
            Label("媒體類型", systemImage: "photo.on.rectangle.angled")
        }
    }

    private func row(_ option: PhotoFilter) -> some View {
        Toggle(isOn: Binding(get: { isSelected(option) }, set: { _ in onSelect(option) })) {
            Label(option.title, systemImage: option.systemImage)
        }
    }
}

/// 照片篩選選單共用的兩種排序，系統選中的項目會顯示勾選狀態。
struct PhotoSortMenuSection: View {
    @Binding var sortsByAdded: Bool

    var body: some View {
        Toggle(isOn: Binding(get: { sortsByAdded }, set: { sortsByAdded = $0 })) {
            Label("按最近加入排序", systemImage: "clock")
        }
        Toggle(isOn: Binding(get: { !sortsByAdded }, set: { sortsByAdded = !$0 })) {
            Label("按拍攝日期排序", systemImage: "camera")
        }
    }
}

// MARK: - 底部功能列

private struct ActionBarCompactKey: EnvironmentKey { static let defaultValue = false }
extension EnvironmentValues {
    /// 功能列放不下時改成上面圖示、下面文字的窄版。
    fileprivate var actionBarCompact: Bool {
        get { self[ActionBarCompactKey.self] }
        set { self[ActionBarCompactKey.self] = newValue }
    }
}

/// 功能列的一排按鈕。寬度夠就是「圖示＋文字」橫排；小螢幕或英文文字太長就改窄版，身體也可強制維持橫排。
struct ActionBarRow<Content: View>: View {
    var isCompact = false
    var forceHorizontal = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        Group {
            if forceHorizontal {
                HStack(spacing: 0) { content() }
                    .environment(\.actionBarCompact, false)
            } else if isCompact {
                HStack(spacing: 0) { content() }
                    .environment(\.actionBarCompact, true)
            } else {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 0) { content() }
                        .environment(\.actionBarCompact, false)
                    HStack(spacing: 0) { content() }
                        .environment(\.actionBarCompact, true)
                }
            }
        }
    }
}

/// 功能列裡的按鈕，整理、多選、單張檢視共用。
struct ActionBarButton: View {
    let key: LocalizedStringKey
    let icon: String
    let id: String
    var isActive = false
    var isDestructive = false
    var iconOnly = false
    /// 一般狀態的顏色。深色的單張檢視用白色。
    var tint: Color = .primary
    var badgeCount: Int? = nil
    let action: () -> Void

    @Environment(\.actionBarCompact) private var compact

    var body: some View {
        let color = isDestructive ? Color.red : (isActive ? Color.accentColor : tint)
        Button(action: action) {
            Group {
                if iconOnly && compact {
                    Image(systemName: icon).font(.system(size: 20))
                        .overlay(alignment: .topTrailing) {
                            if let badgeCount, badgeCount > 0 {
                                Text("\(badgeCount)")
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 3)
                                    .frame(minWidth: 14, minHeight: 14)
                                    .background(Color.accentColor, in: Capsule())
                                    .offset(x: 8, y: -6)
                            }
                        }
                        .frame(minWidth: 48, minHeight: 48)
                } else if compact {
                    VStack(spacing: 3) {
                        Image(systemName: icon).font(.callout)
                            .overlay(alignment: .topTrailing) {
                                if let badgeCount, badgeCount > 0 {
                                    Text("\(badgeCount)")
                                        .font(.system(size: 9, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 3)
                                        .frame(minWidth: 13, minHeight: 13)
                                        .background(Color.accentColor, in: Capsule())
                                        .offset(x: 9, y: -6)
                                }
                            }
                        Text(key).font(.caption2).lineLimit(1).minimumScaleFactor(0.7)
                    }
                    .frame(minWidth: 44)
                } else {
                    HStack(spacing: 4) {
                        Label(key, systemImage: icon)
                        if let badgeCount, badgeCount > 0 {
                            Text("\(badgeCount)")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 4)
                                .frame(minWidth: 15, minHeight: 15)
                                .background(Color.accentColor, in: Capsule())
                        }
                    }
                    .font(.caption)
                    .lineLimit(1)
                    .fixedSize()
                }
            }
            .foregroundStyle(color)
            .padding(.vertical, compact ? 4 : 8)
            .padding(.horizontal, 2)
            .background(Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(key))
        .accessibilityIdentifier(id)
    }
}

extension View {
    /// 兩指張開放大（每列張數變少）、捏合縮小（變多）。所有格狀畫面共用。
    /// 用 simultaneousGesture，不會擋住捲動與點照片。
    func pinchToZoomGrid(_ zoom: @escaping (_ zoomIn: Bool) -> Void) -> some View {
        simultaneousGesture(
            MagnifyGesture().onEnded { value in
                if value.magnification > 1.15 { zoom(true) }
                else if value.magnification < 0.87 { zoom(false) }
            }
        )
    }
}

// MARK: - 失敗提示

private struct FailureToastModifier: ViewModifier {
    @EnvironmentObject private var library: PhotoLibraryService
    @State private var hideTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let failure = library.failure {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                        Text(failure.text).font(.footnote.weight(.medium)).lineLimit(2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .floatingGlass(in: Capsule())
                    .padding(.bottom, 110)
                    .padding(.horizontal, PageMetrics.edge)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .accessibilityAddTraits(.updatesFrequently)
                    .accessibilityIdentifier("failure.toast")
                }
            }
            .sensoryFeedback(.error, trigger: library.failure?.id)
            .onChange(of: library.failure) { _, new in
                hideTask?.cancel()
                guard new != nil else { return }
                hideTask = Task {
                    try? await Task.sleep(nanoseconds: 3_500_000_000)
                    guard !Task.isCancelled else { return }
                    withMotion { library.failure = nil }
                }
            }
            .motionAnimation(value: library.failure)
    }
}

extension View {
    /// 操作失敗（例如加到相簿失敗）時，在畫面底部顯示提示。
    func failureToast() -> some View { modifier(FailureToastModifier()) }
}

extension View {
    /// 篩選鈕的狀態提示：有套用篩選（不是預設）就在右上角放紅點。
    /// 系統的選單會吃掉點擊，快速點兩下打不到這顆鈕，所以恢復預設放在選單最上面（見 `ResetFiltersButton`）。
    func filterIndicator(isActive: Bool, reset: @escaping () -> Void) -> some View {
        overlay(alignment: .topTrailing) {
            if isActive {
                Circle().fill(.red).frame(width: 7, height: 7).offset(x: 4, y: -3)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityValue(isActive ? Text("已篩選") : Text(""))
        .accessibilityAction(named: Text("重設篩選")) { if isActive { reset() } }
    }
}

/// 選單最上面的「恢復預設篩選」，有套用篩選時才出現。
struct ResetFiltersButton: View {
    let isActive: Bool
    let reset: () -> Void

    var body: some View {
        if isActive {
            Button(role: .destructive) {
                withMotion { reset() }
            } label: {
                Label("重設篩選條件", systemImage: "arrow.counterclockwise")
            }
            .accessibilityIdentifier("filter.reset")
            Divider()
        }
    }
}

extension View {
    /// 全頁使用同一個分組底色，讓清單與卡片在淺色、深色模式都有清楚層次。
    func appCanvas() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
    }

    /// 功能頁（整理、更多）的清單共用樣式：分組間距與第一個內容的位置在這裡統一，頁面不要自己補值。
    ///
    /// 圓角卡片跟標題怎麼對齊：insetGrouped 的分組本身會自動離螢幕邊緣留一段系統margin，
    /// 這段margin因裝置而異、且不是 listRowInsets 能蓋掉的（listRowInsets只管分組「裡面」的內距，
    /// 會疊加在這段margin上面）。所以改成明確指定這段margin＝PageMetrics.edge，卡片的外緣才會跟
    /// 標題、其他頁的內容對在同一條線上；卡片「裡面」文字要不要再縮一點是 pageRowInsets 的事，
    /// 兩層各管各的，不會互相疊加出裝置量出來不一樣的邊距。
    func pageList(firstSectionHasHeader: Bool = false, underlapsHeader: Bool = false) -> some View {
        self
            .listStyle(.insetGrouped)
            .listSectionSpacing(.custom(PageMetrics.gapLG))
            // 依裝置寬度跟原生 large title 的 leading inset 對齊分組卡片外緣。
            .contentMargins(.horizontal, PageMetrics.groupedListEdge, for: .scrollContent)
            .contentMargins(.top, underlapsHeader ? PageMetrics.headerUnderlapContentInset :
                            (firstSectionHasHeader ? PageMetrics.headerCompensation : PageMetrics.contentTopGap),
                            for: .scrollContent)
            .appCanvas()
            .ignoresSafeArea(edges: underlapsHeader ? .top : [])
    }

    /// `pageList()` 搭配用：卡片外緣已經對齊 `PageMetrics.edge`（見上面），這裡只管卡片「裡面」
    /// 文字要留多少讀起來舒服的內距，用一般行動裝置介面常見的 16pt。
    func pageRowInsets(vertical: CGFloat = 11) -> some View {
        self.listRowInsets(EdgeInsets(top: vertical, leading: 16, bottom: vertical, trailing: 16))
    }
}
