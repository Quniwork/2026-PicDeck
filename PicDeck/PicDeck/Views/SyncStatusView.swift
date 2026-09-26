import SwiftUI
import Photos

// MARK: - 同步狀態卡片（MoreTabView 頂部）

/// 顯示 iOS 版本感知的同步狀態。
/// iOS 27+ 顯示「全功能同步中」；iOS 26 以下顯示「功能受限」提示。
struct SyncStatusCard: View {
    @State private var showDetail = false

    private var isFullSync: Bool {
        if #available(iOS 27.0, *) { return true }
        return false
    }

    var body: some View {
        Button { showDetail = true } label: {
            HStack(spacing: 12) {
                // 狀態圖示
                ZStack {
                    Circle()
                        .fill(isFullSync ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: isFullSync ? "checkmark.icloud" : "exclamationmark.icloud")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(isFullSync ? .green : .orange)
                }

                VStack(alignment: .leading, spacing: 2) {
                    if isFullSync {
                        Text("全功能同步中")
                            .font(.subheadline.weight(.semibold))
                        Text("說明、關鍵字、相簿均已與系統同步")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("同步功能受限")
                            .font(.subheadline.weight(.semibold))
                        Text("升級至 iOS 27 可解鎖說明與關鍵字同步")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetail) {
            SyncStatusDetailView()
        }
    }
}

// MARK: - 同步狀態詳情頁

struct SyncStatusDetailView: View {
    @Environment(\.dismiss) private var dismiss

    private var isFullSync: Bool {
        if #available(iOS 27.0, *) { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: 同步能力總覽
                Section("系統同步能力") {
                    SyncCapabilityRow(
                        title: "照片說明（Caption）",
                        icon: "text.quote",
                        available: isFullSync
                    )
                    SyncCapabilityRow(
                        title: "照片關鍵字（Keywords）",
                        icon: "key.horizontal",
                        available: isFullSync
                    )
                    SyncCapabilityRow(
                        title: "系統相簿",
                        icon: "rectangle.stack",
                        available: true
                    )
                }

                Section("同步機制說明") {
                    VStack(alignment: .leading, spacing: 10) {
                        Label {
                            Text("照片說明（Caption）與 PicDeck 備註保持即時雙向同步。")
                                .font(.footnote)
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }

                        Label {
                            Text("系統照片的關鍵字會顯示於單圖資訊面板「關鍵字(系統建立)」中，不會自動污染 PicDeck 的標籤列表；您可隨時在該照片上將其轉為正式標籤。")
                                .font(.footnote)
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }

                        if !isFullSync {
                            Label {
                                Text("目前系統版本低於 iOS 27，說明與關鍵字同步功能受限。")
                                    .font(.footnote)
                            } icon: {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("同步狀態")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

// MARK: - 輔助子視圖

private struct SyncCapabilityRow: View {
    let title: String
    let icon: String
    let available: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(available ? .primary : .tertiary)
                .frame(width: 20)
            Text(title)
            Spacer()
            Label(
                available ? "已啟用" : "需 iOS 27",
                systemImage: available ? "checkmark.circle.fill" : "exclamationmark.circle"
            )
            .labelStyle(.titleAndIcon)
            .font(.caption.weight(.medium))
            .foregroundStyle(available ? .green : .orange)
        }
    }
}
