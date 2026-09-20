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
                .environment(\.dynamicTypeSize, .small)
                .onAppear { model.appearance.apply() }
        }
        .onChange(of: scenePhase) { _, phase in
            // 進背景時把保留紀錄立刻寫入磁碟。
            if phase != .active {
                organized.flush()
                tagStore.flush()
                journalStore.flush()
                noteStore.flush()
            }
        }
    }
}
