import SwiftUI
import Photos

/// 整理分頁裡的「標籤」與「資料夾及相簿」兩個子層用的清單。

// MARK: - 資料夾及相簿

/// 資料夾與相簿的清單，照階層顯示。動到的是系統照片裡的相簿與資料夾，照片不會被刪。
struct AlbumManagerList: View {
    @EnvironmentObject private var library: PhotoLibraryService
    @Environment(\.editMode) private var editMode

    @State private var tree: [AlbumNode] = []
    @State private var collapsed: Set<String> = []
    @State private var isLoading = true
    @State private var renaming: AlbumNode?
    @State private var renameText = ""
    @State private var deleting: AlbumNode?
    @State private var showCannotDeleteFolderAlert = false
    /// 點開的相簿，用來推到相簿內容畫面。
    @State private var openedAlbum: AlbumSummary?

    var body: some View {
        List {
            Section {
                AlbumCreateButton(assets: [], tree: tree, identifier: "album.create") {
                    Task { await reload() }
                }
                .pageRowInsets(vertical: 6)
            }

            Section {
                if isLoading {
                    ProgressView().frame(maxWidth: .infinity)
                } else if tree.isEmpty {
                    Text("尚未建立任何相簿")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(tree.flattened(collapsed: collapsed), id: \.node.id) { row in
                        rowView(row.node, depth: row.depth)
                            // 資料夾裡面還有東西就不能刪，要先把裡面的相簿或資料夾刪光。
                            .deleteDisabled(!canDelete(row.node))
                            .swipeActions(edge: .trailing) {
                                if canDelete(row.node) {
                                    Button(role: .destructive) {
                                        deleting = row.node
                                    } label: {
                                        Label("刪除", systemImage: "trash")
                                            .foregroundStyle(.red)
                                    }
                                } else if row.node.isFolder {
                                    Button {
                                        showCannotDeleteFolderAlert = true
                                    } label: {
                                        Label("刪除", systemImage: "info.circle")
                                    }
                                    .tint(.gray)
                                }
                                Button {
                                    renaming = row.node
                                    renameText = row.node.title
                                } label: {
                                    Label("重新命名", systemImage: "square.and.pencil")
                                }
                                .tint(.blue)
                            }
                            .pageRowInsets(vertical: 6)
                    }
                    .onDelete { offsets in
                        let rows = tree.flattened(collapsed: collapsed)
                        guard let index = offsets.first, rows.indices.contains(index) else { return }
                        let node = rows[index].node
                        if canDelete(node) {
                            deleting = node
                        } else if node.isFolder {
                            showCannotDeleteFolderAlert = true
                        }
                    }
                }
            } header: {
                HStack {
                    Text("資料夾與相簿")
                    Spacer()
                    if !tree.isEmpty {
                        EditButton()
                            .font(.footnote)
                            .textCase(nil)
                            .accessibilityIdentifier("album.edit")
                    }
                }
            } footer: {
                Text("刪除相簿時，其中的照片仍會完整保留在相片庫中。檔案夾需在內部項目清空後方可刪除。")
            }
        }
        .pageList()
        .scrollDismissesKeyboard(.immediately)
        .task { await reload() }
        .refreshable { await reload() }
        .navigationDestination(item: $openedAlbum) { album in
            AlbumDetailView(album: album)
        }
        .alert("重新命名",
               isPresented: Binding(get: { renaming != nil },
                                    set: { if !$0 { renaming = nil } })) {
            TextField("名稱", text: $renameText)
            Button("取消", role: .cancel) { renaming = nil }
            Button("儲存") { rename() }
        }
        .alert(deleting?.isFolder == true ? "刪除此檔案夾？" : "刪除此相簿？",
               isPresented: Binding(get: { deleting != nil },
                                    set: { if !$0 { deleting = nil } })) {
            Button("取消", role: .cancel) { deleting = nil }
            Button("刪除", role: .destructive) { delete() }
        } message: {
            if deleting?.isFolder != true {
                Text("相片仍會保留在相片庫中。")
            }
        }
        .alert("無法刪除資料夾", isPresented: $showCannotDeleteFolderAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text("要將裡面的相簿刪除內容為空的時候，才能刪除資料夾")
        }
    }

    @ViewBuilder
    private func rowView(_ node: AlbumNode, depth: Int) -> some View {
        HStack(spacing: 8) {
            if editMode?.wrappedValue.isEditing == true && node.isFolder && !canDelete(node) {
                Button {
                    showCannotDeleteFolderAlert = true
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color(.systemGray3))
                }
                .buttonStyle(.plain)
            }

            if node.isFolder {
                Image(systemName: collapsed.contains(node.id) ? "chevron.right" : "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 14)
                Image(systemName: "folder.fill").foregroundStyle(.tint)
            } else {
                Color.clear.frame(width: 14)
                Image(systemName: "rectangle.stack").foregroundStyle(.tint)
            }
            Text(node.title)
            Spacer()
            if !node.isFolder {
                Text("\(node.count)").foregroundStyle(.secondary)
            }
        }
        .padding(.leading, CGFloat(depth) * 20)
        .contentShape(Rectangle())
        .onTapGesture {
            if editMode?.wrappedValue.isEditing == true && node.isFolder && !canDelete(node) {
                showCannotDeleteFolderAlert = true
            } else if node.isFolder {
                if collapsed.contains(node.id) { collapsed.remove(node.id) } else { collapsed.insert(node.id) }
            } else {
                openedAlbum = AlbumSummary(id: node.id, title: node.title, count: node.count)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(node.isFolder ? "album.folder" : "album.row")
    }

    private func rename() {
        guard let node = renaming else { return }
        let name = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        renaming = nil
        guard !name.isEmpty, name != node.title else { return }
        Task {
            if node.isFolder {
                await library.attempt(String(localized: "Couldn't rename")) {
                    try await library.renameFolder(id: node.id, to: name)
                }
            } else {
                await library.attempt(String(localized: "Couldn't rename")) {
                    try await library.renameAlbum(id: node.id, to: name)
                }
            }
            await reload()
        }
    }

    /// 相簿隨時可以刪。資料夾要空的才能刪。
    private func canDelete(_ node: AlbumNode) -> Bool {
        !node.isFolder || node.children.isEmpty
    }

    private func delete() {
        guard let node = deleting, canDelete(node) else {
            deleting = nil
            return
        }
        let targetNode = node
        deleting = nil
        Task {
            if targetNode.isFolder {
                await library.attempt(String(localized: "Couldn't delete")) {
                    try await library.deleteFolder(id: targetNode.id)
                }
            } else {
                await library.attempt(String(localized: "Couldn't delete")) {
                    try await library.deleteAlbum(id: targetNode.id)
                }
            }
            await reload()
        }
    }

    private func reload() async {
        let newTree = library.albumTree()
        withAnimation(.easeInOut(duration: 0.25)) {
            tree = newTree
            isLoading = false
        }
    }
}

// MARK: - 標籤

/// 標籤清單。點一列進去可以改名、換圖示、設紀念日。
struct TagManagerList: View {
    @EnvironmentObject private var tagStore: TagStore

    @State private var editingTag: PhotoTag?
    @State private var newName = ""

    var body: some View {
        List {
            Section {
                CreateTagButton(assets: [], identifier: "manage.tag.create")
                    .pageRowInsets(vertical: 6)
            }

            Section {
                if tagStore.tags.isEmpty {
                    Text("尚未建立任何標籤")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(tagStore.tags) { tag in
                        row(for: tag)
                            .contentShape(Rectangle())
                            .onTapGesture { editingTag = tag }
                            .accessibilityElement(children: .combine)
                            .accessibilityAddTraits(.isButton)
                            .accessibilityIdentifier("manage.tag.row")
                            .pageRowInsets(vertical: 6)
                    }
                    .onDelete { offsets in
                        let ids = offsets.map { tagStore.tags[$0].id }
                        withAnimation(.easeInOut(duration: 0.25)) {
                            for id in ids {
                                tagStore.deleteTag(id: id)
                            }
                        }
                    }
                    .onMove { source, destination in
                        tagStore.moveTags(fromOffsets: source, toOffset: destination)
                    }
                }
            } header: {
                HStack {
                    Text("標籤列表")
                    Spacer()
                    if tagStore.tags.count > 1 {
                        EditButton()
                            .font(.footnote)
                            .textCase(nil)
                            .accessibilityIdentifier("manage.tag.edit")
                    }
                }
            } footer: {
                Text("點擊標籤可更換圖示或設定紀念日起算日。點擊「編輯」可拖曳調整排列順序。")
            }
        }
        .pageList()
        .scrollDismissesKeyboard(.immediately)
        .sheet(item: $editingTag) { tag in
            TagFormView(mode: .edit(tag))
        }
    }

    private func row(for tag: PhotoTag) -> some View {
        HStack(spacing: 10) {
            IconLabel(raw: tag.symbol, size: 18)
            VStack(alignment: .leading, spacing: 0) {
                Text(tag.name)
                if let text = tag.anniversaryText(on: Date()) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar").font(.caption2)
                        Text(text)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text("\(tagStore.usageCount(of: tag.id))")
                .foregroundStyle(.secondary)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        // 有日子的列多一行小字，沒有的只有一行。固定最低高度，每一列一樣高。
        .frame(minHeight: 36)
        // 分隔線的起點系統會照第一個圖示的寬度自己算，表情與圖標寬度不同就會長短不一。
        // 固定從列的最左邊開始。
        .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
    }
}
