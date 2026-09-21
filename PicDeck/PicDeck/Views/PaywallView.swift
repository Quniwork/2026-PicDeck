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
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    // MARK: - 區塊

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Unlock PicDeck")
                .font(.largeTitle.weight(.bold))
            Text(model.isTrialActive
                 ? String(format: String(localized: "Free trial: %lld days left"), model.trialDaysLeft)
                 : (Self.freeDuringDevelopment
                    ? String(localized: "Free during development. We'll announce when pricing starts.")
                    : String(localized: "One subscription unlocks everything.")))
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var benefits: some View {
        card {
            benefitRow(systemImage: "infinity",
                       title: "No daily limit",
                       detail: "The free plan handles 30 photos a day.")
            benefitRow(systemImage: "line.3.horizontal.decrease.circle",
                       title: "All filters",
                       detail: "Favorites, Photos, Videos and Screenshots.")
            benefitRow(systemImage: "tag",
                       title: "Filter by your tags",
                       detail: "Tagging stays free; filtering by tag needs the unlock.")
            benefitRow(systemImage: "calendar",
                       title: "Tags with dates",
                       detail: "Free: 1 tag with a date. Subscribe for unlimited.")
            benefitRow(systemImage: "book.closed",
                       title: "Journal",
                       detail: "Free: 1 new entry a day. Subscribe for unlimited.")
        }
    }

    private var plans: some View {
        VStack(spacing: 10) {
            planRow(.monthly,
                    title: String(localized: "Monthly"),
                    detail: Self.freeDuringDevelopment
                        ? String(localized: "Free during development. Pricing will be announced later.")
                        : String(localized: "About the price of a coffee. Cancel anytime."),
                    price: (Self.freeDuringDevelopment ? "NT$0" : Self.monthlyPrice) + String(localized: "/month"))
            if Self.showsLifetime {
                planRow(.lifetime,
                        title: String(localized: "Lifetime"),
                        detail: String(localized: "Pay once, keep it forever."),
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
                    Text("Start 30-day free trial").frame(maxWidth: .infinity)
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

            Text("Development build: buttons unlock locally and do not charge anything.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    private var buyTitle: String {
        if Self.freeDuringDevelopment { return String(localized: "Subscribe (free during development)") }
        return selected == .monthly
            ? String(format: String(localized: "Subscribe %@ / month"), Self.monthlyPrice)
            : String(format: String(localized: "Buy once for %@"), Self.lifetimePrice)
    }

    // MARK: - 元件

    /// 所有卡片都撐滿整個寬度，左右邊才對得齊。
    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) { content() }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground),
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
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isOn ? Color.accentColor : Color.clear, lineWidth: 2))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("paywall.plan.\(plan.rawValue)")
    }
}
