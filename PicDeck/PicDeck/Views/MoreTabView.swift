import SwiftUI

struct MoreTabView: View {
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var organized: OrganizedStore
    @EnvironmentObject private var tagStore: TagStore
    @EnvironmentObject private var journalStore: JournalStore
    @State private var showPaywall = false
    @State private var showTutorial = false

    var body: some View {
        NavigationStack {
            List {
                Section("Plan") {
                    LabeledContent("Status",
                                   value: model.isUnlocked ? String(localized: "Unlocked")
                                                           : String(localized: "Free"))
                    if model.isUnlocked {
                        LabeledContent("Daily limit", value: String(localized: "None"))
                    } else {
                        LabeledContent("Today", value: "\(model.processedToday) / \(AppModel.dailyFreeLimit)")
                        Button("Unlock PicDeck") { showPaywall = true }
                    }
                }

                Section("Interface") {
                    Picker("Appearance", selection: $model.appearance) {
                        ForEach(AppAppearance.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("more.appearance")
                }

                Section("Journal") {
                    LabeledContent("Entries", value: "\(journalStore.count)")
                }

                Section("Help") {
                    Button("Replay gesture tutorial") { showTutorial = true }
                }

                Section("Privacy") {
                    Text("PicDeck works entirely on your device. Photos are never uploaded to any server.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Organize state") {
                    LabeledContent("Marked as kept", value: "\(organized.keptCount)")
                }

                Section("Developer") {
                    Button("Reset unlock (testing)", role: .destructive) {
                        model.resetUnlockForTesting()
                    }
                    Button("Reset kept records (testing)", role: .destructive) {
                        organized.resetKeptForTesting()
                    }
                    Button("Reset tags (testing)", role: .destructive) {
                        tagStore.resetForTesting()
                    }
                    Button("Reset journal (testing)", role: .destructive) {
                        journalStore.resetForTesting()
                    }
                    LabeledContent("Version", value: appVersion)
                }
            }
            // 第一個小標題本身有留白，往上補回來，跟其他分頁的第一個內容同高。
            .contentMargins(.top, -12, for: .scrollContent)
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { LeadingTitleToolbar(title: String(localized: "More"), ) }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .fullScreenCover(isPresented: $showTutorial) {
                TutorialView { showTutorial = false }
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }
}
