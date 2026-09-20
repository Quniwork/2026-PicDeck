import SwiftUI
import Photos

/// 整理分頁裡的「標籤」與「資料夾及相簿」兩個子層用的清單。

// MARK: - 資料夾及相簿

/// 資料夾與相簿的清單，照階層顯示。動到的是系統照片裡的相簿與資料夾，照片不會被刪。
struct AlbumManagerList: View {
    @EnvironmentObject private var library: PhotoLibraryService

    @State private var tree: [AlbumNode] = []
    @State private var collapsed: Set<String> = []
    @State private var isLoading = true
    @State private var renaming: AlbumNode?
    @State private var renameText = ""
    @State private var deleting: AlbumNode?
    /// 點開的相簿，用來推到相簿內容畫面。
    @State private var openedAlbum: AlbumSummary?

    var body: some View {
        List {
            Section {
                AlbumCreateButton(assets: [], tree: tree, identifier: "album.create") {
                    Task { await reload() }
                }
            }

            Section {
                if isLoading {
                    ProgressView().frame(maxWidth: .infinity)
                } else if tree.isEmpty {
                    Text("No albums yet.")
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
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                Button {
                                    renaming = row.node
                                    renameText = row.node.title
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                    .onDelete { offsets in
                        let rows = tree.flattened(collapsed: collapsed)
                        guard let index = offsets.first, rows.indices.contains(index) else { return }
                        deleting = rows[index].node
                    }
                }
            } header: {
                HStack {
                    Text("Folders and albums")
                    Spacer()
                    if !tree.isEmpty {
                        EditButton()
                            .font(.footnote)
                            .textCase(nil)
                            .accessibilityIdentifier("album.edit")
                    }
                }
            } footer: {
                Text("Deleting an album keeps its photos in your library. A folder can only be deleted after everything inside it is removed.")
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .task { await reload() }
        .refreshable { await reload() }
        .navigationDestination(item: $openedAlbum) { album in
            AlbumDetailView(album: album)
        }
        .alert(String(localized: "Rename"),
               isPresented: Binding(get: { renaming != nil },
                                    set: { if !$0 { renaming = nil } })) {
            TextField(String(localized: "Name"), text: $renameText)
            Button("Cancel", role: .cancel) { renaming = nil }
            Button("Save") { rename() }
        }
        .alert(deleting?.isFolder == true ? String(localized: "Delete this folder?")
                                          : String(localized: "Delete this album?"),
               isPresented: Binding(get: { deleting != nil },
                                    set: { if !$0 { deleting = nil } })) {
            Button("Cancel", role: .cancel) { deleting = nil }
            Button("Delete", role: .destructive) { delete() }
        } message: {
            if deleting?.isFolder != true {
                Text("The photos stay in your library.")
            }
        }
    }

    @ViewBuilder
    private func rowView(_ node: AlbumNode, depth: Int) -> some View {
        HStack(spacing: 8) {
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
            // 資料夾點一下展開或收合；相簿點一下看裡面的照片（改名在左滑）。
            if node.isFolder {
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
                try? await library.renameFolder(id: node.id, to: name)
            } else {
                try? await library.renameAlbum(id: node.id, to: name)
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
        deleting = nil
        Task {
            if node.isFolder {
                try? await library.deleteFolder(id: node.id)
            } else {
                try? await library.deleteAlbum(id: node.id)
            }
            await reload()
        }
    }

    private func reload() async {
        tree = library.albumTree()
        isLoading = false
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
            }

            Section {
                if tagStore.tags.isEmpty {
                    Text("No tags yet.")
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
                            // 上下留白縮小，列不要太高。
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            tagStore.deleteTag(id: tagStore.tags[index].id)
                        }
                    }
                    .onMove { source, destination in
                        tagStore.moveTags(fromOffsets: source, toOffset: destination)
                    }
                }
            } header: {
                HStack {
                    Text("Tags")
                    Spacer()
                    if tagStore.tags.count > 1 {
                        EditButton()
                            .font(.footnote)
                            .textCase(nil)
                            .accessibilityIdentifier("manage.tag.edit")
                    }
                }
            } footer: {
                Text("Open a tag to change its icon or give it a start date. Tap Edit to drag them into the order you want.")
            }
        }
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
