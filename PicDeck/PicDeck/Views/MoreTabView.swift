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
                Section("Status") {
                    LabeledContent("Plan", value: planName)
                    if let expiry = model.subscriptionExpiry {
                        LabeledContent("Expires on") {
                            Text(expiry, format: .dateTime.year().month().day())
                        }
                        .accessibilityIdentifier("more.expiry")
                    }
                    LabeledContent("Organize (daily)", value: dailyStatus)
                        .accessibilityIdentifier("more.daily")
                    LabeledContent("Journal (daily)", value: journalStatus)
                        .accessibilityIdentifier("more.journalDaily")
                    LabeledContent("Tags", value: String(localized: "Unlimited"))
                    LabeledContent("Tags with dates", value: anniversaryStatus)
                        .accessibilityIdentifier("more.anniversary")
                    if model.isUnlocked {
                        Button("Manage subscription") {
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                UIApplication.shared.open(url)
                            }
                        }
                    } else {
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

                Section("Help") {
                    Button("Replay gesture tutorial") { showTutorial = true }
                }

                Section("Privacy") {
                    Text("PicDeck works entirely on your device. Photos are never uploaded to any server.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
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

    private var planName: String {
        if model.isTrialActive {
            return String(format: String(localized: "Free trial: %lld days left"), model.trialDaysLeft)
        }
        switch model.purchasedPlan {
        case .monthly: return String(localized: "Monthly subscription")
        case .lifetime: return String(localized: "Lifetime")
        case nil: return String(localized: "Free")
        }
    }

    private var dailyStatus: String {
        model.isUnlocked
            ? String(localized: "Unlimited")
            : String(format: String(localized: "%lld / %lld photos"),
                     model.processedToday, AppModel.dailyFreeLimit)
    }

    private var anniversaryStatus: String {
        let count = tagStore.anniversaryCount()
        return model.isUnlocked
            ? String(format: String(localized: "%lld tags"), count)
            : String(format: String(localized: "%lld / %lld tags"), count, TagStore.freeAnniversaryLimit)
    }

    private var journalStatus: String {
        model.isUnlocked
            ? String(localized: "Unlimited")
            : String(format: String(localized: "%lld / %lld entries"),
                     model.journalCreatedToday, AppModel.dailyJournalFreeLimit)
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }
}
