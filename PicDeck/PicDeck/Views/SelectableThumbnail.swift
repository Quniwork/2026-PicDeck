import SwiftUI
import Photos

/// 多選模式下的縮圖：右下角有勾選圈，選中時整張變暗並加框。
struct SelectableThumbnail: View {
    let asset: PHAsset
    let size: CGFloat
    let isSelecting: Bool
    let isSelected: Bool
    let onToggle: () -> Void
    /// 非多選模式時的長按選單。
    var menu: (() -> AnyView?)? = nil
    var fitsAspect: Bool = false
    /// 不在多選模式時點一下要做什麼（打開檢視）。
    var onOpen: (() -> Void)? = nil
    /// 打開檢視時要從這張縮圖的位置展開，跟呼叫端的 namespace 配一對。
    var zoomNamespace: Namespace.ID? = nil

    var body: some View {
        Button {
            if isSelecting { onToggle() } else { onOpen?() }
        } label: {
            AssetThumbnail(asset: asset, size: size, fitsAspect: fitsAspect, showsFavorite: true)
                .modifier(ZoomSourceIfNeeded(id: asset.localIdentifier, namespace: zoomNamespace))
                .overlay {
                    if isSelecting && isSelected {
                        Rectangle().fill(Color.accentColor.opacity(0.25))
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    if isSelecting {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.body)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(isSelected ? .white : .white.opacity(0.9),
                                             isSelected ? Color.accentColor : .black.opacity(0.25))
                            .padding(4)
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(asset.accessibilitySummary)
        .accessibilityValue(isSelecting ? Text(isSelected ? "Selected" : "Not selected") : Text(""))
        .accessibilityIdentifier("selectable.thumb.\(asset.localIdentifier)")
        .photoActions { isSelecting ? nil : menu?() }
    }
}
