import SwiftUI
import Photos

/// 寫日記：選心情、寫文字，並挑選當天要附上的照片。
/// 以「日」為單位，同一天共用一篇。
struct JournalEditorView: View {
    let year: Int
    let month: Int
    let day: Int
    /// 從長按或多選進來時，預設先選好這些照片。
    var preselectedIDs: [String] = []

    @EnvironmentObject private var journalStore: JournalStore
    @EnvironmentObject private var library: PhotoLibraryService
    @Environment(\.dismiss) private var dismiss

    @State private var mood = ""
    @State private var text = ""
    @State private var selectedIDs: [String] = []
    @State private var dayAssets: [PHAsset] = []
    @State private var isLoading = true

    private let photoColumns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 4)

    private var dateKey: String { JournalStore.key(year: year, month: month, day: day) }
    private var dateTitle: String { DateTitle.day(year: year, month: month, day: day) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        IconPickerButton(raw: $mood,
                                         size: 44,
                                         removedValue: "",
                                         identifier: "journal.mood")
                        Text(mood.isEmpty ? "Tap to pick a mood" : "Tap to change")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.vertical, 2)
                } header: {
                    Text("Mood")
                }

                Section(String(localized: "Journal")) {
                    TextField(String(localized: "What happened today?"),
                              text: $text, axis: .vertical)
                        .lineLimit(4...10)
                        .accessibilityIdentifier("journal.text")
                }

                Section {
                    if isLoading {
                        ProgressView().frame(maxWidth: .infinity)
                    } else if dayAssets.isEmpty {
                        Text("No photos on this day.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        LazyVGrid(columns: photoColumns, spacing: 4) {
                            ForEach(dayAssets, id: \.localIdentifier) { asset in
                                selectableThumbnail(asset)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Photos  (\(selectedIDs.count))")
                } footer: {
                    Text("Pick the photos to show with this entry.")
                }

                if journalStore.entry(forKey: dateKey) != nil {
                    Section {
                        Button(String(localized: "Delete entry"), role: .destructive) {
                            journalStore.delete(forKey: dateKey)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(dateTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        journalStore.save(mood: mood, text: text,
                                          photoIDs: selectedIDs, forKey: dateKey)
                        dismiss()
                    }
                    .accessibilityIdentifier("journal.save")
                }
            }
            .task { await load() }
        }
        .accessibilityIdentifier("journal.editor")
    }

    private func selectableThumbnail(_ asset: PHAsset) -> some View {
        let isSelected = selectedIDs.contains(asset.localIdentifier)
        return AssetThumbnail(asset: asset, size: 90, showsDuration: false)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.accentColor, lineWidth: 3)
                }
            }
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color.accentColor)
                        .padding(3)
                }
            }
            .onTapGesture { toggle(asset) }
    }

    private func toggle(_ asset: PHAsset) {
        let id = asset.localIdentifier
        if let index = selectedIDs.firstIndex(of: id) {
            selectedIDs.remove(at: index)
        } else {
            selectedIDs.append(id)
        }
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }

        if let existing = journalStore.entry(forKey: dateKey) {
            mood = existing.mood
            text = existing.text
            selectedIDs = existing.photoIDs
        }
        // 帶進來的照片一律補上，且不重複。
        for id in preselectedIDs where !selectedIDs.contains(id) {
            selectedIDs.append(id)
        }
        dayAssets = await library.assets(onYear: year, month: month, day: day)
    }
}

/// 長按照片跳出的操作，與整理的審核畫面一致。
struct PhotoActionsMenu: View {
    let asset: PHAsset
    let albums: [AlbumSummary]
    let onJournal: (PHAsset) -> Void
    let onTag: (PHAsset) -> Void
    let onFavorite: (PHAsset) -> Void
    let onAddToAlbum: (PHAsset, AlbumSummary) -> Void

    var body: some View {
        Button {
            onJournal(asset)
        } label: {
            Label("Write journal", systemImage: "square.and.pencil")
        }

        Button {
            onTag(asset)
        } label: {
            Label("Tags", systemImage: "tag")
        }

        Button {
            onFavorite(asset)
        } label: {
            Label(asset.isFavorite ? "Remove from favorites" : "Favorite",
                  systemImage: asset.isFavorite ? "heart.slash" : "heart")
        }

        if !albums.isEmpty {
            Menu {
                ForEach(albums) { album in
                    Button {
                        onAddToAlbum(asset, album)
                    } label: {
                        Text("\(album.title)  (\(album.count))")
                    }
                }
            } label: {
                Label("Add to album", systemImage: "rectangle.stack.badge.plus")
            }
        }
    }
}
