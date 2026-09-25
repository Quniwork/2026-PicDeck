import SwiftUI

/// 30 秒手勢教學，首次啟動時出現。
struct TutorialView: View {
    let onFinish: () -> Void

    @State private var page = 0

    private let pages: [TutorialPage] = [
        TutorialPage(systemImage: "arrow.left",
                     title: "向左滑動：保留相片",
                     detail: "標記為已整理，未來不再出現在待整理列表中。",
                     tint: .green),
        TutorialPage(systemImage: "arrow.up",
                     title: "向上滑動：標記刪除",
                     detail: "僅先移至待刪除清單，在垃圾桶確認之前不會真正刪除照片。",
                     tint: .red),
        TutorialPage(systemImage: "arrow.down",
                     title: "向下滑動：加入喜愛",
                     detail: "直接同步加入至 iOS 系統內建的「喜好項目」相簿。",
                     tint: .pink),
        TutorialPage(systemImage: "arrow.right",
                     title: "向右滑動：返回上張",
                     detail: "改變主意了嗎？向右滑動即可復原上個動作並回到上一張照片。",
                     tint: .accentColor),
        TutorialPage(systemImage: "folder",
                     title: "點擊相簿：快速歸檔",
                     detail: "將照片直接加入指定相簿，同時自動標記為已整理完成。",
                     tint: .accentColor)
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 20) {
                        Image(systemName: item.systemImage)
                            .font(.system(size: 64, weight: .semibold))
                            .foregroundStyle(item.tint)
                            .frame(height: 100)

                        Text(item.title)
                            .font(.title2.weight(.semibold))
                            .multilineTextAlignment(.center)

                        Text(item.detail)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            VStack(spacing: 12) {
                Button {
                    if page < pages.count - 1 {
                        withMotion { page += 1 }
                    } else {
                        onFinish()
                    }
                } label: {
                    Text(page < pages.count - 1 ? "下一步" : "開始整理照片")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("略過教學") { onFinish() }
                    .font(.footnote)
            }
            .padding(24)
        }
        .background(Color(.systemBackground))
    }
}

struct TutorialPage {
    let systemImage: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey
    let tint: Color
}
