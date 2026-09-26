import SwiftUI
import Photos

/// 頁尾點開標籤或相簿時，於功能列上方展開的水平膠囊列表（圖 2、圖 3 樣式）。
/// 整理頁面（單張與柵欄模式）與單張照片檢視共用此樣式。
struct QuickAssetChipsBar: View {
    enum Mode {
        case tags
        case albums
    }

    let mode: Mode
    let assets: [PHAsset]
    var assignedAlbumIDs: Binding<Set<String>>? = nil
    let onManage: () -> Void

    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var tagStore: TagStore
    @EnvironmentObject private var organized: OrganizedStore

    @State private var userAlbums: [AlbumSummary] = []
    @State private var currentAlbumIDs: Set<String> = []

    init(mode: Mode, asset: PHAsset, assignedAlbumIDs: Binding<Set<String>>? = nil, onManage: @escaping () -> Void) {
        self.mode = mode
        self.assets = [asset]
        self.assignedAlbumIDs = assignedAlbumIDs
        self.onManage = onManage
    }

    init(mode: Mode, assets: [PHAsset], assignedAlbumIDs: Binding<Set<String>>? = nil, onManage: @escaping () -> Void) {
        self.mode = mode
        self.assets = assets
        self.assignedAlbumIDs = assignedAlbumIDs
        self.onManage = onManage
    }

    private var assignedTagIDs: Set<UUID> {
        guard let first = assets.first else { return [] }
        if assets.count == 1 {
            return tagStore.tagIDs(for: first)
        }
        let sets = assets.map { tagStore.tagIDs(for: $0) }
        return sets.reduce(sets.first ?? []) { $0.intersection($1) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch mode {
            case .tags:
                HStack {
                    Label("標籤", systemImage: "tag")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button(action: onManage) {
                        HStack(spacing: 4) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.caption)
                            Text("管理")
                                .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("quick.tag.manage")
                }
                .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tagStore.tagsByRecentUse) { tag in
                            let isOn = assignedTagIDs.contains(tag.id)
                            Button {
                                toggleTag(tag.id)
                            } label: {
                                HStack(spacing: 4) {
                                    if !tag.symbol.isEmpty {
                                        IconLabel(raw: tag.symbol, size: 12, tintOverride: isOn ? .white : nil)
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
                    }
                    .padding(.horizontal, 14)
                }

            case .albums:
                HStack {
                    Label("相簿", systemImage: "rectangle.stack")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button(action: onManage) {
                        HStack(spacing: 4) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.caption)
                            Text("管理")
                                .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("quick.album.manage")
                }
                .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(userAlbums) { album in
                            let isOn = currentAlbumIDs.contains(album.id)
                            Button {
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
                    }
                    .padding(.horizontal, 14)
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 10)
        .task(id: assets.map(\.localIdentifier)) {
            await reloadAlbums()
        }
    }

    private func toggleTag(_ tagID: UUID) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let isOn = assignedTagIDs.contains(tagID)
        if isOn {
            tagStore.removeTag(tagID, from: assets)
        } else {
            tagStore.addTag(tagID, to: assets)
            for asset in assets {
                organized.markOrganized(asset)
            }
        }
    }

    private func toggleAlbum(_ album: AlbumSummary) {
        let inAlbum = currentAlbumIDs.contains(album.id)
        if inAlbum {
            currentAlbumIDs.remove(album.id)
            assignedAlbumIDs?.wrappedValue.remove(album.id)
            Task {
                try? await library.removeAssets(assets, fromAlbumWithID: album.id)
                await reloadAlbums()
            }
        } else {
            currentAlbumIDs.insert(album.id)
            assignedAlbumIDs?.wrappedValue.insert(album.id)
            for asset in assets {
                organized.markOrganized(asset)
            }
            Task {
                try? await library.addAssets(assets, toAlbumWithID: album.id)
                await reloadAlbums()
            }
        }
    }

    private func reloadAlbums() async {
        userAlbums = await library.userAlbums()
        guard !assets.isEmpty else { currentAlbumIDs = []; return }
        if assets.count == 1, let first = assets.first {
            let ids = library.albumIDs(for: first)
            currentAlbumIDs = ids
            assignedAlbumIDs?.wrappedValue = ids
        } else {
            let sets = assets.map { library.albumIDs(for: $0) }
            let common = sets.reduce(sets.first ?? []) { $0.intersection($1) }
            currentAlbumIDs = common
            assignedAlbumIDs?.wrappedValue = common
        }
    }
}
