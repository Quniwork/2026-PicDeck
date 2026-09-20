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

    var body: some View {
        AssetThumbnail(asset: asset, size: size, fitsAspect: fitsAspect, showsFavorite: true)
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
            .onTapGesture {
                if isSelecting { onToggle() }
            }
            .photoActions { isSelecting ? nil : menu?() }
    }
}
