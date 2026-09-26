import SwiftUI
import Photos

/// 照片詳細資訊面板（點開資訊按鈕展開）：
/// 依使用者要求，僅顯示「備註」與「添加在哪些天的日記」。
/// 標籤與相簿則由頁尾按鈕展開獨立膠囊列表。
struct PhotoInspectorPanelView: View {
    let asset: PHAsset
    let onCollapse: () -> Void

    @EnvironmentObject private var noteStore: NoteStore
    @EnvironmentObject private var journalStore: JournalStore
    @EnvironmentObject private var tagStore: TagStore
    @Environment(\.scenePhase) private var scenePhase

    @State private var noteInput: String = ""
    @State private var showJournalEditor = false
    @State private var journalEntryForEdit: JournalEntry?
    @State private var autoSaveTask: Task<Void, Never>?
    @State private var editingAsset: PHAsset?
    @FocusState private var isNoteFocused: Bool

    private var entries: [JournalEntry] {
        journalStore.entries(for: asset)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 頂部拖曳把手、規格與收起按鈕
            handleHeader

            VStack(alignment: .leading, spacing: 14) {
                // MARK: - 1. 備註（直接就地編輯，即時儲存）
                noteSection

                // MARK: - 關鍵字(系統照片APP中建立)
                systemKeywordsSection

                // MARK: - 2. 添加在哪些天的日記
                journalSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .onChange(of: asset.localIdentifier, initial: true) { oldID, newID in
            if !oldID.isEmpty && oldID != newID, let editingAsset {
                saveNote(for: editingAsset)
            }
            editingAsset = asset
            noteInput = noteStore.note(for: asset)?.text ?? ""
        }
        .onChange(of: noteStore.notes) { _, _ in
            if !isNoteFocused {
                noteInput = noteStore.note(for: asset)?.text ?? ""
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active, !isNoteFocused {
                noteInput = noteStore.note(for: asset)?.text ?? ""
            }
        }
        .onChange(of: isNoteFocused) { _, focused in
            if !focused {
                saveNote()
            }
        }
        .onDisappear {
            saveNote()
        }
        .sheet(isPresented: $showJournalEditor) {
            if let entry = journalEntryForEdit {
                JournalEditorView(entry: entry)
            } else {
                let date = asset.creationDate ?? Date()
                let parts = PhotoGrouping.calendar.dateComponents([.year, .month, .day], from: date)
                JournalEditorView(year: parts.year ?? 0, month: parts.month ?? 0, day: parts.day ?? 0,
                                  preselectedIDs: [asset.localIdentifier],
                                  allowsDateChange: true)
            }
        }
    }

    // MARK: - 檔案名稱與規格計算

    private var assetFilename: String? {
        if #available(iOS 27.0, *), let name = asset.extendedMetadata.originalFilename, !name.isEmpty {
            return (name as NSString).deletingPathExtension
        }
        if let resource = PHAssetResource.assetResources(for: asset).first {
            let name = resource.originalFilename
            return (name as NSString).deletingPathExtension
        }
        if let name = asset.value(forKey: "filename") as? String {
            return (name as NSString).deletingPathExtension
        }
        return nil
    }

    private var mediaTypeDescription: String {
        if asset.mediaSubtypes.contains(.photoScreenshot) {
            return "截圖"
        } else if asset.mediaType == .video {
            return "影片"
        } else if asset.playbackStyle == .imageAnimated {
            return "GIF 動圖"
        } else {
            return "照片"
        }
    }

    private var assetFileSize: String? {
        guard let resource = PHAssetResource.assetResources(for: asset).first,
              let unsignedSize = resource.value(forKey: "fileSize") as? UInt64,
              unsignedSize > 0 else {
            return nil
        }
        return ByteCountFormatter.string(fromByteCount: Int64(unsignedSize), countStyle: .file)
    }

    // MARK: - 拖曳把手與標頭

    private var handleHeader: some View {
        VStack(spacing: 8) {
            Capsule()
                .fill(Color.secondary.opacity(0.35))
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    // 圖 1 #1：檔案名稱大小與顏色與副標題一致
                    if let filename = assetFilename, !filename.isEmpty {
                        Text(filename)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }

                    // 類型 • 尺寸 • 檔案大小（中圓點參考照片.app放大，尺寸無千分位）
                    HStack(spacing: 6) {
                        Text(mediaTypeDescription)
                        Text("•")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        Text("\(String(asset.pixelWidth)) × \(String(asset.pixelHeight))")
                        if let fileSize = assetFileSize {
                            Text("•")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            Text(fileSize)
                        }
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: onCollapse) {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("收起詳細資訊"))
                .accessibilityIdentifier("inspector.collapse")
            }
            .padding(.horizontal, 16)
        }
        .contentShape(Rectangle())
        .highPriorityGesture(
            DragGesture(minimumDistance: 10)
                .onEnded { value in
                    let dy = value.translation.height
                    let dx = abs(value.translation.width)
                    if dy > 20, dy > dx * 1.1 {
                        onCollapse()
                    }
                }
        )
    }

    // MARK: - 1. 備註（直接就地編輯）

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("備註")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(alignment: .center, spacing: 8) {
                TextField("加入備註…", text: $noteInput, axis: .vertical)
                    .font(.subheadline)
                    .lineLimit(1...5)
                    .focused($isNoteFocused)
                    .onChange(of: noteInput) { _, _ in
                        autoSaveTask?.cancel()
                        autoSaveTask = Task {
                            try? await Task.sleep(nanoseconds: 800_000_000)
                            guard !Task.isCancelled else { return }
                            saveNote()
                        }
                    }
                    .accessibilityIdentifier("inspector.note.input")

                if isNoteFocused {
                    Button {
                        isNoteFocused = false
                        saveNote()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.accentColor)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("完成編輯備註"))
                    .accessibilityIdentifier("inspector.note.done")
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func saveNote(for targetAsset: PHAsset? = nil) {
        autoSaveTask?.cancel()
        let targetAsset = targetAsset ?? asset
        let trimmed = noteInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let existing = noteStore.note(for: targetAsset)?.text ?? ""
        if trimmed != existing {
            noteStore.save(text: trimmed, for: targetAsset)
        }
    }

    // MARK: - 2. 添加在哪些天的日記

    private var journalSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("添加在哪些天的日記")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    journalEntryForEdit = nil
                    showJournalEditor = true
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                        Text("新增日記")
                            .font(.caption.weight(.semibold))
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)
                .accessibilityIdentifier("inspector.journal.addMore")
            }

            if entries.isEmpty {
                HStack {
                    Text("尚未加入任何日記")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        if index > 0 {
                            Divider()
                                .padding(.leading, 14)
                        }
                        Button {
                            journalEntryForEdit = entry
                            showJournalEditor = true
                        } label: {
                            HStack(spacing: 8) {
                                if !entry.mood.isEmpty {
                                    Text(entry.mood).font(.caption)
                                }
                                Text(entry.dateKey)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.primary)

                                if !entry.text.isEmpty {
                                    Text(entry.text)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("inspector.journal.entry.\(entry.dateKey)")
                    }
                }
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    // MARK: - 關鍵字(系統照片APP中建立)

    private var systemKeywords: [String] {
        tagStore.systemKeywords(for: asset).filter { kw in
            !tagStore.tags.contains { TagStore.normalizedName($0.name) == TagStore.normalizedName(kw) }
        }
    }

    @ViewBuilder
    private var systemKeywordsSection: some View {
        let keywords = systemKeywords
        if !keywords.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text("關鍵字(系統照片APP中建立)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    InspectorFlowLayout(spacing: 8) {
                        ForEach(keywords, id: \.self) { kw in
                            keywordChip(kw)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private func keywordChip(_ keyword: String) -> some View {
        HStack(spacing: 6) {
            Text(keyword)
                .font(.caption.weight(.medium))

            Button {
                tagStore.promoteKeywordToTag(keyword, for: asset)
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                    Text("轉為標籤")
                        .font(.caption2.weight(.semibold))
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.accentColor.opacity(0.15), in: Capsule())
                .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

// MARK: - 流水佈局（支援關鍵字自動換行）

private struct InspectorFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: width, height: currentY + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX, currentX > bounds.minX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
