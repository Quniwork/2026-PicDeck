import SwiftUI
import UniformTypeIdentifiers

struct MoreTabView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var organized: OrganizedStore
    @EnvironmentObject private var tagStore: TagStore
    @EnvironmentObject private var journalStore: JournalStore
    @ObservedObject private var cloudSync = CloudSyncService.shared
    @State private var showPaywall = false
    @State private var showTutorial = false
    @State private var syncAlertMessage: String?
    @State private var showSyncAlert = false
    @State private var backupFileURL: URL?
    @State private var showShareSheet = false
    @State private var showFileImporter = false
    @State private var restoreAlertMessage: String?
    @State private var showRestoreAlert = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: 系統同步狀態（頂部優先顯示）
                Section {
                    SyncStatusCard()
                }

                Section("方案狀態") {
                    LabeledContent("目前方案", value: planName)
                        .pageRowInsets()
                    if let expiry = model.subscriptionExpiry {
                        LabeledContent("到期日") {
                            Text(expiry, format: .dateTime.year().month().day())
                        }
                        .pageRowInsets()
                        .accessibilityIdentifier("more.expiry")
                    }
                    LabeledContent("每日整理額度", value: dailyStatus)
                        .pageRowInsets()
                        .accessibilityIdentifier("more.daily")
                    LabeledContent("每日日記額度", value: journalStatus)
                        .pageRowInsets()
                        .accessibilityIdentifier("more.journalDaily")
                    LabeledContent("標籤功能", value: "無限制")
                        .pageRowInsets()
                    LabeledContent("紀念日標籤", value: anniversaryStatus)
                        .pageRowInsets()
                        .accessibilityIdentifier("more.anniversary")
                    if model.isUnlocked {
                        Button("管理訂閱項目") {
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .pageRowInsets()
                    } else {
                        Button("解鎖 PicDeck 完整功能") { showPaywall = true }
                            .pageRowInsets()
                    }
                }

                Section("資料自動備份與同步") {
                    LabeledContent("同步狀態") {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("全自動背景同步中")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .pageRowInsets()

                    LabeledContent("備份存放位置") {
                        Text("我的 iPhone > PicDeck")
                            .foregroundStyle(.secondary)
                    }
                    .pageRowInsets()

                    if let lastBackup = cloudSync.lastAutoBackupDate {
                        LabeledContent("上次自動備份") {
                            Text(lastBackup, format: .dateTime.month().day().hour().minute().second())
                                .foregroundStyle(.secondary)
                        }
                        .pageRowInsets()
                    }

                    LabeledContent("iCloud 雲端鏡像") {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(cloudSync.isICloudAvailable ? Color.green : Color.orange)
                                .frame(width: 8, height: 8)
                            Text(cloudSync.isICloudAvailable ? "已連線" : "正式上架自動啟用")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .pageRowInsets()

                    Text("【全自動防刪除保護】已在 iPhone「檔案」App 中建立專屬「PicDeck」資料夾。每次新增標籤、日記記錄或相片備註時，系統皆會全自動即時同步備份至該目錄，完全無需任何手動操作。刪除 App 重新安裝時亦會自動為您偵測還原。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .pageRowInsets()
                }

                Section("備份管理（進階）") {
                    Button {
                        if let url = cloudSync.createBackupArchiveURL() {
                            backupFileURL = url
                            showShareSheet = true
                        }
                    } label: {
                        Label("另存備份檔案複本", systemImage: "square.and.arrow.up")
                    }
                    .pageRowInsets()

                    Button {
                        showFileImporter = true
                    } label: {
                        Label("從外部檔案手動還原", systemImage: "square.and.arrow.down")
                    }
                    .pageRowInsets()
                }

                Section("介面外觀") {
                    Picker("外觀模式", selection: $model.appearance) {
                        ForEach(AppAppearance.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .pageRowInsets()
                    .accessibilityIdentifier("more.appearance")
                }

                Section("使用幫助") {
                    Button("重新播放手勢教學") { showTutorial = true }
                        .pageRowInsets()
                }

                Section("隱私保護") {
                    Text("PicDeck 完全在您的本機裝置上運作。您的相片永遠不會上傳至任何第三方伺服器，雲端同步僅限於您個人專屬的私人 iCloud 容器。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .pageRowInsets()
                }

                Section("開發者測試") {
                    Button("重置解鎖狀態（測試）", role: .destructive) {
                        model.resetUnlockForTesting()
                    }
                    .pageRowInsets()
                    Button("重置保留記錄（測試）", role: .destructive) {
                        organized.resetKeptForTesting()
                    }
                    .pageRowInsets()
                    Button("重置標籤記錄（測試）", role: .destructive) {
                        tagStore.resetForTesting()
                    }
                    .pageRowInsets()
                    Button("重置日記記錄（測試）", role: .destructive) {
                        journalStore.resetForTesting()
                    }
                    .pageRowInsets()
                    LabeledContent("版本號碼", value: appVersion)
                        .pageRowInsets()
                }
            }
            .pageList(firstSectionHasHeader: true)
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: dynamicTypeSize.isAccessibilitySize ? 0 : PageMetrics.largeTitleBodyOffset)
                    .accessibilityHidden(true)
            }
            .navigationTitle("更多")
            .navigationBarTitleDisplayMode(dynamicTypeSize.isAccessibilitySize ? .large : .inline)
            .borderlessHeaderScrim()
            .toolbar {
                if !dynamicTypeSize.isAccessibilitySize {
                    LeadingTitleToolbar(title: "更多", font: .largeTitle)
                }
            }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .sheet(isPresented: $showShareSheet) {
                if let url = backupFileURL {
                    ActivityView(activityItems: [url])
                }
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.data, .json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let selectedURL = urls.first else { return }
                    let success = cloudSync.restoreFromBackupArchive(at: selectedURL)
                    if success {
                        restoreAlertMessage = "還原成功！已完整恢復您的標籤、日記與相片備註記錄。"
                    } else {
                        restoreAlertMessage = "還原失敗，請確認選擇的備份檔案是否正確。"
                    }
                    showRestoreAlert = true
                case .failure(let error):
                    restoreAlertMessage = "選取檔案失敗：\(error.localizedDescription)"
                    showRestoreAlert = true
                }
            }
            .alert("iCloud 連線診斷", isPresented: $showSyncAlert) {
                Button("了解", role: .cancel) {}
            } message: {
                Text(syncAlertMessage ?? "")
            }
            .alert("資料還原", isPresented: $showRestoreAlert) {
                Button("確定", role: .cancel) {}
            } message: {
                Text(restoreAlertMessage ?? "")
            }
            .fullScreenCover(isPresented: $showTutorial) {
                TutorialView { showTutorial = false }
            }
        }
    }

    private var planName: String {
        if model.isTrialActive {
            return String(format: "免費試用：剩餘 %lld 天", model.trialDaysLeft)
        }
        switch model.purchasedPlan {
        case .monthly: return "每月訂閱"
        case .lifetime: return "買斷終生版"
        case nil: return "免費版"
        }
    }

    private var dailyStatus: String {
        model.isUnlocked
            ? "無限制"
            : String(format: "%lld / %lld 張照片", model.processedToday, AppModel.dailyFreeLimit)
    }

    private var anniversaryStatus: String {
        // 訂閱後不限個數；免費版顯示 目前 / 上限。
        model.isUnlocked
            ? "無限制"
            : String(format: "%lld / %lld 個", tagStore.anniversaryCount(), TagStore.freeAnniversaryLimit)
    }

    private var journalStatus: String {
        model.isUnlocked
            ? "無限制"
            : String(format: "%lld / %lld 篇", model.journalCreatedToday, AppModel.dailyJournalFreeLimit)
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }
}

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
