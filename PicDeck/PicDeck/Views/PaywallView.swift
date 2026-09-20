import SwiftUI

/// v0.1 的付費頁：價格與權益照企劃書呈現，購買為本機模擬，尚未接 StoreKit。
struct PaywallView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unlock PicDeck")
                            .font(.largeTitle.weight(.bold))
                        Text("One payment. No subscription.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        benefitRow(systemImage: "infinity",
                                   title: "No daily limit",
                                   detail: "The free plan handles 30 photos a day.")
                        benefitRow(systemImage: "line.3.horizontal.decrease.circle",
                                   title: "All filters",
                                   detail: "Favorites, Photos, Videos and Screenshots.")
                        benefitRow(systemImage: "tag",
                                   title: "Filter by your tags",
                                   detail: "Tagging stays free; filtering by tag needs the unlock.")
                        benefitRow(systemImage: "square.and.pencil",
                                   title: "Journal",
                                   detail: "Write a mood and a note for each day.")
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground),
                                in: RoundedRectangle(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Pricing")
                            .font(.headline)
                        priceRow(stage: "Development sponsor", price: "NT$99", highlighted: true)
                        priceRow(stage: "Early bird", price: "NT$249", highlighted: false)
                        priceRow(stage: "At launch", price: "NT$499", highlighted: false)
                        Text("You are in the development phase, so today's price is the sponsor price.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground),
                                in: RoundedRectangle(cornerRadius: 14))

                    Button {
                        model.unlock()
                        dismiss()
                    } label: {
                        Text("Sponsor for NT$99")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Text("Development build: this button unlocks locally and does not charge anything.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
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
        }
    }

    private func priceRow(stage: LocalizedStringKey, price: String, highlighted: Bool) -> some View {
        HStack {
            Text(stage)
                .font(.subheadline)
                .foregroundStyle(highlighted ? .primary : .secondary)
            Spacer()
            Text(price)
                .font(.subheadline.weight(highlighted ? .bold : .regular))
                .foregroundStyle(highlighted ? Color.accentColor : .secondary)
        }
    }
}
