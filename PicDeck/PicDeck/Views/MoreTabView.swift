import SwiftUI

struct MoreTabView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
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
                        .pageRowInsets()
                    if let expiry = model.subscriptionExpiry {
                        LabeledContent("Expires on") {
                            Text(expiry, format: .dateTime.year().month().day())
                        }
                        .pageRowInsets()
                        .accessibilityIdentifier("more.expiry")
                    }
                    LabeledContent("Organize (daily)", value: dailyStatus)
                        .pageRowInsets()
                        .accessibilityIdentifier("more.daily")
                    LabeledContent("Journal (daily)", value: journalStatus)
                        .pageRowInsets()
                        .accessibilityIdentifier("more.journalDaily")
                    LabeledContent("Tags", value: String(localized: "Unlimited"))
                        .pageRowInsets()
                    LabeledContent("Tags with dates", value: anniversaryStatus)
                        .pageRowInsets()
                        .accessibilityIdentifier("more.anniversary")
                    if model.isUnlocked {
                        Button("Manage subscription") {
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .pageRowInsets()
                    } else {
                        Button("Unlock PicDeck") { showPaywall = true }
                            .pageRowInsets()
                    }
                }

                Section("Interface") {
                    Picker("Appearance", selection: $model.appearance) {
                        ForEach(AppAppearance.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .pageRowInsets()
                    .accessibilityIdentifier("more.appearance")
                }

                Section("Help") {
                    Button("Replay gesture tutorial") { showTutorial = true }
                        .pageRowInsets()
                }

                Section("Privacy") {
                    Text("PicDeck works entirely on your device. Photos are never uploaded to any server.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .pageRowInsets()
                }

                Section("Developer") {
                    Button("Reset unlock (testing)", role: .destructive) {
                        model.resetUnlockForTesting()
                    }
                    .pageRowInsets()
                    Button("Reset kept records (testing)", role: .destructive) {
                        organized.resetKeptForTesting()
                    }
                    .pageRowInsets()
                    Button("Reset tags (testing)", role: .destructive) {
                        tagStore.resetForTesting()
                    }
                    .pageRowInsets()
                    Button("Reset journal (testing)", role: .destructive) {
                        journalStore.resetForTesting()
                    }
                    .pageRowInsets()
                    LabeledContent("Version", value: appVersion)
                        .pageRowInsets()
                }
            }
            .pageList(firstSectionHasHeader: true)
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: dynamicTypeSize.isAccessibilitySize ? 0 : PageMetrics.largeTitleBodyOffset)
                    .accessibilityHidden(true)
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(dynamicTypeSize.isAccessibilitySize ? .large : .inline)
            .toolbar {
                if !dynamicTypeSize.isAccessibilitySize {
                    LeadingTitleToolbar(title: String(localized: "More"), font: .largeTitle)
                }
            }
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
        // 訂閱後不限個數；免費版顯示 目前 / 上限。
        model.isUnlocked
            ? String(localized: "Unlimited")
            : String(format: String(localized: "%lld / %lld tags"), tagStore.anniversaryCount(), TagStore.freeAnniversaryLimit)
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
