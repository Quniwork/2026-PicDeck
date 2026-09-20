import SwiftUI
import Photos

/// 標籤的表單。建立與編輯共用同一張，欄位一致：圖示、名稱、紀念日。
struct TagFormView: View {
    enum Mode {
        /// 建立新標籤。建好之後順便套到這些照片上。
        case create(assets: [PHAsset])
        case edit(PhotoTag)
    }

    let mode: Mode

    @EnvironmentObject private var tagStore: TagStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var symbol = TagStore.defaultSymbol
    @State private var hasAnniversary = false
    @State private var anniversary = Date()
    @State private var style: AnniversaryStyle = .yearMonthDay
    @State private var pinnedOnHome = false

    private var editingTag: PhotoTag? {
        if case .edit(let tag) = mode { return tag }
        return nil
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isDuplicate: Bool {
        !trimmedName.isEmpty && tagStore.nameExists(trimmedName, excluding: editingTag?.id)
    }

    private var canConfirm: Bool {
        !trimmedName.isEmpty && !isDuplicate
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 10) {
                        IconPickerButton(raw: $symbol,
                                         removedValue: TagStore.defaultSymbol,
                                         identifier: "tag.icon")
                        TextField(String(localized: "Tag name"), text: $name)
                            .accessibilityIdentifier("tag.name")
                    }
                } header: {
                    Text("Tag name")
                } footer: {
                    if isDuplicate {
                        Text("A tag with this name already exists.")
                            .foregroundStyle(.red)
                            .accessibilityIdentifier("tag.duplicate")
                    }
                }

                Section {
                    Toggle(isOn: $pinnedOnHome) {
                        Label("Pin to Home", systemImage: "pin")
                    }
                    .accessibilityIdentifier("tag.pinHome")
                } footer: {
                    Text("A pinned tag shows on Home as a collection. Open it to narrow down with other tags.")
                }

                AnniversaryFields(hasAnniversary: $hasAnniversary,
                                  anniversary: $anniversary,
                                  style: $style)

                if let editingTag {
                    Section {
                        DestructiveRowButton(title: String(localized: "Delete tag"),
                                             identifier: "tag.delete") {
                            tagStore.deleteTag(id: editingTag.id)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(editingTag == nil
                             ? String(localized: "New tag")
                             : String(localized: "Edit tag"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingTag == nil
                           ? String(localized: "Create")
                           : String(localized: "Save")) { confirm() }
                        .disabled(!canConfirm)
                        .accessibilityIdentifier("tag.save")
                }
            }
            .onAppear(perform: load)
        }
    }

    private func load() {
        guard let tag = editingTag else { return }
        name = tag.name
        symbol = tag.symbol
        hasAnniversary = tag.hasAnniversary
        anniversary = tag.anniversary ?? Date()
        style = tag.anniversaryStyle
        pinnedOnHome = tag.pinnedOnHome
    }

    private func confirm() {
        guard canConfirm else { return }

        switch mode {
        case .create(let assets):
            guard let tag = tagStore.createTag(name: trimmedName,
                                               symbol: symbol,
                                               anniversary: hasAnniversary ? anniversary : nil,
                                               anniversaryStyle: style,
                                               isPinned: hasAnniversary,
                                               pinnedOnHome: pinnedOnHome) else { return }
            if !assets.isEmpty { tagStore.addTag(tag.id, to: assets) }

        case .edit(let tag):
            tagStore.updateTag(id: tag.id,
                               name: trimmedName,
                               symbol: symbol,
                               anniversary: hasAnniversary ? anniversary : nil,
                               anniversaryStyle: style,
                               isPinned: hasAnniversary,
                               pinnedOnHome: pinnedOnHome)
        }
        dismiss()
    }
}

/// 開啟建立標籤表單的按鈕。
struct CreateTagButton: View {
    /// 建好之後要套上這個標籤的照片。
    var assets: [PHAsset] = []
    var identifier: String = "tag.create"

    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label("Create tag", systemImage: "plus.circle.fill")
        }
        .accessibilityIdentifier(identifier)
        .sheet(isPresented: $isPresented) {
            TagFormView(mode: .create(assets: assets))
        }
    }
}

/// 某一天旁邊的紀念日文字，例如「🧒 堯 6年1個月15天」。
///
/// 只有在篩選到某個設了日期的標籤時才顯示，平常瀏覽維持原本乾淨的日期標題。
struct AnniversaryChips: View {
    let date: Date
    /// 目前篩選到的紀念日標籤。沒有就整個不顯示。
    let tag: PhotoTag?
    var font: Font = .caption2

    var body: some View {
        if let tag, let text = tag.anniversaryText(on: date) {
            // 已經篩選到這個標籤，標題就是它了，這裡只顯示過了多久。
            HStack(spacing: 3) {
                Text(text).fontWeight(.semibold)
            }
            .font(font)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Color(.secondarySystemFill), in: Capsule())
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("anniversary.chip")
        }
    }
}


/// 紀念日的設定欄位。編輯標籤與新增標籤共用。
struct AnniversaryFields: View {
    @Binding var hasAnniversary: Bool
    @Binding var anniversary: Date
    @Binding var style: AnniversaryStyle
    /// 同一個畫面可能同時有「編輯現有標籤」與「新增標籤」兩組，識別碼要分開。
    var idPrefix: String = "tag"

    var body: some View {
        Section {
            Toggle(isOn: $hasAnniversary.animation()) {
                Text("Anniversary")
            }
            .accessibilityIdentifier("\(idPrefix).anniversary.toggle")

            if hasAnniversary {
                DatePicker(String(localized: "Start date"),
                           selection: $anniversary,
                           displayedComponents: .date)
                    .accessibilityIdentifier("\(idPrefix).anniversary.date")
            }
        } footer: {
            Text("Set a start date to count from, such as a child's birthday. Filtering by this tag then shows how long it had been on each day.")
        }

        if hasAnniversary {
            Section {
                ForEach(AnniversaryStyle.allCases) { option in
                    Button {
                        style = option
                    } label: {
                        HStack {
                            Image(systemName: style == option
                                  ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(style == option ? Color.accentColor : .secondary)
                            Text(option.title)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(Anniversary.text(from: anniversary, to: Date(), style: option))
                                .font(.callout.weight(style == option ? .semibold : .regular))
                                .foregroundStyle(style == option ? Color.accentColor : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .accessibilityIdentifier("\(idPrefix).style.\(option.rawValue)")
                }
            } header: {
                Text("Counting method")
            } footer: {
                Text("Shown for today. The start date counts as D+0 and day 1.")
            }
        }
    }
}
