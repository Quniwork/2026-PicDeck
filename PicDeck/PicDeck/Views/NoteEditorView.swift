import SwiftUI
import Photos

/// 幫一張照片寫備註與標籤。像收藏：截圖了一間想去的餐廳，標 #美食 #燒肉，備註寫店名、地點、營業時間。
struct NoteEditorView: View {
    let asset: PHAsset

    @EnvironmentObject private var noteStore: NoteStore
    @EnvironmentObject private var tagStore: TagStore
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @State private var showTagPicker = false
    @FocusState private var isEditing: Bool

    private var existing: PhotoNote? { noteStore.note(for: asset) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(alignment: .top, spacing: 12) {
                        AssetThumbnail(asset: asset, size: 120, showsDuration: false)
                            .frame(width: 96, height: 96)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        VStack(alignment: .leading, spacing: 8) {
                            if let date = asset.creationDate {
                                Text(date, format: .dateTime.year().month().day().weekday())
                                    .font(.subheadline.weight(.semibold))
                            }
                            TagChipsRow(tags: tagStore.tags(for: asset))
                            // 跟標籤小膠囊同一種樣式，只是有個 +，像在旁邊多加一顆。
                            Button {
                                showTagPicker = true
                            } label: {
                                HStack(spacing: 3) {
                                    Image(systemName: "plus").font(.system(size: 10, weight: .bold))
                                    Text("Tags")
                                }
                                .font(.caption2.weight(.medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .foregroundStyle(Color.accentColor)
                                .background(Color.accentColor.opacity(0.12), in: Capsule())
                                .contentShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("note.tags")
                        }
                    }
                    .padding(.vertical, 2)
                }

                Section {
                    TextField(String(localized: "Restaurant, place, opening hours, how it was…"),
                              text: $text, axis: .vertical)
                        .lineLimit(5...14)
                        .focused($isEditing)
                        .accessibilityIdentifier("note.text")
                } header: {
                    Text("Note")
                }

                if existing != nil {
                    Section {
                        DestructiveRowButton(title: String(localized: "Delete note"),
                                             identifier: "note.delete") {
                            if let existing { noteStore.delete(noteID: existing.id) }
                            dismiss()
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    // 標籤一加就存了，所以只加標籤、不寫備註也要能按完成離開。
                    // 沒寫備註且原本也沒有，就不建立備註。
                    Button("Done") {
                        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty || existing != nil {
                            noteStore.save(text: text, isDone: existing?.isDone ?? false, for: asset)
                        }
                        dismiss()
                    }
                    .accessibilityIdentifier("note.save")
                }
            }
            .sheet(isPresented: $showTagPicker) {
                TagPickerView(assets: [asset])
            }
            .onAppear {
                if let existing {
                    text = existing.text
                } else {
                    isEditing = true
                }
            }
        }
    }
}

/// 一排標籤小膠囊。放不下就截斷，不換行。
struct TagChipsRow: View {
    let tags: [PhotoTag]

    var body: some View {
        if !tags.isEmpty {
            HStack(spacing: 5) {
                ForEach(tags.prefix(3)) { tag in
                    HStack(spacing: 3) {
                        IconLabel(raw: tag.symbol, size: 10)
                        Text(tag.name).lineLimit(1)
                    }
                    .font(.caption2)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color(.secondarySystemFill), in: Capsule())
                }
                if tags.count > 3 {
                    Text("+\(tags.count - 3)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

/// 多選之後一次寫備註：同一段文字加到每一張照片。已經有備註的照片不覆蓋，接在原本備註後面另起一行。
struct BatchNoteView: View {
    let assets: [PHAsset]
    var onDone: () -> Void = {}

    @EnvironmentObject private var noteStore: NoteStore
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @FocusState private var isEditing: Bool

    private var existingCount: Int { assets.filter { noteStore.note(for: $0) != nil }.count }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "Restaurant, place, opening hours, how it was…"),
                              text: $text, axis: .vertical)
                        .lineLimit(5...14)
                        .focused($isEditing)
                        .accessibilityIdentifier("batchnote.text")
                } header: {
                    Text("Note")
                } footer: {
                    if existingCount > 0 {
                        Text("Photos that already have a note keep it; this text is added on a new line.")
                    }
                }
            }
            .navigationTitle(String(format: String(localized: "Note for %lld photos"), assets.count))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .accessibilityIdentifier("batchnote.save")
                }
            }
            .onAppear { isEditing = true }
        }
    }

    private func save() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        for asset in assets {
            if let old = noteStore.note(for: asset) {
                noteStore.save(text: old.text + "\n" + trimmed, isDone: old.isDone, for: asset)
            } else {
                noteStore.save(text: trimmed, isDone: false, for: asset)
            }
        }
        dismiss()
        onDone()
    }
}
