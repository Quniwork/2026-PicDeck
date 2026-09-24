import SwiftUI
import Photos

/// 頁尾點開標籤或相簿時，於功能列上方展開的水平膠囊列表（圖 2、圖 3 樣式）。
/// 整理頁面與單張照片檢視共用此樣式。
struct QuickAssetChipsBar: View {
    enum Mode {
        case tags
        case albums
    }

    let mode: Mode
    let asset: PHAsset
    var assignedAlbumIDs: Binding<Set<String>>? = nil
    let onManage: () -> Void

    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var tagStore: TagStore

    @State private var userAlbums: [AlbumSummary] = []
    @State private var currentAlbumIDs: Set<String> = []

    private var assignedTagIDs: Set<UUID> {
        tagStore.tagIDs(for: asset)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch mode {
            case .tags:
                Label("標籤", systemImage: "tag")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tagStore.tagsByRecentUse) { tag in
                            let isOn = assignedTagIDs.contains(tag.id)
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                tagStore.toggleTag(tag.id, for: asset)
                            } label: {
                                HStack(spacing: 4) {
                                    if !tag.symbol.isEmpty {
                                        IconLabel(raw: tag.symbol, size: 12)
                                    } else {
                                        Image(systemName: isOn ? "tag.fill" : "tag")
                                            .font(.system(size: 11))
                                    }
                                    Text(tag.name)
                                        .font(.subheadline.weight(.medium))
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .foregroundStyle(isOn ? Color.white : Color.primary)
                                .background(isOn ? Color.accentColor : Color(.tertiarySystemFill), in: Capsule())
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("quick.tag.chip.\(tag.name)")
                        }

                        Button(action: onManage) {
                            Label("管理", systemImage: "slider.horizontal.3")
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .foregroundStyle(.secondary)
                                .background(Color(.tertiarySystemFill), in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("quick.tag.manage")
                    }
                    .padding(.horizontal, 14)
                }

            case .albums:
                Label("相簿", systemImage: "rectangle.stack")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(userAlbums) { album in
                            let isOn = currentAlbumIDs.contains(album.id)
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                toggleAlbum(album)
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: isOn ? "rectangle.stack.fill" : "rectangle.stack")
                                        .font(.system(size: 11))
                                    Text(album.title)
                                        .font(.subheadline.weight(.medium))
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .foregroundStyle(isOn ? Color.white : Color.primary)
                                .background(isOn ? Color.accentColor : Color(.tertiarySystemFill), in: Capsule())
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("quick.album.chip.\(album.title)")
                        }

                        Button(action: onManage) {
                            Label("管理", systemImage: "slider.horizontal.3")
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .foregroundStyle(.secondary)
                                .background(Color(.tertiarySystemFill), in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("quick.album.manage")
                    }
                    .padding(.horizontal, 14)
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 10)
        .task(id: asset.localIdentifier) {
            await reloadAlbums()
        }
    }

    private func toggleAlbum(_ album: AlbumSummary) {
        let inAlbum = currentAlbumIDs.contains(album.id)
        if inAlbum {
            currentAlbumIDs.remove(album.id)
            assignedAlbumIDs?.wrappedValue.remove(album.id)
            Task {
                try? await library.removeAssets([asset], fromAlbumWithID: album.id)
                await reloadAlbums()
            }
        } else {
            currentAlbumIDs.insert(album.id)
            assignedAlbumIDs?.wrappedValue.insert(album.id)
            Task {
                try? await library.addAsset(asset, toAlbumWithID: album.id)
                await reloadAlbums()
            }
        }
    }

    private func reloadAlbums() async {
        userAlbums = await library.userAlbums()
        let ids = library.albumIDs(for: asset)
        currentAlbumIDs = ids
        assignedAlbumIDs?.wrappedValue = ids
    }
}
