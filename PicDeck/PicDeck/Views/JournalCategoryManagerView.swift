import SwiftUI

/// 管理日記自己的分類：新增、改名、換圖示、排序、刪除。
/// 跟照片標籤是兩套獨立系統，這裡改動不影響標籤。
struct JournalCategoryManagerView: View {
    @EnvironmentObject private var journalStore: JournalStore
    @Environment(\.dismiss) private var dismiss

    @State private var editingCategory: JournalCategory?
    @State private var showCreate = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if journalStore.categories.isEmpty {
                        Text("尚未建立任何分類")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .pageRowInsets(vertical: 6)
                    } else {
                        ForEach(journalStore.categories) { category in
                            Button {
                                editingCategory = category
                            } label: {
                                HStack(spacing: 10) {
                                    IconLabel(raw: category.symbol, size: 18)
                                    Text(category.name).foregroundStyle(.primary)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .pageRowInsets(vertical: 6)
                            .accessibilityIdentifier("journal.category.row")
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                journalStore.deleteCategory(id: journalStore.categories[index].id)
                            }
                        }
                        .onMove { source, destination in
                            journalStore.moveCategories(fromOffsets: source, toOffset: destination)
                        }
                    }
                } header: {
                    HStack {
                        Text("分類清單")
                        Spacer()
                        if journalStore.categories.count > 1 {
                            EditButton()
                                .font(.footnote)
                                .textCase(nil)
                                .accessibilityIdentifier("journal.category.edit")
                        }
                    }
                } footer: {
                    Text("為生活日記設定專屬分類，與相片標籤獨立運作。刪除分類不會刪除日記內文。")
                }
            }
            .pageList(firstSectionHasHeader: true)
            .navigationTitle("管理日記分類")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button { showCreate = true } label: { Image(systemName: "plus") }
                        .accessibilityIdentifier("journal.category.add")
                }
            }
            .sheet(isPresented: $showCreate) {
                JournalCategoryFormView(mode: .create)
            }
            .sheet(item: $editingCategory) { category in
                JournalCategoryFormView(mode: .edit(category))
            }
        }
    }
}

/// 新增或編輯一個日記分類：名稱加一個圖示。
struct JournalCategoryFormView: View {
    enum Mode {
        case create
        case edit(JournalCategory)
    }

    let mode: Mode

    @EnvironmentObject private var journalStore: JournalStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var symbol = "sf:tag"

    private var editingCategory: JournalCategory? {
        if case .edit(let category) = mode { return category }
        return nil
    }

    private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 10) {
                        IconPickerButton(raw: $symbol, removedValue: "sf:tag", identifier: "journal.category.icon")
                        TextField("分類名稱", text: $name)
                            .accessibilityIdentifier("journal.category.name")
                    }
                }

                if let editingCategory {
                    Section {
                        DestructiveRowButton(title: "刪除分類",
                                             identifier: "journal.category.delete") {
                            journalStore.deleteCategory(id: editingCategory.id)
                            dismiss()
                        }
                    }
                }
            }
            .appCanvas()
            .navigationTitle(editingCategory == nil ? "新增分類" : "編輯分類")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        if let editingCategory {
                            journalStore.renameCategory(id: editingCategory.id, to: trimmedName, symbol: symbol)
                        } else {
                            journalStore.addCategory(name: trimmedName, symbol: symbol)
                        }
                        dismiss()
                    }
                    .disabled(trimmedName.isEmpty)
                    .accessibilityIdentifier("journal.category.save")
                }
            }
            .onAppear {
                if let editingCategory {
                    name = editingCategory.name
                    symbol = editingCategory.symbol
                }
            }
        }
    }
}
