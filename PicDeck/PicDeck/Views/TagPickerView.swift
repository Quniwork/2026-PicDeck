import SwiftUI
import Photos

/// 幫照片加標籤。單張或多張共用，可以直接在這裡新增標籤。
struct TagPickerView: View {
    /// 要加標籤的照片，一張或多張。
    let assets: [PHAsset]

    @EnvironmentObject private var tagStore: TagStore
    @Environment(\.dismiss) private var dismiss


    var body: some View {
        NavigationStack {
            List {
                if !tagStore.tags.isEmpty {
                    Section(assets.count == 1 ? String(localized: "Tags")
                                              : String(localized: "Apply to \(assets.count) photos")) {
                        ForEach(tagStore.tags) { tag in
                            Button {
                                toggle(tag)
                            } label: {
                                HStack {
                                    IconLabel(raw: tag.symbol, size: 17)
                                    Text(tag.name).foregroundStyle(.primary)
                                    Spacer()
                                    if isApplied(tag) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.tint)
                                    }
                                }
                            }
                        }
                    }
                }

                Section {
                    CreateTagButton(assets: assets)
                }

                if tagStore.tags.isEmpty {
                    Section {
                        Text("Tags are free. Filtering by tag needs the paid unlock.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Add tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    /// 多張時，只有全部都有這個標籤才算已套用。
    private func isApplied(_ tag: PhotoTag) -> Bool {
        !assets.isEmpty && assets.allSatisfy { tagStore.tagIDs(for: $0).contains(tag.id) }
    }

    private func toggle(_ tag: PhotoTag) {
        if isApplied(tag) {
            for asset in assets {
                var ids = tagStore.tagIDs(for: asset)
                ids.remove(tag.id)
                tagStore.setTags(ids, for: asset)
            }
        } else {
            tagStore.addTag(tag.id, to: assets)
        }
    }

}

/// 標籤很多時用的完整清單，可以搜尋。從篩選選單的「全部標籤」進來。
struct TagFilterSheet: View {
    /// 目前選中的標籤。
    let selected: UUID?
    let onPick: (PhotoTag) -> Void

    @EnvironmentObject private var tagStore: TagStore
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""

    private var results: [PhotoTag] {
        let needle = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !needle.isEmpty else { return tagStore.tags }
        return tagStore.tags.filter { $0.name.lowercased().contains(needle) }
    }

    var body: some View {
        NavigationStack {
            List {
                if results.isEmpty {
                    Text("No matches.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(results) { tag in
                        Button {
                            onPick(tag)
                            dismiss()
                        } label: {
                            HStack(spacing: 10) {
                                IconLabel(raw: tag.symbol, size: 18)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(tag.name).foregroundStyle(.primary)
                                    if let text = tag.anniversaryText(on: Date()) {
                                        Text(text)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Text("\(tagStore.usageCount(of: tag.id))")
                                    .foregroundStyle(.secondary)
                                if tag.id == selected {
                                    Image(systemName: "checkmark").foregroundStyle(.tint)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                        .accessibilityIdentifier("tagfilter.row")
                    }
                }
            }
            .searchable(text: $query, prompt: Text("Search tags"))
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
