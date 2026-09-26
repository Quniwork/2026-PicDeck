import SwiftUI

/// 選集的區塊：建立、命名、排序、隱藏、刪除。點鉛筆進到區塊裡設定標題、標籤與顯示方式。
struct HomeArrangeView: View {
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var tagStore: TagStore
    @Environment(\.dismiss) private var dismiss

    @State private var showAdd = false
    @State private var editingBlockID: UUID?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach($model.homeBlocks) { $block in
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(displayTitle(block)).font(.body)
                                Text(subtitle(block)).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button {
                                editingBlockID = block.id
                            } label: {
                                Image(systemName: "square.and.pencil")
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(.borderless)
                            .accessibilityLabel(Text("Edit"))
                            .accessibilityIdentifier("arrange.edit")

                            Button {
                                block.isHidden.toggle()
                            } label: {
                                Image(systemName: block.isHidden ? "eye.slash" : "eye")
                                    .foregroundStyle(block.isHidden ? Color.secondary : Color.accentColor)
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(.borderless)
                            .accessibilityLabel(Text(block.isHidden ? "Show" : "Hide"))
                        }
                        .deleteDisabled(block.mode == .onThisDay)
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("arrange.row")
                    }
                    .onMove { source, destination in
                        model.homeBlocks.move(fromOffsets: source, toOffset: destination)
                    }
                    .onDelete { offsets in remove(at: offsets) }
                } header: {
                    Text("Blocks")
                } footer: {
                    Text("Drag to change the order, tap the pencil to set the title, tags and how the block looks. Deleting a Days or Tags block unpins its tags; the tags themselves stay.")
                }
            }
            .environment(\.editMode, .constant(.active))
            .appCanvas()
            .navigationTitle("Arrange Collections")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $editingBlockID) { id in
                HomeBlockEditorView(blockID: id)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showAdd = true } label: { Label("New block", systemImage: "plus") }
                        .accessibilityIdentifier("arrange.new")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.accessibilityIdentifier("arrange.done")
                }
            }
            .sheet(isPresented: $showAdd) {
                AddHomeBlockView { newID in editingBlockID = newID }
            }
        }
    }

    private func displayTitle(_ block: HomeBlock) -> String {
        block.title.trimmingCharacters(in: .whitespaces).isEmpty ? HomeBlockNames.defaultTitle(for: block.mode) : block.title
    }

    private func subtitle(_ block: HomeBlock) -> String {
        let kind = HomeBlockNames.defaultTitle(for: block.mode)
        guard block.holdsTags else { return kind }
        let names = block.tagIDs.compactMap { tagStore.tag(withID: $0)?.name }.map { "#" + $0 }
        return names.isEmpty ? kind : kind + " · " + names.joined(separator: " ")
    }

    /// 刪除區塊。日子與標籤區塊裡的標籤，如果沒有出現在其他日子或標籤區塊，就一併取消釘選。
    private func remove(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            let block = model.homeBlocks[index]
            guard block.mode != .onThisDay else { continue }
            model.homeBlocks.remove(at: index)
            if block.mode == .days || block.mode == .tags {
                let stillPlaced = Set(model.homeBlocks.filter { $0.mode == .days || $0.mode == .tags }.flatMap(\.tagIDs))
                for id in block.tagIDs where !stillPlaced.contains(id) { tagStore.setPinnedOnHome(id, false) }
            }
        }
        model.reconcileHomeBlocks(tags: tagStore.tags)
    }
}

/// 建立區塊的第一步：選種類。建好之後直接進到區塊裡設定標題與標籤。
struct AddHomeBlockView: View {
    let onCreated: (UUID) -> Void

    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach([HomeBlock.Mode.days, .tags, .monthCalendar, .weekCalendar]) { mode in
                        Button { create(mode) } label: {
                            HStack(spacing: 14) {
                                Image(systemName: HomeBlockNames.icon(for: mode))
                                    .font(.title3)
                                    .frame(width: 30)
                                    .foregroundStyle(Color.accentColor)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(HomeBlockNames.defaultTitle(for: mode)).foregroundStyle(.primary)
                                    Text(HomeBlockNames.explanation(for: mode))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                        .accessibilityIdentifier("add.mode.\(mode.rawValue)")
                    }
                } header: {
                    Text("Choose a block type")
                }
            }
            .appCanvas()
            .navigationTitle("New block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.accessibilityIdentifier("add.cancel")
                }
            }
        }
    }

    private func create(_ mode: HomeBlock.Mode) {
        // 新區塊放在「那年今天」前面，還沒有標籤，接著到區塊裡加。
        let block = HomeBlock(mode: mode)
        let at = model.homeBlocks.firstIndex { $0.mode == .onThisDay } ?? model.homeBlocks.count
        model.homeBlocks.insert(block, at: at)
        onCreated(block.id)
        dismiss()
    }
}
