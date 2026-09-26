import SwiftUI
import Photos

/// 日記分頁：列出寫過的日記。右上角可以用標籤、分類篩選，調整照片大小，旁邊的 + 新增日記。
struct JournalTabView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var tagStore: TagStore
    @EnvironmentObject private var journalStore: JournalStore

    @State private var tagID: UUID?
    @State private var categoryID: JournalCategory.ID?
    @State private var activeSheet: ActiveSheet?

    /// 這個畫面會跳出的表單。合併成一個 sheet，避免多個 .sheet 疊在同一個畫面上（見照片分頁的註解）。
    private enum ActiveSheet: Identifiable {
        case paywall
        case newEntry(JournalDate)
        case editEntry(JournalEntry)
        case categories

        var id: String {
            switch self {
            case .paywall: return "paywall"
            case .newEntry(let date): return "new-\(date.id)-\(date.photoIDs.count)"
            case .editEntry(let entry): return "edit-\(entry.id)"
            case .categories: return "categories"
            }
        }
    }

    private static let columnRange = AppModel.gridColumnRange

    private var selectedTag: PhotoTag? {
        tagID.flatMap { tagStore.tag(withID: $0) }
    }

    /// 有篩選標籤就只留照片帶著那個標籤的日記。
    private var allowedPhotoIDs: Set<String>? {
        guard let selectedTag else { return nil }
        return Set(tagStore.assetIDs(withTag: selectedTag.id))
    }

    private var isFilterActive: Bool {
        tagID != nil || categoryID != nil || !model.journalNewestFirst
    }

    private func resetFilters() {
        tagID = nil
        categoryID = nil
        model.journalNewestFirst = true
    }

    /// 目前看得到的日記篇數（有篩選就只算符合的）。
    private var entryCountText: String {
        let entries = journalStore.sortedEntries.filter { entry in
            if let allowedPhotoIDs, !entry.photoIDs.contains(where: { allowedPhotoIDs.contains($0) }) { return false }
            if let categoryID, entry.categoryID != categoryID { return false }
            return true
        }
        return String(format: String(localized: "%lld journal entries"), entries.count)
    }

    var body: some View {
        NavigationStack {
            Group {
                JournalEntriesView(onEdit: { entry in
                    activeSheet = .editEntry(entry)
                }, onAddForDay: { year, month, day in
                    newEntry(year: year, month: month, day: day)
                },
                                   anniversaryTag: selectedTag?.hasAnniversary == true ? selectedTag : nil,
                                   allowedPhotoIDs: allowedPhotoIDs,
                                   categoryID: categoryID,
                                   newestFirst: model.journalNewestFirst,
                                   columnCount: model.gridColumns(for: .journal),
                                   fitsAspect: model.gridFitsAspect(for: .journal))
                    .pinchToZoomGrid { model.zoom(.journal, in: $0) }
                    // 換篩選、排序時，日記卡片淡入淡出並重新排列。
                    .motionAnimation(value: tagID)
                    .motionAnimation(value: categoryID)
                    .motionAnimation(value: model.journalNewestFirst)
                    .motionAnimation(value: model.gridColumns(for: .journal))
            }
            .navigationTitle("日記")
            .navigationBarTitleDisplayMode(dynamicTypeSize.isAccessibilitySize ? .large : .inline)
            .borderlessHeaderScrim()
            .overlay(alignment: .top) {
                BorderlessPageHeader(title: "日記") {
                    filterMenu
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .floatingGlass(in: Circle(), interactive: true)
                    Button {
                        addEntry()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(Text("新增日記"))
                    .accessibilityIdentifier("journal.add")
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .floatingGlass(in: Circle(), interactive: true)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .paywall:
                PaywallView()
            case .newEntry(let date):
                JournalEditorView(year: date.year, month: date.month, day: date.day,
                                  preselectedIDs: date.photoIDs,
                                  allowsDateChange: true)
            case .editEntry(let entry):
                JournalEditorView(entry: entry)
            case .categories:
                JournalCategoryManagerView()
            }
        }
    }

    /// 新增今天的日記；永遠是新的一篇，就算今天已經寫過了。
    private func addEntry() {
        // 免費版每天只能新增 1 則，這裡先擋，省得使用者寫完才被告知。
        // 訂閱後這裡永遠會過，每次都是開一篇新的空白日記，不會變成編輯舊的。
        guard model.canCreateJournal else {
            activeSheet = .paywall
            return
        }
        let parts = PhotoGrouping.calendar.dateComponents([.year, .month, .day], from: Date())
        guard let year = parts.year, let month = parts.month, let day = parts.day else { return }
        // 從「＋」新增可以改日期，寫到別天去。
        activeSheet = .newEntry(JournalDate(year: year, month: month, day: day, isNew: true))
    }

    /// 從某一天的日期旁「＋」新增這天的另一篇：日期固定，不能改。
    private func newEntry(year: Int, month: Int, day: Int) {
        guard model.canCreateJournal else {
            activeSheet = .paywall
            return
        }
        activeSheet = .newEntry(JournalDate(year: year, month: month, day: day))
    }

    // MARK: - 篩選

    private var filterMenu: some View {
        Menu {
            ResetFiltersButton(isActive: isFilterActive, reset: resetFilters)

            // 一排文字：預設由新到舊；點一下（打勾）就變成由舊到新，再點回來。
            Toggle(isOn: Binding(get: { !model.journalNewestFirst },
                                 set: { model.journalNewestFirst = !$0 })) {
                Label(String(localized: "Sort by Date"), systemImage: "arrow.up.arrow.down")
            }
            .accessibilityIdentifier("journal.sort")

            Section(String(localized: "Tags")) {
                Toggle(isOn: Binding(get: { tagID == nil }, set: { _ in tagID = nil })) {
                    Label(String(localized: "All Items"), systemImage: "square.grid.3x3")
                }
                ForEach(tagStore.tags) { tag in
                    Toggle(isOn: Binding(get: { tagID == tag.id }, set: { _ in choose(tag) })) {
                        Label {
                            Text(tag.name)
                        } icon: {
                            TagMenuIcon(tag: tag)
                        }
                    }
                }
            }

            Section(String(localized: "Category")) {
                Toggle(isOn: Binding(get: { categoryID == nil }, set: { _ in categoryID = nil })) {
                    Label(String(localized: "All Categories"), systemImage: "square.grid.3x3")
                }
                ForEach(journalStore.categories) { category in
                    Toggle(isOn: Binding(get: { categoryID == category.id }, set: { _ in categoryID = category.id })) {
                        Label {
                            Text(category.name)
                        } icon: {
                            IconLabel(raw: category.symbol, size: 18)
                        }
                    }
                }
                Button { activeSheet = .categories } label: {
                    Label(String(localized: "Manage categories"), systemImage: "slider.horizontal.3")
                }
                .accessibilityIdentifier("journal.category.manage.menu")
            }

            Menu(String(localized: "View Options")) {
                Button {
                    model.zoom(.journal, in: true)
                } label: {
                    Label(String(localized: "Zoom In"), systemImage: "plus.magnifyingglass")
                }
                .disabled(model.gridColumns(for: .journal) <= Self.columnRange.lowerBound)

                Button {
                    model.zoom(.journal, in: false)
                } label: {
                    Label(String(localized: "Zoom Out"), systemImage: "minus.magnifyingglass")
                }
                .disabled(model.gridColumns(for: .journal) >= Self.columnRange.upperBound)

                Toggle(isOn: Binding(get: { model.gridFitsAspect(for: .journal) },
                                     set: { model.setGridFitsAspect($0, for: .journal) })) {
                    Label("原始比例網格",
                          systemImage: "rectangle.arrowtriangle.2.outward")
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .filterIndicator(isActive: isFilterActive, reset: resetFilters)
        }
        .accessibilityLabel(Text("篩選"))
        .accessibilityIdentifier("journal.filter")
    }

    /// 標籤篩選是付費功能，沒解鎖就導到付費頁。
    private func choose(_ tag: PhotoTag) {
        if model.isUnlocked {
            tagID = tag.id
        } else {
            activeSheet = .paywall
        }
    }
}
