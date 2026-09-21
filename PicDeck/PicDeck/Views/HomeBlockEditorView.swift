import SwiftUI

/// 一個區塊的設定：標題、放哪些標籤、顯示方式。
struct HomeBlockEditorView: View {
    let blockID: UUID

    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var tagStore: TagStore
    @Environment(\.dismiss) private var dismiss

    @State private var showPicker = false
    @State private var confirmDelete = false

    private var index: Int? { model.homeBlocks.firstIndex { $0.id == blockID } }

    var body: some View {
        if let index {
            let block = model.homeBlocks[index]
            Form {
                Section {
                    TextField(HomeBlockNames.defaultTitle(for: block.mode),
                              text: $model.homeBlocks[index].title)
                        .accessibilityIdentifier("block.title")
                } header: {
                    Text("Title")
                } footer: {
                    Text("Leave it empty to use the default name.")
                }

                if block.holdsTags {
                    Section {
                        ForEach(block.tagIDs, id: \.self) { id in
                            if let tag = tagStore.tag(withID: id) {
                                HStack(spacing: 10) {
                                    IconLabel(raw: tag.symbol, size: 18)
                                    Text(tag.name)
                                    Spacer()
                                    if block.mode == .days, let text = tag.anniversaryText(on: Date()) {
                                        Text(text).font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .onDelete { offsets in removeTags(at: offsets, from: index) }
                        .onMove { source, destination in
                            model.homeBlocks[index].tagIDs.move(fromOffsets: source, toOffset: destination)
                        }

                        Button {
                            showPicker = true
                        } label: {
                            Label(addTitle(block.mode), systemImage: "plus.circle.fill")
                        }
                        .accessibilityIdentifier("block.addTag")
                    } header: {
                        Text("Tags")
                    } footer: {
                        Text(HomeBlockNames.explanation(for: block.mode))
                    }
                }

                if block.mode == .tags {
                    Section {
                        Picker("Show as", selection: $model.homeBlocks[index].layout) {
                            Text("Cards").tag(HomeBlock.TagsLayout.cards)
                            Text("List").tag(HomeBlock.TagsLayout.list)
                        }
                        .pickerStyle(.segmented)
                        .accessibilityIdentifier("block.layout")
                    } header: {
                        Text("Show as")
                    }
                }

                // 卡片的排法：先選橫向捲動或自動換行，再選大小。列表沒有這兩項。
                if block.mode == .days || (block.mode == .tags && block.layout == .cards) {
                    Section {
                        Picker("Arrangement", selection: $model.homeBlocks[index].wraps) {
                            Text("Scroll sideways").tag(false)
                            Text("Wrap").tag(true)
                        }
                        .pickerStyle(.segmented)
                        .accessibilityIdentifier("block.wrap")
                    } header: {
                        Text("Arrangement")
                    } footer: {
                        Text(block.wraps
                             ? "Cards go down in rows."
                             : "Cards slide sideways; the last card is cut off a little to show there is more.")
                    }

                    Section {
                        Picker("Card size", selection: $model.homeBlocks[index].size) {
                            Text("Small").tag(CardSize.small)
                            Text("Medium").tag(CardSize.medium)
                            Text("Large").tag(CardSize.large)
                        }
                        .pickerStyle(.segmented)
                        .accessibilityIdentifier("block.size")
                    } header: {
                        Text("Card size")
                    } footer: {
                        Text(block.wraps
                             ? "Small: 2 columns, half as tall as wide. Medium: 2 columns, square. Large: 1 column, half as tall as wide."
                             : "Small and medium show two cards and a bit of the next one, large shows one card and a bit of the next.")
                    }
                }

                if block.mode != .onThisDay {
                    Section {
                        DestructiveRowButton(title: String(localized: "Delete block"), identifier: "block.delete") {
                            confirmDelete = true
                        }
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle(block.title.isEmpty ? HomeBlockNames.defaultTitle(for: block.mode) : block.title)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPicker) {
                BlockTagPickerView(blockID: blockID)
            }
            .alert(String(localized: "Delete this block?"), isPresented: $confirmDelete) {
                Button("Delete", role: .destructive) { deleteBlock(index) }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("The tags themselves are kept.")
            }
        } else {
            Text("This block no longer exists.").foregroundStyle(.secondary)
        }
    }

    private func addTitle(_ mode: HomeBlock.Mode) -> String {
        mode == .days ? String(localized: "Add a tag with a date") : String(localized: "Add a tag")
    }

    /// 從區塊拿掉標籤。日子與標籤區塊的標籤如果沒出現在其他日子或標籤區塊，就取消釘選。
    private func removeTags(at offsets: IndexSet, from index: Int) {
        let removed = offsets.map { model.homeBlocks[index].tagIDs[$0] }
        model.homeBlocks[index].tagIDs.remove(atOffsets: offsets)
        unpinOrphans(removed)
    }

    private func unpinOrphans(_ ids: [UUID]) {
        let mode = model.homeBlocks.first { $0.id == blockID }?.mode
        guard mode == .days || mode == .tags else { return }
        let stillPlaced = Set(model.homeBlocks.filter { $0.mode == .days || $0.mode == .tags }.flatMap(\.tagIDs))
        for id in ids where !stillPlaced.contains(id) { tagStore.setPinnedOnHome(id, false) }
    }

    private func deleteBlock(_ index: Int) {
        let block = model.homeBlocks[index]
        model.homeBlocks.remove(at: index)
        if block.mode == .days || block.mode == .tags {
            let stillPlaced = Set(model.homeBlocks.filter { $0.mode == .days || $0.mode == .tags }.flatMap(\.tagIDs))
            for id in block.tagIDs where !stillPlaced.contains(id) { tagStore.setPinnedOnHome(id, false) }
        }
        model.reconcileHomeBlocks(tags: tagStore.tags)
        dismiss()
    }
}

/// 替區塊選標籤。日子區塊選有日期的標籤（沒日期的可以補日期），標籤、月曆、週曆區塊可以選所有標籤（包含有日期的）。
/// 也可以直接新增一個標籤。
struct BlockTagPickerView: View {
    let blockID: UUID

    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var tagStore: TagStore
    @Environment(\.dismiss) private var dismiss

    private enum FormSheet: Identifiable {
        case create
        case setDate(PhotoTag)
        var id: String {
            switch self {
            case .create: return "create"
            case .setDate(let tag): return "date-\(tag.id)"
            }
        }
    }

    @State private var form: FormSheet?
    @State private var idsBeforeForm: Set<UUID> = []

    private var block: HomeBlock? { model.homeBlocks.first { $0.id == blockID } }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(eligibleTags) { tag in
                        Button { choose(tag) } label: {
                            HStack(spacing: 10) {
                                IconLabel(raw: tag.symbol, size: 20)
                                Text(tag.name).foregroundStyle(.primary)
                                Spacer()
                                if block?.mode == .days, !tag.hasAnniversary {
                                    Text("Needs a date").font(.caption).foregroundStyle(.secondary)
                                } else if tag.hasAnniversary {
                                    Image(systemName: "calendar").font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                        .accessibilityIdentifier("add.tag")
                    }
                    Button {
                        idsBeforeForm = Set(tagStore.tags.map(\.id))
                        form = .create
                    } label: {
                        Label(block?.mode == .days ? String(localized: "New tag with a date") : String(localized: "New tag"),
                              systemImage: "plus.circle")
                    }
                    .accessibilityIdentifier("add.newTag")
                } header: {
                    Text("Choose a tag")
                }
            }
            .navigationTitle("Add a tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.accessibilityIdentifier("picker.cancel")
                }
            }
            .sheet(item: $form, onDismiss: afterForm) { which in
                let pinned = block?.mode == .days || block?.mode == .tags
                switch which {
                case .create:
                    TagFormView(mode: .create(assets: []), startsPinned: pinned, startsWithDays: block?.mode == .days)
                case .setDate(let tag):
                    TagFormView(mode: .edit(tag), startsPinned: true, startsWithDays: true)
                }
            }
        }
    }

    /// 已經在這個區塊裡的不再列出。日子區塊可以選所有標籤（沒日期的點了會請他補日期）。
    private var eligibleTags: [PhotoTag] {
        let inBlock = Set(block?.tagIDs ?? [])
        return tagStore.tags.filter { !inBlock.contains($0.id) }
    }

    private func choose(_ tag: PhotoTag) {
        if block?.mode == .days, !tag.hasAnniversary {
            // 還沒設日期：打開標籤表單，日子已經打開，設好日期儲存之後加進區塊。
            idsBeforeForm = Set(tagStore.tags.map(\.id))
            pendingTagID = tag.id
            form = .setDate(tag)
        } else {
            add(tag.id)
            dismiss()
        }
    }

    @State private var pendingTagID: UUID?

    private func add(_ id: UUID) {
        guard let index = model.homeBlocks.firstIndex(where: { $0.id == blockID }),
              !model.homeBlocks[index].tagIDs.contains(id) else { return }
        let mode = model.homeBlocks[index].mode
        if mode == .days || mode == .tags { tagStore.setPinnedOnHome(id, true) }
        model.homeBlocks[index].tagIDs.append(id)
    }

    /// 表單關掉之後：新建的標籤，或補了日期的標籤，加進區塊並回到區塊設定。
    private func afterForm() {
        let newIDs = tagStore.tags.map(\.id).filter { !idsBeforeForm.contains($0) }
        for id in newIDs { add(id) }
        if let pendingTagID, let tag = tagStore.tag(withID: pendingTagID), tag.hasAnniversary {
            add(pendingTagID)
        }
        let added = !newIDs.isEmpty || (pendingTagID.flatMap { tagStore.tag(withID: $0)?.hasAnniversary } ?? false)
        pendingTagID = nil
        if added { dismiss() }
    }
}
