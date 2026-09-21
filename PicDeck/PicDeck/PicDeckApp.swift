import SwiftUI

@main
struct PicDeckApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var library = PhotoLibraryService()
    @StateObject private var model = AppModel()
    @StateObject private var organized = OrganizedStore()
    @StateObject private var tagStore = TagStore()
    @StateObject private var journalStore = JournalStore()
    @StateObject private var noteStore = NoteStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(library)
                .environmentObject(model)
                .environmentObject(organized)
                .environmentObject(tagStore)
                .environmentObject(journalStore)
                .environmentObject(noteStore)
                // 字比系統設定小兩級，並且跟著系統的文字大小走。
                .modifier(RelativeTypeSize())
                .onAppear { model.appearance.apply() }
                // 桌面小工具的資料：啟動時、標籤有變動時同步一次。
                .task(id: tagStore.assignments.count &+ tagStore.tags.count &* 1000) {
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    await WidgetSync.sync(tagStore: tagStore, library: library)
                }
                // 點小工具：切到選集並打開那個標籤。
                .onOpenURL { url in
                    guard url.scheme == "picdeck", url.host == "tag",
                          let id = UUID(uuidString: url.lastPathComponent) else { return }
                    // 點小工具：直接到「照片 → 時間軸」，套用那個標籤。
                    model.requestedScale = .timeline
                    model.requestedSelection = .tag(id)
                    model.selectedTab = 2
                }
        }
        .onChange(of: scenePhase) { _, phase in
            // 進背景時把保留紀錄立刻寫入磁碟。
            if phase == .active { model.refreshEntitlement() }
            if phase == .background { Task { await WidgetSync.sync(tagStore: tagStore, library: library) } }
            if phase != .active {
                organized.flush()
                tagStore.flush()
                journalStore.flush()
                noteStore.flush()
            }
        }
    }
}
