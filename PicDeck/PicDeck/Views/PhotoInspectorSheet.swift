import SwiftUI
import Photos

/// 照片詳細資訊面板（方案 C）：
/// 在照片檢視中點擊 Header ⓘ 或向上輕滑呼叫，半螢幕呈現（支援 medium 與 large detents）。
/// 包含照片拍攝時間與尺寸規格、標籤管理、相簿管理、備註閱讀與編輯、當天日記預覽與捷徑。
struct PhotoInspectorSheet: View {
    let asset: PHAsset

    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var tagStore: TagStore
    @EnvironmentObject private var noteStore: NoteStore
    @EnvironmentObject private var journalStore: JournalStore
    @Environment(\.dismiss) private var dismiss

    @State private var albumTitles: [String] = []
    @State private var showTagPicker = false
    @State private var showAlbumPicker = false
    @State private var showNoteEditor = false
    @State private var showJournalEditor = false
    @State private var journalEntryForEdit: JournalEntry?

    private var tags: [PhotoTag] {
        tagStore.tags(for: asset)
    }

    private var noteText: String? {
        noteStore.note(for: asset)?.text
    }

    private var dateKey: String? {
        JournalStore.key(for: asset)
    }

    private var existingJournalEntry: JournalEntry? {
        journalStore.entry(for: asset) ?? {
            guard let key = dateKey else { return nil }
            return journalStore.entries(onDateKey: key).first
        }()
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - 規格與資訊
                Section {
                    HStack(alignment: .top, spacing: 14) {
                        AssetThumbnail(asset: asset, size: 140, showsDuration: false)
                            .frame(width: 72, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        VStack(alignment: .leading, spacing: 4) {
                            if let date = asset.creationDate {
                                Text(date, format: .dateTime.year().month().day().hour().minute().second())
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)

                                Text(date, format: .dateTime.weekday(.wide))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            HStack(spacing: 8) {
                                Text("\(asset.pixelWidth) × \(asset.pixelHeight)")
                                    .font(.caption2.monospacedDigit())
                                    .foregroundStyle(.secondary)

                                if asset.mediaType == .video {
                                    Label(durationString(asset.duration), systemImage: "video.fill")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text(asset.playbackStyle == .imageAnimated ? "GIF 動圖" : "照片")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.top, 2)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // MARK: - 標籤管理
                Section {
                    if tags.isEmpty {
                        HStack {
                            Text("尚未加入標籤")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button {
                                showTagPicker = true
                            } label: {
                                Label("加入標籤", systemImage: "plus")
                                    .font(.caption.weight(.semibold))
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .accessibilityIdentifier("inspector.addTag")
                        }
                        .padding(.vertical, 2)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(tags) { tag in
                                        HStack(spacing: 4) {
                                            if !tag.symbol.isEmpty {
                                                IconLabel(raw: tag.symbol, size: 12)
                                            } else {
                                                Image(systemName: "tag.fill").font(.system(size: 11))
                                            }
                                            Text(tag.name)
                                                .font(.caption.weight(.medium))
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.accentColor.opacity(0.12), in: Capsule())
                                        .foregroundStyle(Color.accentColor)
                                    }
                                }
                            }

                            Button {
                                showTagPicker = true
                            } label: {
                                Label("管理標籤", systemImage: "slider.horizontal.3")
                                    .font(.caption.weight(.medium))
                            }
                            .accessibilityIdentifier("inspector.manageTags")
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Label("標籤", systemImage: "tag")
                }

                // MARK: - 相簿管理
                Section {
                    if albumTitles.isEmpty {
                        HStack {
                            Text("未加入任何相簿")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button {
                                showAlbumPicker = true
                            } label: {
                                Label("加入相簿", systemImage: "plus")
                                    .font(.caption.weight(.semibold))
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .accessibilityIdentifier("inspector.addToAlbum")
                        }
                        .padding(.vertical, 2)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(albumTitles, id: \.self) { title in
                                        HStack(spacing: 4) {
                                            Image(systemName: "rectangle.stack.fill")
                                                .font(.system(size: 11))
                                            Text(title)
                                                .font(.caption.weight(.medium))
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.accentColor.opacity(0.12), in: Capsule())
                                        .foregroundStyle(Color.accentColor)
                                    }
                                }
                            }

                            Button {
                                showAlbumPicker = true
                            } label: {
                                Label("管理相簿", systemImage: "slider.horizontal.3")
                                    .font(.caption.weight(.medium))
                            }
                            .accessibilityIdentifier("inspector.manageAlbums")
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Label("相簿", systemImage: "rectangle.stack")
                }

                // MARK: - 備註
                Section {
                    if let text = noteText, !text.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(text)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .lineLimit(6)

                            Button {
                                showNoteEditor = true
                            } label: {
                                Label("編輯備註", systemImage: "pencil")
                                    .font(.caption.weight(.medium))
                            }
                            .padding(.top, 2)
                            .accessibilityIdentifier("inspector.editNote")
                        }
                        .padding(.vertical, 2)
                    } else {
                        Button {
                            showNoteEditor = true
                        } label: {
                            Label("新增備註…", systemImage: "note.text.badge.plus")
                                .font(.subheadline)
                        }
                        .accessibilityIdentifier("inspector.addNote")
                    }
                } header: {
                    Label("備註", systemImage: "note.text")
                }

                // MARK: - 日記
                Section {
                    if let entry = existingJournalEntry {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                if !entry.mood.isEmpty {
                                    Text(entry.mood).font(.title3)
                                }
                                Text(entry.dateKey)
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                            }

                            if !entry.text.isEmpty {
                                Text(entry.text)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(3)
                            }

                            Button {
                                journalEntryForEdit = entry
                                showJournalEditor = true
                            } label: {
                                Label("開啟日記", systemImage: "book.pages")
                                    .font(.caption.weight(.medium))
                            }
                            .padding(.top, 2)
                            .accessibilityIdentifier("inspector.openJournal")
                        }
                        .padding(.vertical, 2)
                    } else {
                        Button {
                            journalEntryForEdit = nil
                            showJournalEditor = true
                        } label: {
                            Label("撰寫這天的日記", systemImage: "square.and.pencil")
                                .font(.subheadline)
                        }
                        .accessibilityIdentifier("inspector.writeJournal")
                    }
                } header: {
                    Label("日記", systemImage: "book.closed")
                }
            }
            .navigationTitle("詳細資訊")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                        .accessibilityIdentifier("inspector.done")
                }
            }
            .task {
                reloadAlbums()
            }
            .sheet(isPresented: $showTagPicker) {
                TagPickerView(assets: [asset])
            }
            .sheet(isPresented: $showAlbumPicker, onDismiss: {
                reloadAlbums()
            }) {
                AlbumPickerView(assets: [asset])
            }
            .sheet(isPresented: $showNoteEditor) {
                NoteEditorView(asset: asset)
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func reloadAlbums() {
        albumTitles = library.albumTitles(for: asset)
    }

    private func durationString(_ duration: TimeInterval) -> String {
        let total = Int(duration.rounded())
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }
}
