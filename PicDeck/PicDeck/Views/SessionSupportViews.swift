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
            } else if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
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
            Color(.systemBackground).ignoresSafeArea()

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
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

    private let lines: [String] = [
        "向左滑動：保留相片",
        "向右滑動：返回上一張相片",
        "向上滑動：標記刪除",
        "向下滑動：加入喜愛",
        "點擊相簿：快速歸檔",
        "點擊兩下：放大檢視"
    ]

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark").font(.headline)
                }
                .accessibilityLabel(Text("關閉"))
                .accessibilityIdentifier("help.close")
            }

            Text("手勢教學指南")
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
                Text("開始教學").frame(maxWidth: .infinity)
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
    @EnvironmentObject private var organized: OrganizedStore
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
                                  title: "待刪除清單是空的",
                                  message: "向上滑動的照片會先移至此處。在確認刪除前不會真正移除。")
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 4) {
                            ForEach(assets, id: \.localIdentifier) { asset in
                                ZStack(alignment: .topTrailing) {
                                    AssetThumbnail(asset: asset, size: 110)

                                    Button {
                                        model.unmarkTrashed(asset.localIdentifier)
                                        organized.unmarkOrganized(asset)
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
                        .padding(.top, PageMetrics.headerUnderlapContentInset)
                    }
                    .safeAreaInset(edge: .bottom) {
                        VStack(spacing: 8) {
                            Text("已標記 \(model.trashedAssetIDs.count) 張")
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            Button {
                                showConfirm = true
                            } label: {
                                if isDeleting {
                                    ProgressView().frame(maxWidth: .infinity)
                                } else {
                                    Text("移至垃圾桶刪除").frame(maxWidth: .infinity)
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
                    .ignoresSafeArea(edges: .top)
                }
            }
            .navigationTitle("待刪除清單")
            .failureToast()
            .navigationBarTitleDisplayMode(.inline)
            .borderlessHeaderScrim()
            .overlay(alignment: .top) {
                HStack(spacing: 12) {
                    GlassCircleButton { dismiss() } label: { Image(systemName: "xmark") }
                        .accessibilityLabel(Text("關閉"))
                    Text("待刪除清單")
                        .font(.headline)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    if !model.trashedAssetIDs.isEmpty {
                        Button("全部復原") { restoreAll() }
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .frame(height: 44)
                            .floatingGlass(in: Capsule(), interactive: true)
                    }
                }
                .padding(.horizontal, PageMetrics.edge)
                .padding(.top, 8)
            }
            .toolbar(.hidden, for: .navigationBar)
            .task { await reload() }
            .alert("確定要刪除這 \(model.trashedAssetIDs.count) 張照片嗎？", isPresented: $showConfirm) {
                Button("取消", role: .cancel) {}
                Button("刪除", role: .destructive) { performDelete() }
            } message: {
                Text("照片將移至系統「最近刪除」相簿，可在 30 天內隨時復原。")
            }
        }
    }

    private func restoreAll() {
        for asset in assets {
            model.unmarkTrashed(asset.localIdentifier)
            organized.unmarkOrganized(asset)
        }
        assets.removeAll()
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
            .navigationTitle("歸檔至相簿…")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}
