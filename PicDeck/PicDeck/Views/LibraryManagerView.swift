import SwiftUI
import Photos

/// 整理的地方：相簿與標籤都在這裡建立、改名、刪除。
/// 標籤的紀念日設定也從這裡進去。
struct LibraryManagerView: View {
    /// 打開時停在哪一頁。
    var initialTab: Tab = .albums

    enum Tab: String, CaseIterable, Identifiable {
        case albums, tags
        var id: String { rawValue }
        var title: String {
            switch self {
            case .albums: return String(localized: "Albums")
            case .tags: return String(localized: "Tags")
            }
        }
    }

    @State private var tab: Tab = .albums

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $tab) {
                ForEach(Tab.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .accessibilityIdentifier("manage.tab")

            switch tab {
            case .albums: AlbumManagerList()
            case .tags: TagManagerList()
            }
        }
        .navigationTitle("Manage")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { tab = initialTab }
    }
}

// MARK: - 相簿

/// 相簿清單。改名與刪除動到的是系統相簿本身，照片不會被刪。
struct AlbumManagerList: View {
    @EnvironmentObject private var library: PhotoLibraryService

    @State private var albums: [AlbumSummary] = []
    @State private var isLoading = false
    @State private var newName = ""
    @State private var renaming: AlbumSummary?
    @State private var renameText = ""
    @State private var deleting: AlbumSummary?

    var body: some View {
        List {
            Section {
                HStack(spacing: 10) {
                    Image(systemName: "folder.badge.plus")
                        .foregroundStyle(.secondary)
                    TextField(String(localized: "New album name"), text: $newName)
                        .accessibilityIdentifier("album.name")
                    Button(String(localized: "Add")) { create() }
                        .buttonStyle(.bordered)
                        .disabled(!canCreate)
                        .accessibilityIdentifier("album.add")
                }
            } footer: {
                if isDuplicate {
                    Text("An album with this name already exists.")
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("album.duplicate")
                }
            }

            Section {
                if isLoading {
                    ProgressView().frame(maxWidth: .infinity)
                } else if albums.isEmpty {
                    Text("No albums yet.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(albums) { album in
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundStyle(.tint)
                            Text(album.title)
                            Spacer()
                            Text("\(album.count)").foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            renaming = album
                            renameText = album.title
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityIdentifier("album.row")
                    }
                    .onDelete { offsets in
                        guard let index = offsets.first else { return }
                        deleting = albums[index]
                    }
                }
            } header: {
                Text("Albums")
            } footer: {
                Text("Deleting an album keeps its photos in your library.")
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .task { await reload() }
        .refreshable { await reload() }
        .alert(String(localized: "Rename album"),
               isPresented: Binding(get: { renaming != nil },
                                    set: { if !$0 { renaming = nil } })) {
            TextField(String(localized: "Album name"), text: $renameText)
            Button("Cancel", role: .cancel) { renaming = nil }
            Button("Save") { rename() }
        }
        .alert(String(localized: "Delete this album?"),
               isPresented: Binding(get: { deleting != nil },
                                    set: { if !$0 { deleting = nil } })) {
            Button("Cancel", role: .cancel) { deleting = nil }
            Button("Delete", role: .destructive) { delete() }
        } message: {
            Text("The photos stay in your library.")
        }
    }

    private var trimmed: String {
        newName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isDuplicate: Bool {
        !trimmed.isEmpty && albums.contains { $0.title.caseInsensitiveCompare(trimmed) == .orderedSame }
    }

    private var canCreate: Bool { !trimmed.isEmpty && !isDuplicate }

    private func create() {
        guard canCreate else { return }
        let name = trimmed
        newName = ""
        Task {
            _ = try? await library.createAlbum(named: name)
            await reload()
        }
    }

    private func rename() {
        guard let album = renaming else { return }
        let name = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        renaming = nil
        guard !name.isEmpty, name != album.title else { return }
        Task {
            try? await library.renameAlbum(id: album.id, to: name)
            await reload()
        }
    }

    private func delete() {
        guard let album = deleting else { return }
        deleting = nil
        Task {
            try? await library.deleteAlbum(id: album.id)
            await reload()
        }
    }

    private func reload() async {
        isLoading = albums.isEmpty
        defer { isLoading = false }
        albums = await library.userAlbums()
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
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            tagStore.deleteTag(id: tagStore.tags[index].id)
                        }
                    }
                }
            } header: {
                Text("Tags")
            } footer: {
                Text("Open a tag to change its icon or give it a start date, such as a child's birthday.")
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
            VStack(alignment: .leading, spacing: 2) {
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
    }
}
