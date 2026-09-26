import SwiftUI
import UIKit

/// 全專案共用的 Liquid Glass 樣式。iOS 26 以後用系統的玻璃，之前的系統退回半透明材質。
///
/// 使用原則：玻璃只給「浮在內容上面的操作層」，例如頁首按鈕、底部功能列、浮動把手，
/// 不要拿來做內容本身的卡片。玻璃疊在玻璃上會變髒，需要放在一起的用 `GlassGroup` 包起來。
extension View {
    /// 浮在內容上的玻璃面板。`interactive` 打開後按下去會有系統的回饋動畫，按鈕都應該開。
    @ViewBuilder
    func floatingGlass<S: Shape>(in shape: S, interactive: Bool = false, tint: Color? = nil) -> some View {
        if #available(iOS 26.0, *) {
            let base: Glass = .regular
            let tinted = tint.map { base.tint($0) } ?? base
            self.glassEffect(interactive ? tinted.interactive() : tinted, in: shape)
        } else {
            self
                .background(.regularMaterial, in: shape)
                .overlay(shape.stroke(Color.primary.opacity(0.08)))
                .shadow(color: .black.opacity(0.10), radius: 8, y: 2)
        }
    }

    /// 導覽列標題下面的副標題，例如「11,521 個項目」。iOS 26 才有，之前的系統不顯示。
    @ViewBuilder
    func subtitleIfAvailable(_ text: String) -> some View {
        if #available(iOS 26.0, *) {
            self.navigationSubtitle(text)
        } else {
            self
        }
    }

    /// 內容捲到玻璃後面時，邊緣做柔化，玻璃上的字才讀得清楚。iOS 26 以後才有。
    @ViewBuilder
    func softScrollEdges() -> some View {
        if #available(iOS 26.0, *) {
            self.scrollEdgeEffectStyle(.soft, for: .all)
        } else {
            self
        }
    }

    /// 為 View 套用無邊界 Header 遮罩並隱藏系統導覽列背景與分隔線。
    func borderlessHeaderScrim(height: CGFloat = 140, color: Color? = nil) -> some View {
        self
            .toolbarBackground(.hidden, for: .navigationBar)
            .background(NavigationBarSeparatorHider())
            .overlay(alignment: .top) {
                BorderlessHeaderScrim(height: height, customColor: color)
            }
    }
}

/// 無邊界 Header 遮罩：漸層由頂部向漸變淡出至透明（.clear），沒有 iOS 預設導覽列的底線與區塊硬切感。
struct BorderlessHeaderScrim: View {
    @Environment(\.colorScheme) private var colorScheme
    var height: CGFloat = 140
    var customColor: Color? = nil

    var body: some View {
        let baseColor = customColor ?? (colorScheme == .dark ? Color.black : Color(.systemBackground))
        let fade = LinearGradient(
            stops: [
                .init(color: .black, location: 0),
                .init(color: .black, location: 0.48),
                .init(color: .clear, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )

        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .mask(fade)

            LinearGradient(
                stops: [
                    .init(color: baseColor.opacity(colorScheme == .dark ? 0.52 : 0.70), location: 0.0),
                    .init(color: baseColor.opacity(colorScheme == .dark ? 0.38 : 0.50), location: 0.45),
                    .init(color: baseColor.opacity(colorScheme == .dark ? 0.12 : 0.16), location: 0.76),
                    .init(color: .clear, location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(height: height)
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
    }
}

/// 把幾個玻璃元件放進同一個容器，它們靠近時會像液體一樣融合，也避免玻璃各自取樣互相干擾。
struct GlassGroup<Content: View>: View {
    var spacing: CGFloat = 12
    @ViewBuilder let content: () -> Content

    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) { content() }
        } else {
            content()
        }
    }
}

/// 限定在目前導覽堆疊的導覽列上，移除系統預設的底部分隔線，並於離開時還原。
struct NavigationBarSeparatorHider: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller { Controller() }

    func updateUIViewController(_ controller: Controller, context: Context) {
        controller.updateAppearance()
    }

    final class Controller: UIViewController {
        private weak var configuredBar: UINavigationBar?
        private var originalStandard: UINavigationBarAppearance?
        private var originalScrollEdge: UINavigationBarAppearance?
        private var originalCompact: UINavigationBarAppearance?
        private var originalCompactScrollEdge: UINavigationBarAppearance?

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            updateAppearance()
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            restoreAppearance()
        }

        func updateAppearance() {
            guard let bar = navigationController?.navigationBar else { return }
            if configuredBar !== bar {
                restoreAppearance()
                configuredBar = bar
                originalStandard = bar.standardAppearance.copy() as? UINavigationBarAppearance
                originalScrollEdge = bar.scrollEdgeAppearance?.copy() as? UINavigationBarAppearance
                originalCompact = bar.compactAppearance?.copy() as? UINavigationBarAppearance
                originalCompactScrollEdge = bar.compactScrollEdgeAppearance?.copy() as? UINavigationBarAppearance
            }

            [bar.standardAppearance, bar.scrollEdgeAppearance, bar.compactAppearance, bar.compactScrollEdgeAppearance]
                .compactMap { $0 }
                .forEach { $0.shadowColor = .clear }
        }

        private func restoreAppearance() {
            guard let bar = configuredBar else { return }
            if let originalStandard { bar.standardAppearance = originalStandard }
            bar.scrollEdgeAppearance = originalScrollEdge
            bar.compactAppearance = originalCompact
            bar.compactScrollEdgeAppearance = originalCompactScrollEdge
            configuredBar = nil
            originalStandard = nil
            originalScrollEdge = nil
            originalCompact = nil
            originalCompactScrollEdge = nil
        }
    }
}

/// 玻璃圓形按鈕，頁首的關閉、更多、垃圾桶這類都用它。點擊範圍固定 44 點，符合 HIG 的最小尺寸。
struct GlassCircleButton<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button(action: action) {
            label()
                .font(.body.weight(.medium))
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .floatingGlass(in: Circle(), interactive: true)
    }
}

/// 表單最下面的「刪除xx」：紅字置中，沒有底色。
struct DestructiveRowButton: View {
    let title: String
    var identifier: String = ""
    let action: () -> Void

    var body: some View {
        Button(role: .destructive, action: action) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .listRowBackground(Color.clear)
        .accessibilityIdentifier(identifier)
    }
}

/// 各分頁的標題：跟照片分頁一樣靠左、貼近頂端的一行字，不用系統的大標題（上面會留一大塊空白）。
struct LeadingTitleToolbar: ToolbarContent {
    let title: String
    var accessibilityIdentifier = "page.title"
    /// 首頁、整理、更多用大一點的；日記旁邊有兩顆按鈕，維持較小。
    var font: Font = TypeScale.titlePlain

    /// 標題下面的小字，例如「2 則日記」。
    var subtitle: String? = nil
    /// 副標暫時隱藏時仍維持主標題的位置，避免捲動時標題上下跳動。
    var reservesSubtitleAlignment = false
    var titleColor: Color? = nil
    var subtitleColor: Color? = nil
    var hasTextShadow: Bool = false

    private var label: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(font.weight(.bold))
                .foregroundStyle(titleColor ?? Color.primary)
                .lineLimit(1)
                .fixedSize()
                .shadow(color: hasTextShadow ? .black.opacity(0.4) : .clear, radius: 2, y: 1)
            if let subtitle {
                Text(subtitle)
                    .font(TypeScale.subtitle)
                    .foregroundStyle(subtitleColor ?? Color.secondary)
                    .lineLimit(1)
                    .fixedSize()
                    .shadow(color: hasTextShadow ? .black.opacity(0.4) : .clear, radius: 2, y: 1)
            } else if reservesSubtitleAlignment {
                // 照片的其他層級在頂端隱藏副標，仍保留與「全部」相同的高度。
                Text(" ")
                    .font(TypeScale.subtitle)
                    .hidden()
            }
        }
        // 標題列與右側按鈕垂直對齊；有副標時下移整組，讓主標題仍對齊按鈕，副標自然跟在下方。
        // x 往左微調，讓字的左緣落在 PageMetrics.edge 上（系統工具列項目自己有內距）。
        .offset(x: PageMetrics.titleNudge, y: subtitle == nil && !reservesSubtitleAlignment ? 0 : 8)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    @ToolbarContentBuilder
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) { Text("").accessibilityHidden(true) }
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: .topBarLeading) { label }
                .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: .topBarLeading) { label }
        }
    }
}
