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

    @State private var noteInput: String = ""
    @State private var showJournalEditor = false
    @State private var journalEntryForEdit: JournalEntry?

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

                // MARK: - 2. 添加在哪些天的日記
                journalSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 16)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .onChange(of: asset.localIdentifier, initial: true) { _, _ in
            noteInput = noteStore.note(for: asset)?.text ?? ""
        }
        .sheet(isPresented: $showJournalEditor) {
            if let entry = journalEntryForEdit {
                JournalEditorView(entry: entry)
            } else if let date = asset.creationDate {
                let parts = PhotoGrouping.calendar.dateComponents([.year, .month, .day], from: date)
                JournalEditorView(year: parts.year ?? 0, month: parts.month ?? 0, day: parts.day ?? 0,
                                  preselectedIDs: [asset.localIdentifier])
            }
        }
    }

    // MARK: - 拖曳把手與標頭

    private var handleHeader: some View {
        VStack(spacing: 6) {
            Capsule()
                .fill(Color.secondary.opacity(0.35))
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            HStack {
                // 左側：照片規格與類型（日期時間已在頂部導覽列顯示，不重複）
                HStack(spacing: 6) {
                    Text("\(asset.pixelWidth) × \(asset.pixelHeight)")
                        .font(.caption.monospacedDigit().weight(.medium))
                        .foregroundStyle(.secondary)

                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)

                    Text(asset.mediaType == .video ? "影片" : (asset.playbackStyle == .imageAnimated ? "GIF 動圖" : "照片"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: onCollapse) {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("收起詳細資訊"))
                .accessibilityIdentifier("inspector.collapse")
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 4)
        }
    }

    // MARK: - 1. 備註（直接就地編輯）

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("備註", systemImage: "note.text")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "pencil")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)

                TextField("加入備註…", text: $noteInput, axis: .vertical)
                    .font(.subheadline)
                    .lineLimit(1...5)
                    .onChange(of: noteInput) { _, newValue in
                        noteStore.save(text: newValue, for: asset)
                    }
                    .accessibilityIdentifier("inspector.note.input")

                if !noteInput.isEmpty {
                    Button {
                        noteInput = ""
                        noteStore.save(text: "", for: asset)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("inspector.note.clear")
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: - 2. 添加在哪些天的日記

    private var journalSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("添加在哪些天的日記", systemImage: "book.closed")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            if entries.isEmpty {
                HStack {
                    Text("尚未加入任何日記")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        journalEntryForEdit = nil
                        showJournalEditor = true
                    } label: {
                        Label("撰寫這天的日記", systemImage: "square.and.pencil")
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .accessibilityIdentifier("inspector.journal.create")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                VStack(spacing: 6) {
                    ForEach(entries) { entry in
                        Button {
                            journalEntryForEdit = entry
                            showJournalEditor = true
                        } label: {
                            HStack(spacing: 8) {
                                if !entry.mood.isEmpty {
                                    Text(entry.mood).font(.subheadline)
                                }
                                Text(entry.dateKey)
                                    .font(.subheadline.weight(.semibold))
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
                            .padding(.vertical, 10)
                            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("inspector.journal.entry.\(entry.dateKey)")
                    }

                    Button {
                        journalEntryForEdit = nil
                        showJournalEditor = true
                    } label: {
                        HStack {
                            Spacer()
                            Label("新增至另一天的日記", systemImage: "plus")
                                .font(.caption.weight(.semibold))
                        }
                    }
                    .padding(.top, 2)
                    .accessibilityIdentifier("inspector.journal.addMore")
                }
            }
        }
    }
}
