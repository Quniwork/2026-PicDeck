import SwiftUI
import Photos

/// 月份卡片封面：挑選當月照片並調整裁切位置。
struct PhotoCoverEditorView: View {
    let title: String
    let candidates: [PHAsset]
    var aspectRatio: CGFloat = 4.0 / 3.0
    let initial: PhotoCoverPreference?
    let onSave: (PhotoCoverPreference?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedID: String?
    @State private var framing: CoverFraming = .standard
    @State private var image: UIImage?
    @State private var dragStart: CoverFraming?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 4)

    var body: some View {
        Form {
            Section {
                preview
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
            } footer: {
                Text("拖曳照片以調整位置，滑動拉桿進行縮放。")
            }

            Section {
                HStack {
                    Image(systemName: "minus.magnifyingglass").foregroundStyle(.secondary)
                    Slider(value: $framing.zoom, in: CoverFraming.zoomRange)
                    Image(systemName: "plus.magnifyingglass").foregroundStyle(.secondary)
                }
                Button("重設位置") { framing = .standard }
                    .disabled(framing.isDefault)
            }

            Section("挑選封面照片") {
                Button {
                    selectedID = nil
                    framing = .standard
                    if let newest = candidates.first { loadImage(newest) }
                } label: {
                    HStack {
                        Label("自動選取（最新照片）", systemImage: "sparkles")
                        Spacer()
                        if selectedID == nil { Image(systemName: "checkmark").foregroundStyle(.tint) }
                    }
                }
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(candidates, id: \.localIdentifier) { asset in
                        Button { choose(asset) } label: {
                            AssetThumbnail(asset: asset, size: 160, showsDuration: false)
                                .overlay {
                                    if selectedID == asset.localIdentifier {
                                        Rectangle().strokeBorder(Color.accentColor, lineWidth: 3)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(asset.accessibilitySummary)
                        .accessibilityIdentifier("month.cover.photo")
                    }
                }
            }
        }
        .appCanvas()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("儲存") {
                    onSave(selectedID.map { PhotoCoverPreference(assetID: $0, framing: framing.clamped()) })
                    dismiss()
                }
            }
        }
        .onAppear {
            selectedID = initial?.assetID
            framing = initial?.framing ?? .standard
            if let selectedID {
                if let asset = candidates.first(where: { $0.localIdentifier == selectedID }) {
                    loadImage(asset)
                } else if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [selectedID], options: nil).firstObject {
                    loadImage(asset)
                }
            } else if let newest = candidates.first {
                loadImage(newest)
            }
        }
    }

    private var preview: some View {
        GeometryReader { geometry in
            let frame = CGSize(width: geometry.size.width, height: geometry.size.width / aspectRatio)
            ZStack {
                Color(.tertiarySystemFill)
                if let image {
                    PositionedImage(image: image, framing: framing)
                } else {
                    Text("自動選取").font(.footnote).foregroundStyle(.secondary)
                }
            }
            .frame(width: frame.width, height: frame.height)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .gesture(DragGesture().onChanged { value in
                guard let image else { return }
                let start = dragStart ?? framing
                dragStart = start
                let size = start.filledSize(image: image.size, frame: frame)
                let roomX = max(1, (size.width - frame.width) / 2)
                let roomY = max(1, (size.height - frame.height) / 2)
                var next = start
                next.x = start.x - Double(value.translation.width / roomX)
                next.y = start.y - Double(value.translation.height / roomY)
                framing = next.clamped()
            }.onEnded { _ in dragStart = nil })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 260)
        .padding(.vertical, 8)
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
