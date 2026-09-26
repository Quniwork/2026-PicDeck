import SwiftUI
import Photos

/// 把照片加到相簿。做法跟加標籤一樣：最上面是「建立」，下面是相簿清單，
/// 照片已經在裡面的打勾，點一下加入，再點一下移出。
/// 相簿放在資料夾裡的會照階層顯示，資料夾可以展開與收合。
struct AlbumPickerView: View {
    /// 要處理的照片，一張或多張。
    let assets: [PHAsset]

    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var organized: OrganizedStore
    @Environment(\.dismiss) private var dismiss

    @State private var tree: [AlbumNode] = []
    @State private var memberIDs: Set<String> = []
    @State private var collapsed: Set<String> = []
    @State private var isLoading = true

    /// 攤平後要畫的列，每一列帶縮排層級。收起來的資料夾底下就不列。
    private var rows: [(node: AlbumNode, depth: Int)] {
        tree.flattened(collapsed: collapsed)
    }

    /// 用過的相簿（不含資料夾），最近的在前，最多三個。
    private var recentAlbums: [AlbumNode] {
        let used = (UserDefaults.standard.dictionary(forKey: "picdeck.albumLastUsed") as? [String: Date]) ?? [:]
        func flat(_ nodes: [AlbumNode]) -> [AlbumNode] { nodes.flatMap { $0.isFolder ? flat($0.children) : [$0] } }
        return flat(tree).filter { used[$0.id] != nil }.sorted { (used[$0.id] ?? .distantPast) > (used[$1.id] ?? .distantPast) }.prefix(3).map { $0 }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    AlbumCreateButton(assets: assets, tree: tree) {
                        Task { await reload() }
                    }
                    .pageRowInsets(vertical: 6)
                }

                // 最近用過的相簿放最上面，不用在階層裡找。
                if !recentAlbums.isEmpty {
                    Section(String(localized: "Recently used")) {
                        ForEach(recentAlbums, id: \.id) { node in
                            rowView(node, depth: 0)
                                .pageRowInsets(vertical: 6)
                        }
                    }
                }

                Section {
                    if isLoading {
                        ProgressView().frame(maxWidth: .infinity)
                    } else if tree.isEmpty {
                        Text("No albums yet.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .pageRowInsets(vertical: 6)
                    } else {
                        ForEach(rows, id: \.node.id) { row in
                            rowView(row.node, depth: row.depth)
                                .pageRowInsets(vertical: 6)
                        }
                    }
                } header: {
                    Text(assets.count == 1 ? String(localized: "Albums")
                                           : String(localized: "Apply to \(assets.count) photos"))
                }
            }
            .pageList()
            .navigationTitle("Add to album")
            .failureToast()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("albumpicker.done")
                }
            }
            .task { await reload() }
        }
    }

    @ViewBuilder
    private func rowView(_ node: AlbumNode, depth: Int) -> some View {
        if node.isFolder {
            Button {
                if collapsed.contains(node.id) { collapsed.remove(node.id) } else { collapsed.insert(node.id) }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: collapsed.contains(node.id) ? "chevron.right" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 14)
                    Image(systemName: "folder.fill").foregroundStyle(.tint)
                    Text(node.title).foregroundStyle(.primary)
                    Spacer()
                }
                .padding(.leading, CGFloat(depth) * 20)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .pageRowInsets(vertical: 6)
            .accessibilityLabel(Text(node.title))
            .accessibilityIdentifier("albumpicker.folder")
        } else {
            Button {
                toggle(node)
            } label: {
                HStack(spacing: 8) {
                    Color.clear.frame(width: 14)
                    Image(systemName: "rectangle.stack").foregroundStyle(.tint)
                    Text(node.title).foregroundStyle(.primary)
                    Spacer()
                    Text("\(node.count)").foregroundStyle(.secondary)
                    if memberIDs.contains(node.id) {
                        Image(systemName: "checkmark").foregroundStyle(.tint)
                    }
                }
                .padding(.leading, CGFloat(depth) * 20)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .pageRowInsets(vertical: 6)
            .accessibilityLabel(Text(node.title))
            .accessibilityValue(memberIDs.contains(node.id) ? "checked" : "")
            .accessibilityIdentifier("albumpicker.row")
        }
    }

    private func reload() async {
        tree = library.albumTree()
        memberIDs = library.albumIDs(containingAll: assets)
        isLoading = false
    }

    /// 多張時，只有全部都在裡面才算已加入，跟標籤一樣。
    private func toggle(_ album: AlbumNode) {
        let isMember = memberIDs.contains(album.id)
        // 先更新畫面，勾選才會立刻跟手。
        if isMember { memberIDs.remove(album.id) } else { memberIDs.insert(album.id) }

        Task {
            if isMember {
                await library.attempt(String(localized: "Couldn't update the album")) {
                    try await library.removeAssets(assets, fromAlbumWithID: album.id)
                }
            } else {
                for asset in assets {
                    organized.markOrganized(asset)
                }
                await library.attempt(String(localized: "Couldn't add to the album")) {
                    try await library.addAssets(assets, toAlbumWithID: album.id)
                }
            }
            await reload()
        }
    }
}

/// 開啟建立表單的按鈕。
struct AlbumCreateButton: View {
    /// 建好相簿之後要順便加進去的照片。可以是空的。
    var assets: [PHAsset] = []
    let tree: [AlbumNode]
    var identifier: String = "album.create"
    let onCreated: () -> Void

    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label("Create album or folder", systemImage: "plus.circle.fill")
        }
        .accessibilityIdentifier(identifier)
        .sheet(isPresented: $isPresented) {
            AlbumCreateForm(assets: assets, tree: tree, onCreated: onCreated)
        }
    }
}

/// 建立相簿或資料夾。位置可以選最上層，或任何一個資料夾底下。
struct AlbumCreateForm: View {
    let assets: [PHAsset]
    let tree: [AlbumNode]
    let onCreated: () -> Void

    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var organized: OrganizedStore
    @Environment(\.dismiss) private var dismiss

    private enum Kind: String, CaseIterable, Identifiable {
        case album, folder
        var id: String { rawValue }
    }

    @State private var kind: Kind = .album
    @State private var name = ""
    /// nil 代表最上層。
    @State private var parentID: String?
    @State private var isWorking = false

    /// 可以當作位置的資料夾，攤平並帶縮排，深的資料夾名字前面補空白。
    private var folders: [(id: String, title: String)] {
        var output: [(String, String)] = []
        func walk(_ nodes: [AlbumNode], depth: Int) {
            for node in nodes where node.isFolder {
                output.append((node.id, String(repeating: "　", count: depth) + node.title))
                walk(node.children, depth: depth + 1)
            }
        }
        walk(tree, depth: 0)
        return output
    }

    private var trimmed: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 同一個位置底下不能有同名的相簿或資料夾。
    private var siblings: [AlbumNode] {
        guard let parentID else { return tree }
        func find(_ nodes: [AlbumNode]) -> AlbumNode? {
            for node in nodes {
                if node.id == parentID { return node }
                if let hit = find(node.children) { return hit }
            }
            return nil
        }
        return find(tree)?.children ?? []
    }

    private var isDuplicate: Bool {
        !trimmed.isEmpty && siblings.contains { $0.title.caseInsensitiveCompare(trimmed) == .orderedSame }
    }

    private var canCreate: Bool { !trimmed.isEmpty && !isDuplicate && !isWorking }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("", selection: $kind) {
                        Text("Album").tag(Kind.album)
                        Text("Folder").tag(Kind.folder)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("albumform.kind")
                }

                Section {
                    TextField(kind == .album ? String(localized: "Album name")
                                             : String(localized: "Folder name"),
                              text: $name)
                        .accessibilityIdentifier("albumform.name")
                } footer: {
                    if isDuplicate {
                        Text("A name like this already exists here.")
                            .foregroundStyle(.red)
                            .accessibilityIdentifier("albumform.duplicate")
                    }
                }

                Section {
                    Picker("Location", selection: $parentID) {
                        Text("Top level").tag(String?.none)
                        ForEach(folders, id: \.id) { folder in
                            Text(folder.title).tag(Optional(folder.id))
                        }
                    }
                    .accessibilityIdentifier("albumform.location")
                } footer: {
                    Text("Albums and folders are created in your Photos library.")
                }
            }
            .appCanvas()
            .navigationTitle(kind == .album ? "New album" : "New folder")
            .failureToast()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { create() }
                        .disabled(!canCreate)
                        .accessibilityIdentifier("albumform.save")
                }
            }
        }
    }

    private func create() {
        guard canCreate else { return }
        isWorking = true
        let title = trimmed
        let kind = kind
        let parent = parentID

        Task {
            switch kind {
            case .album:
                var newID: String?
                let created = await library.attempt(String(localized: "Couldn't create the album")) {
                    newID = try await library.createAlbum(named: title, inFolderID: parent)
                }
                if created, let id = newID, !assets.isEmpty {
                    for asset in assets {
                        organized.markOrganized(asset)
                    }
                    await library.attempt(String(localized: "Couldn't add to the album")) {
                        try await library.addAssets(assets, toAlbumWithID: id)
                    }
                }
            case .folder:
                await library.attempt(String(localized: "Couldn't create the folder")) {
                    _ = try await library.createFolder(named: title, inFolderID: parent)
                }
            }
            onCreated()
            dismiss()
        }
    }
}


extension Array where Element == AlbumNode {
    /// 把階層攤平成一列一列，每列帶縮排層級。收起來的資料夾底下就不列。
    func flattened(collapsed: Set<String>) -> [(node: AlbumNode, depth: Int)] {
        var output: [(AlbumNode, Int)] = []
        func walk(_ nodes: [AlbumNode], depth: Int) {
            for node in nodes {
                output.append((node, depth))
                if node.isFolder, !collapsed.contains(node.id) {
                    walk(node.children, depth: depth + 1)
                }
            }
        }
        walk(self, depth: 0)
        return output
    }
}
