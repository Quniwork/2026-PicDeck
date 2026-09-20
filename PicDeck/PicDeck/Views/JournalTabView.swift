import SwiftUI
import Photos

/// 日記分頁：列出寫過的日記。右上角可以用標籤篩選、調整照片大小，旁邊的 + 新增日記。
struct JournalTabView: View {
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var tagStore: TagStore
    @EnvironmentObject private var journalStore: JournalStore

    @State private var tagID: UUID?
    @State private var activeSheet: ActiveSheet?

    /// 這個畫面會跳出的表單。合併成一個 sheet，避免多個 .sheet 疊在同一個畫面上（見照片分頁的註解）。
    private enum ActiveSheet: Identifiable {
        case paywall
        case editor(JournalDate)

        var id: String {
            switch self {
            case .paywall: return "paywall"
            case .editor(let date): return "editor-\(date.id)"
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

    /// 目前看得到的日記篇數（有標籤篩選就只算符合的）。
    private var entryCountText: String {
        let entries = journalStore.sortedEntries
        let count: Int
        if let allowedPhotoIDs {
            count = entries.filter { entry in entry.photoIDs.contains { allowedPhotoIDs.contains($0) } }.count
        } else {
            count = entries.count
        }
        return String(format: String(localized: "%lld journal entries"), count)
    }

    var body: some View {
        NavigationStack {
            Group {
                if model.isUnlocked {
                    JournalEntriesView(onEdit: { year, month, day in
                        activeSheet = .editor(JournalDate(year: year, month: month, day: day))
                    },
                                       anniversaryTag: selectedTag?.hasAnniversary == true ? selectedTag : nil,
                                       allowedPhotoIDs: allowedPhotoIDs,
                                       newestFirst: model.journalNewestFirst,
                                       columnCount: model.gridColumns(for: .journal),
                                       fitsAspect: model.gridFitsAspect(for: .journal))
                } else {
                    ContentUnavailableView {
                        Label("Journal", systemImage: "book")
                    } description: {
                        Text("Journal is part of the paid unlock.")
                    } actions: {
                        Button("Unlock") { activeSheet = .paywall }
                            .buttonStyle(.borderedProminent)
                            .accessibilityIdentifier("journal.unlock")
                    }
                }
            }
            .navigationTitle(String(localized: "Journal"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 主標題與副標題的字級跟照片分頁的「所有項目／607 個項目」一樣。
                LeadingTitleToolbar(title: String(localized: "Journal"), font: .title2, subtitle: entryCountText)
                ToolbarItem(placement: .topBarTrailing) { filterMenu }
                if #available(iOS 26.0, *) {
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addEntry()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(Text("New journal entry"))
                    .accessibilityIdentifier("journal.add")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .paywall:
                PaywallView()
            case .editor(let date):
                JournalEditorView(year: date.year, month: date.month, day: date.day,
                                  preselectedIDs: date.photoIDs,
                                  allowsDateChange: date.isNew)
            }
        }
    }

    /// 新增今天的日記；已經有的話編輯畫面會載入原本的內容。
    private func addEntry() {
        guard model.isUnlocked else {
            activeSheet = .paywall
            return
        }
        let parts = PhotoGrouping.calendar.dateComponents([.year, .month, .day], from: Date())
        guard let year = parts.year, let month = parts.month, let day = parts.day else { return }
        activeSheet = .editor(JournalDate(year: year, month: month, day: day, isNew: true))
    }

    // MARK: - 篩選

    private var filterMenu: some View {
        Menu {
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
                            tagIcon(tag)
                        }
                    }
                }
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
                    Label(String(localized: "Aspect Ratio Grid"),
                          systemImage: "rectangle.arrowtriangle.2.outward")
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .overlay(alignment: .topTrailing) {
                    if tagID != nil {
                        Circle().fill(.red).frame(width: 7, height: 7).offset(x: 4, y: -3)
                    }
                }
        }
        .accessibilityLabel(Text("Filter"))
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

    /// 選單只吃圖片，所以把標籤的表情或圖標先畫成圖片。
    @ViewBuilder
    private func tagIcon(_ tag: PhotoTag) -> some View {
        let renderer = ImageRenderer(content: IconLabel(raw: tag.symbol, size: 18)
            .frame(width: 22, height: 22))
        let _ = renderer.scale = 3
        if let image = renderer.uiImage {
            Image(uiImage: image).renderingMode(.original)
        } else {
            Image(systemName: "tag")
        }
    }
}
