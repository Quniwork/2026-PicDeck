import SwiftUI

/// 30 秒手勢教學，首次啟動時出現。
struct TutorialView: View {
    let onFinish: () -> Void

    @State private var page = 0

    private let pages: [TutorialPage] = [
        TutorialPage(systemImage: "arrow.left",
                     title: "Swipe left to keep",
                     detail: "Marks the photo as organized so it stops showing up in your unorganized list.",
                     tint: .green),
        TutorialPage(systemImage: "arrow.up",
                     title: "Swipe up to delete",
                     detail: "It only marks the photo. Nothing is deleted until you confirm in Trash.",
                     tint: .red),
        TutorialPage(systemImage: "arrow.down",
                     title: "Pull down to favorite",
                     detail: "Syncs straight to the Favorites album in iOS Photos.",
                     tint: .pink),
        TutorialPage(systemImage: "arrow.right",
                     title: "Swipe right to go back",
                     detail: "Changed your mind? Swipe right to undo the last action and return to the previous photo.",
                     tint: .accentColor),
        TutorialPage(systemImage: "folder",
                     title: "Tap an album to file it",
                     detail: "Filing a photo into an album also marks it as organized.",
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
                    Text(page < pages.count - 1 ? "Next" : "Start organizing")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("Skip") { onFinish() }
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
