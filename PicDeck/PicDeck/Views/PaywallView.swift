import SwiftUI

/// 付費頁。兩種方案：每月訂閱（一杯咖啡的錢）與一次買斷；第一次可以免費試用 30 天。
/// 開發階段購買與試用都是本機模擬，尚未接 StoreKit，不會扣款。
struct PaywallView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    /// 價格集中在這裡，之後接 StoreKit 換成商品的 displayPrice。
    static let monthlyPrice = "NT$60"
    static let lifetimePrice = "NT$990"

    /// 開發期間訂閱免費，正式收費的時間與價格另行公告。開始收費時把這個改成 false。
    static let freeDuringDevelopment = true
    /// 買斷與試用先隱藏（程式都還在，要開再改成 true）。
    static let showsLifetime = false
    static let showsTrial = false

    @State private var selected: AppModel.Plan = .monthly

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    benefits
                    plans
                    actions
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(.systemBackground))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("關閉") { dismiss() }
                }
            }
        }
    }

    // MARK: - 區塊

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("解鎖 PicDeck 完整功能")
                .font(.largeTitle.weight(.bold))
            Text(model.isTrialActive
                 ? String(format: "免費試用：剩餘 %lld 天", model.trialDaysLeft)
                 : (Self.freeDuringDevelopment
                    ? "開發測試期間完全免費體驗，正式定價上架時將另行公告。"
                    : "一次訂閱，解鎖所有強大照片整理與生活紀錄功能。"))
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var benefits: some View {
        card {
            benefitRow(systemImage: "infinity",
                       title: "無每日整理上限",
                       detail: "免費版每天可整理 30 張照片，解鎖後享無限張數。")
            benefitRow(systemImage: "line.3.horizontal.decrease.circle",
                       title: "全功能進階篩選",
                       detail: "喜好項目、相片、影片與截圖等完整篩選維度。")
            benefitRow(systemImage: "tag",
                       title: "依個人標籤篩選照片",
                       detail: "標籤建立完全免費，解鎖後可直接按自訂標籤過濾瀏覽。")
            benefitRow(systemImage: "calendar",
                       title: "紀念日起算日標籤",
                       detail: "免費版提供 1 個紀念日標籤，解鎖後可建立無限多個。")
            benefitRow(systemImage: "book.closed",
                       title: "生活日記記錄",
                       detail: "免費版每日可建立 1 篇日記，解鎖後無篇數限制。")
        }
    }

    private var plans: some View {
        VStack(spacing: 10) {
            planRow(.monthly,
                    title: "每月訂閱",
                    detail: Self.freeDuringDevelopment
                        ? "開發測試期間免費，正式收費標準另行公告。"
                        : "一杯咖啡的價格，隨時可在設定中取消。",
                    price: (Self.freeDuringDevelopment ? "NT$0" : Self.monthlyPrice) + " / 月")
            if Self.showsLifetime {
                planRow(.lifetime,
                        title: "買斷終生版",
                        detail: "一次購買，終生享用所有現在與未來更新功能。",
                        price: Self.lifetimePrice)
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 12) {
            if Self.showsTrial && !model.hasUsedTrial {
                Button {
                    model.startTrial()
                    dismiss()
                } label: {
                    Text("開始 30 天免費試用").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier("paywall.trial")

                Button {
                    model.purchase(selected)
                    dismiss()
                } label: {
                    Text(buyTitle).frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .accessibilityIdentifier("paywall.buy")
            } else {
                Button {
                    model.purchase(selected)
                    dismiss()
                } label: {
                    Text(buyTitle).frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier("paywall.buy")
            }

            Text("開發測試環境：點擊按鈕僅於本機模擬解鎖，不會產生任何實際扣款。")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    private var buyTitle: String {
        if Self.freeDuringDevelopment { return "立即訂閱（開發階段免費）" }
        return selected == .monthly
            ? String(format: "立即訂閱 %@ / 月", Self.monthlyPrice)
            : String(format: "一次買斷 %@", Self.lifetimePrice)
    }

    // MARK: - 元件

    /// 所有卡片都撐滿整個寬度，左右邊才對得齊。
    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) { content() }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 14))
    }

    private func benefitRow(systemImage: String,
                            title: LocalizedStringKey,
                            detail: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
    }

    private func planRow(_ plan: AppModel.Plan, title: String, detail: String, price: String) -> some View {
        let isOn = selected == plan
        return Button {
            selected = plan
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isOn ? Color.accentColor : Color.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline.weight(.semibold))
                    Text(detail).font(.caption).foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Text(price).font(.subheadline.weight(.bold))
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isOn ? Color.accentColor : Color.clear, lineWidth: 2))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("paywall.plan.\(plan.rawValue)")
    }
}
