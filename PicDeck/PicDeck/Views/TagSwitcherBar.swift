import SwiftUI

/// 篩選到某個標籤之後，在最上面列出所有標籤，方便一鍵換一個看。
///
/// 只有正在依標籤篩選時才出現，平常瀏覽不會佔版面。
/// 順序跟著管理頁裡排好的順序走。
struct TagSwitcherBar: View {
    /// 目前選中的標籤。
    let selected: UUID?
    let onPick: (PhotoTag) -> Void
    /// 回到所有項目。
    let onClear: () -> Void

    @EnvironmentObject private var tagStore: TagStore

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    clearChip

                    ForEach(tagStore.tags) { tag in
                        chip(for: tag)
                            .id(tag.id)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .background(.bar)
            .overlay(alignment: .bottom) {
                Divider()
            }
            .onAppear { scroll(proxy) }
            .onChange(of: selected) { _ in scroll(proxy) }
        }
    }

    private var clearChip: some View {
        Button {
            onClear()
        } label: {
            Text("All Items")
                .font(.footnote.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color(.tertiarySystemFill), in: Capsule())
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("tagbar.all")
    }

    private func chip(for tag: PhotoTag) -> some View {
        let isSelected = tag.id == selected

        return Button {
            onPick(tag)
        } label: {
            HStack(spacing: 5) {
                IconLabel(raw: tag.symbol, size: 14)
                Text(tag.name)
                    .font(.footnote.weight(isSelected ? .semibold : .regular))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? Color.accentColor.opacity(0.18) : Color(.tertiarySystemFill),
                        in: Capsule())
            .overlay {
                if isSelected {
                    Capsule().stroke(Color.accentColor, lineWidth: 1.5)
                }
            }
            .foregroundStyle(isSelected ? Color.accentColor : .primary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tag.name)
        .accessibilityIdentifier("tagbar.tag")
    }

    /// 把選中的那顆捲到看得見的地方。
    private func scroll(_ proxy: ScrollViewProxy) {
        guard let selected else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo(selected, anchor: .center)
        }
    }
}
