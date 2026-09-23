import SwiftUI
import Photos

/// 載入照片、依定位顯示的封面。卡片用。
struct TagCoverImage: View {
    let assetID: String
    var size: CGFloat
    var framing: CoverFraming = .standard

    @State private var image: UIImage?

    var body: some View {
        Rectangle()
            .fill(Color(.secondarySystemBackground))
            .overlay {
                if let image { PositionedImage(image: image, framing: framing) }
            }
            .clipped()
            .task(id: assetID) {
                guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil).firstObject else { return }
                image = await ThumbnailLoader.shared.image(for: asset, size: size)
            }
    }
}

/// 設定標籤的封面：從這個標籤的照片挑一張，再拖曳與縮放調整要露出哪一塊。
/// 預覽有方形與寬形兩種，因為卡片與桌面小工具的形狀不同，位置是同一組設定。
struct TagCoverEditorView: View {
    let tagID: UUID

    @EnvironmentObject private var tagStore: TagStore
    @EnvironmentObject private var library: PhotoLibraryService
    @Environment(\.dismiss) private var dismiss

    enum Shape: String, CaseIterable, Identifiable {
        case square, wide
        var id: String { rawValue }
        var ratio: CGFloat { self == .square ? 1 : 2 }
    }

    @State private var assets: [PHAsset] = []
    @State private var selectedID: String?
    @State private var framing: CoverFraming = .standard
    @State private var image: UIImage?
    @State private var shape: Shape = .square
    @State private var dragStart: CoverFraming?

    private var tag: PhotoTag? { tagStore.tag(withID: tagID) }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 4)

    var body: some View {
        Form {
            Section {
                preview
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                Picker("Preview shape", selection: $shape) {
                    Text("Square").tag(Shape.square)
                    Text("Wide").tag(Shape.wide)
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("cover.shape")
            } footer: {
                Text("Drag the photo to move it, and use the slider to zoom.")
            }

            Section {
                HStack {
                    Image(systemName: "minus.magnifyingglass").foregroundStyle(.secondary)
                    Slider(value: $framing.zoom, in: CoverFraming.zoomRange)
                        .accessibilityIdentifier("cover.zoom")
                    Image(systemName: "plus.magnifyingglass").foregroundStyle(.secondary)
                }
                Button("Reset position") { framing = .standard }
                    .disabled(framing.isDefault)
            }

            Section {
                Button {
                    selectedID = nil
                    framing = .standard
                    image = nil
                } label: {
                    HStack {
                        Label("Automatic (newest photo)", systemImage: "sparkles")
                        Spacer()
                        if selectedID == nil { Image(systemName: "checkmark").foregroundStyle(.tint) }
                    }
                }
                .accessibilityIdentifier("cover.auto")

                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(assets, id: \.localIdentifier) { asset in
                        Button {
                            choose(asset)
                        } label: {
                            AssetThumbnail(asset: asset, size: 160, showsDuration: false)
                                .overlay {
                                    if selectedID == asset.localIdentifier {
                                        Rectangle().strokeBorder(Color.accentColor, lineWidth: 3)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(asset.accessibilitySummary)
                        .accessibilityValue(Text(selectedID == asset.localIdentifier ? "Selected" : "Not selected"))
                        .accessibilityIdentifier("cover.photo")
                    }
                }
            } header: {
                Text("Choose a photo")
            }
        }
        .appCanvas()
        .navigationTitle("Cover")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    tagStore.setCover(tagID, assetID: selectedID, framing: framing)
                    dismiss()
                }
                .accessibilityIdentifier("cover.save")
            }
        }
        .task { load() }
    }

    // MARK: - 預覽（可拖曳）

    private var preview: some View {
        GeometryReader { geo in
            let frame = CGSize(width: geo.size.width, height: geo.size.width / shape.ratio)
            ZStack {
                Color(.tertiarySystemFill)
                if let image {
                    PositionedImage(image: image, framing: framing)
                } else {
                    Text(selectedID == nil ? "Automatic" : "")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .frame(width: frame.width, height: frame.height)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard let image else { return }
                        let start = dragStart ?? framing
                        dragStart = start
                        // 手指往右拉，露出照片左邊：x 往負的方向走。
                        let size = start.filledSize(image: image.size, frame: frame)
                        let roomX = max(1, (size.width - frame.width) / 2)
                        let roomY = max(1, (size.height - frame.height) / 2)
                        var next = start
                        next.x = start.x - Double(value.translation.width / roomX)
                        next.y = start.y - Double(value.translation.height / roomY)
                        framing = next.clamped()
                    }
                    .onEnded { _ in dragStart = nil }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 300)
        .padding(.vertical, 8)
        .accessibilityIdentifier("cover.preview")
    }

    // MARK: - 邏輯

    private func load() {
        guard let tag else { return }
        assets = library.assets(withIDs: tagStore.assetIDs(withTag: tag.id))
            .sorted { ($0.creationDate ?? .distantPast) > ($1.creationDate ?? .distantPast) }
        selectedID = tag.coverAssetID
        framing = tag.coverFraming
        if let id = selectedID, let asset = library.asset(withID: id) { loadImage(asset) }
    }

    private func choose(_ asset: PHAsset) {
        selectedID = asset.localIdentifier
        framing = .standard
        loadImage(asset)
    }

    private func loadImage(_ asset: PHAsset) {
        Task { image = await ThumbnailLoader.shared.image(for: asset, size: 900) }
    }
}
