import SwiftUI
import Photos

/// 審核畫面的照片卡，點一下可放大。
struct SessionPhotoCard: View {
    let asset: PHAsset
    @Binding var isZoomed: Bool

    @State private var image: UIImage?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))

            if asset.mediaType == .video {
                // 影片：點一下就播放，不需要另外進放大。
                InlineVideoView(asset: asset, poster: image)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                ProgressView()
            }

            if asset.mediaType == .video {
                VStack {
                    HStack {
                        Label(durationText, systemImage: "video.fill")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                        Spacer()
                    }
                    Spacer()
                }
                .padding(12)
            }
        }
        // 圖片雙擊放大；影片單擊就是播放，不搶手勢。
        .onTapGesture(count: 2) { if asset.mediaType != .video { isZoomed = true } }
        .fullScreenCover(isPresented: $isZoomed) {
            ZoomedPhotoView(asset: asset)
        }
        .task(id: asset.localIdentifier) {
            image = await ThumbnailLoader.shared.image(for: asset, size: 900)
        }
    }

    private var durationText: String {
        let total = Int(asset.duration.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

/// 點按放大後的全螢幕檢視。
struct ZoomedPhotoView: View {
    let asset: PHAsset
    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView().tint(.white)
            }

            VStack {
                HStack {
                    Spacer()
                    GlassCircleButton { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel(Text("Close"))
                    .padding()
                }
                Spacer()
            }
        }
        .task {
            image = await ThumbnailLoader.shared.image(for: asset, size: 1400)
        }
    }
}

/// 使用說明。對照參考 App 的「幫助」彈窗。
struct HelpSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showTutorial = false

    private let lines: [LocalizedStringKey] = [
        "Swipe left to keep",
        "Swipe right to go back to the previous photo",
        "Swipe up to delete",
        "Pull down to mark as favorite",
        "Tap an album to file it",
        "Double tap to zoom in"
    ]

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark").font(.headline)
                }
                .accessibilityLabel(Text("Close"))
                .accessibilityIdentifier("help.close")
            }

            Text("How to use")
                .font(.title2.weight(.bold))

            VStack(spacing: 14) {
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)

            Button {
                showTutorial = true
            } label: {
                Text("Start tutorial").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer(minLength: 0)
        }
        .padding(24)
        .presentationDetents([.medium, .large])
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView { showTutorial = false }
        }
    }
}

/// 審核畫面裡的待刪清單，可還原或確認刪除。
struct PendingTrashView: View {
    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    @State private var assets: [PHAsset] = []
    @State private var showConfirm = false
    @State private var isDeleting = false

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 4)]

    var body: some View {
        NavigationStack {
            Group {
                if model.trashedAssetIDs.isEmpty {
                    AppEmptyState(icon: "trash",
                                  title: String(localized: "Trash is empty"),
                                  message: String(localized: "Photos you swipe up land here first. Nothing is deleted until you confirm."))
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 4) {
                            ForEach(assets, id: \.localIdentifier) { asset in
                                ZStack(alignment: .topTrailing) {
                                    AssetThumbnail(asset: asset, size: 110)

                                    Button {
                                        model.unmarkTrashed(asset.localIdentifier)
                                        Task { await reload() }
                                    } label: {
                                        Image(systemName: "arrow.uturn.backward.circle.fill")
                                            .font(.title3)
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(.white, .black.opacity(0.5))
                                    }
                                    .padding(4)
                                }
                            }
                        }
                        .padding(4)
                    }
                    .safeAreaInset(edge: .bottom) {
                        VStack(spacing: 8) {
                            Text("\(model.trashedAssetIDs.count) marked")
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            Button {
                                showConfirm = true
                            } label: {
                                if isDeleting {
                                    ProgressView().frame(maxWidth: .infinity)
                                } else {
                                    Text("Delete permanently").frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .disabled(isDeleting)
                        }
                        .padding(16)
                        .floatingGlass(in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 6)
                    }
                }
            }
            .navigationTitle("Trash")
            .failureToast()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task { await reload() }
            .alert("Delete \(model.trashedAssetIDs.count) photos?", isPresented: $showConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) { performDelete() }
            } message: {
                Text("They go to the iOS Recently Deleted album and can be recovered within 30 days.")
            }
        }
    }

    private func reload() async {
        let ids = model.trashedAssetIDs
        guard !ids.isEmpty else { assets = []; return }

        var found: [PHAsset] = []
        PHAsset.fetchAssets(withLocalIdentifiers: ids, options: nil).enumerateObjects { asset, _, _ in
            found.append(asset)
        }
        assets = found
    }

    private func performDelete() {
        isDeleting = true
        let ids = model.trashedAssetIDs
        Task {
            let deleted = await library.attempt(String(localized: "Couldn't delete")) {
                try await library.delete(assetIDs: ids)
            }
            // 沒刪成（取消或失敗）就保留待刪清單，不要當成已經刪掉。
            if deleted {
                model.clearTrash()
                assets = []
            }
            isDeleting = false
        }
    }
}

/// 選擇要歸檔到哪個本機相簿。
struct AlbumQuickPicker: View {
    let albums: [AlbumSummary]
    let onPick: (AlbumSummary) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if albums.isEmpty {
                    AppEmptyState(icon: "folder",
                                  title: String(localized: "No albums"),
                                  message: String(localized: "Albums you create in the Photos app show up here."))
                } else {
                    List(albums) { album in
                        Button {
                            onPick(album)
                            dismiss()
                        } label: {
                            HStack {
                                Text(album.title).foregroundStyle(.primary)
                                Spacer()
                                Text("\(album.count)").foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("File into album…")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
