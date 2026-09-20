import SwiftUI
import Photos

/// 資料夾分頁：顯示本機已建立的相簿。
struct AlbumsTabView: View {
    @EnvironmentObject private var library: PhotoLibraryService

    @State private var albums: [AlbumSummary] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if albums.isEmpty {
                    ContentUnavailableView {
                        Label("No albums", systemImage: "folder")
                    } description: {
                        Text("Albums you create in the Photos app show up here.")
                    }
                } else {
                    List(albums) { album in
                        NavigationLink(value: album) {
                            HStack {
                                Text(album.title)
                                Spacer()
                                Text("\(album.count)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Folders")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        LibraryManagerView(initialTab: .albums)
                    } label: {
                        Image(systemName: "folder.badge.gearshape")
                    }
                    .accessibilityIdentifier("albums.manage")
                }
            }
            .navigationDestination(for: AlbumSummary.self) { album in
                AlbumDetailView(album: album)
            }
            .task { await reload() }
            .refreshable { await reload() }
        }
    }

    private func reload() async {
        isLoading = albums.isEmpty
        defer { isLoading = false }
        albums = await library.userAlbums()
    }
}

/// 相簿內容。
struct AlbumDetailView: View {
    let album: AlbumSummary

    @State private var assets: [PHAsset] = []

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(assets, id: \.localIdentifier) { asset in
                    AssetThumbnail(asset: asset, size: 130)
                }
            }
            .padding(.horizontal, 2)
        }
        .navigationTitle(album.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            assets = await load()
        }
    }

    private func load() async -> [PHAsset] {
        let id = album.id
        return await Task.detached(priority: .userInitiated) {
            guard let collection = PHAssetCollection
                .fetchAssetCollections(withLocalIdentifiers: [id], options: nil)
                .firstObject else { return [] }

            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            var found: [PHAsset] = []
            PHAsset.fetchAssets(in: collection, options: options).enumerateObjects { asset, _, _ in
                found.append(asset)
            }
            return found
        }.value
    }
}
