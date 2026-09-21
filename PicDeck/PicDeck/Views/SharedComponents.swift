import SwiftUI

/// 各分頁共用的尺寸與字級，改一處全部跟著變。
enum PageMetrics {
    /// 標題（含副標）下面到第一個內容的距離。
    static let contentTopGap: CGFloat = 0
    /// 頁面左右的邊距。
    static let sideMargin: CGFloat = 16
    /// 年、月、日這幾種「一塊一塊」的畫面，內容左右邊距。跟左上角標題文字的左邊對齊。
    static let contentInset: CGFloat = 26
}

/// 字級規則。標題分兩組：旁邊有按鈕與副標的（照片、日記），跟單純的功能頁（首頁、整理、更多）。
enum TypeScale {
    static let titleWithActions: Font = .title2
    static let titlePlain: Font = .title
    static let subtitle: Font = .caption
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

    var body: some View {
        Section(String(localized: "Filter by:")) {
            ForEach([PhotoFilter.all, .favorites, .edited, .notInAlbum]) { row($0) }
            Menu {
                ForEach([PhotoFilter.photos, .videos, .screenshots]) { row($0) }
            } label: {
                Label(String(localized: "Media Types"), systemImage: "photo.on.rectangle.angled")
            }
        }
    }

    private func row(_ option: PhotoFilter) -> some View {
        Toggle(isOn: Binding(get: { isSelected(option) }, set: { _ in onSelect(option) })) {
            Label(option.title, systemImage: option.systemImage)
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

/// 功能列的一排按鈕。寬度夠就是「圖示＋文字」橫排；小螢幕或英文文字太長就改窄版，不會被切掉。
struct ActionBarRow<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 0) { content() }
                .environment(\.actionBarCompact, false)
            HStack(spacing: 0) { content() }
                .environment(\.actionBarCompact, true)
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
    /// 一般狀態的顏色。深色的單張檢視用白色。
    var tint: Color = .primary
    let action: () -> Void

    @Environment(\.actionBarCompact) private var compact

    var body: some View {
        let color = isDestructive ? Color.red : (isActive ? Color.accentColor : tint)
        Button(action: action) {
            Group {
                if compact {
                    VStack(spacing: 3) {
                        Image(systemName: icon).font(.callout)
                        Text(key).font(.caption2).lineLimit(1).minimumScaleFactor(0.7)
                    }
                    .frame(minWidth: 44)
                } else {
                    Label(key, systemImage: icon)
                        .font(.caption)
                        .labelStyle(.titleAndIcon)
                        .lineLimit(1)
                        .fixedSize()
                }
            }
            .foregroundStyle(color)
            .padding(.vertical, compact ? 4 : 8)
            .padding(.horizontal, isActive ? 6 : 2)
            .background(isActive ? Color.accentColor.opacity(0.14) : Color.clear, in: Capsule())
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
                    .padding(.horizontal, 20)
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

// MARK: - 字級

/// 整個 App 的字比系統設定小兩級（預設「大」就變成「小」，跟分頁列的字差不多）。
/// 使用者在系統調大文字，App 也會跟著調大，只是永遠維持小兩級。
struct RelativeTypeSize: ViewModifier {
    @Environment(\.dynamicTypeSize) private var system
    var steps = 2

    func body(content: Content) -> some View {
        let all = DynamicTypeSize.allCases
        let index = all.firstIndex(of: system) ?? 0
        return content.dynamicTypeSize(all[max(0, index - steps)])
    }
}
