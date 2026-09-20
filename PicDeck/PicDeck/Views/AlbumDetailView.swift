import SwiftUI
import Photos

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
