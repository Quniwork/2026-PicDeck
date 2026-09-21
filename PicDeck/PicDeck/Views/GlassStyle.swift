import SwiftUI

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
    /// 首頁、整理、更多用大一點的；日記旁邊有兩顆按鈕，維持較小。
    var font: Font = TypeScale.titlePlain

    /// 標題下面的小字，例如「2 則日記」。
    var subtitle: String? = nil

    private var label: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(font.weight(.bold))
                .lineLimit(1)
                .fixedSize()
            if let subtitle {
                Text(subtitle)
                    .font(TypeScale.subtitle)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .fixedSize()
            }
        }
        // 跟右邊的按鈕視覺置中，不要偏上。
        .offset(y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
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
