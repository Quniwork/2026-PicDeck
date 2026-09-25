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
                // 標籤多了之後放在最下面要捲很久，所以放最上面。
                Section {
                    CreateTagButton(assets: assets)
                        .pageRowInsets(vertical: 6)
                }

                if !tagStore.tags.isEmpty {
                    Section(assets.count == 1 ? String(localized: "Tags")
                                              : String(localized: "Apply to \(assets.count) photos")) {
                        ForEach(tagStore.tagsByRecentUse) { tag in
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
                            .buttonStyle(.plain)
                            .pageRowInsets(vertical: 6)
                        }
                    }
                }

                if tagStore.tags.isEmpty {
                    Section {
                        Text("標籤建立完全免費，依標籤篩選照片為進階解鎖功能。")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .pageList()
            .navigationTitle("加入標籤")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                        .accessibilityIdentifier("tagpicker.done")
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
