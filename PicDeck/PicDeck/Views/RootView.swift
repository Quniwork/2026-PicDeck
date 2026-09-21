import SwiftUI
import Photos

struct RootView: View {
    @EnvironmentObject private var library: PhotoLibraryService
    @EnvironmentObject private var model: AppModel

    var body: some View {
        Group {
            if library.isAuthorized {
                MainTabView()
            } else {
                PermissionView()
            }
        }
        .task {
            library.refreshAuthorizationStatus()
        }
    }
}

/// 底部四個分頁：首頁、照片、整理、更多。地圖之後再加。
struct MainTabView: View {
    @EnvironmentObject private var model: AppModel

    /// 分頁列裡的房子比其他圖標看起來大，用小一點的字重畫成圖片。
    private static let smallHouse: UIImage = {
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        return (UIImage(systemName: "house.fill", withConfiguration: config) ?? UIImage())
            .withRenderingMode(.alwaysTemplate)
    }()

    var body: some View {
        TabView(selection: $model.selectedTab) {
            HomeView()
                .tabItem { Label { Text("Home") } icon: { Image(uiImage: Self.smallHouse) } }
                .tag(0)

            JournalTabView()
                .tabItem { Label("Journal", systemImage: "book") }
                .tag(1)

            PhotosTabView()
                .tabItem { Label("Photos", systemImage: "photo.on.rectangle") }
                .tag(2)

            OrganizeTabView()
                .tabItem { Label("Organize", systemImage: "tray.full") }
                .tag(3)

            MoreTabView()
                .tabItem { Label("More", systemImage: "line.3.horizontal.circle.fill") }
                .tag(4)
        }
    }
}

struct PermissionView: View {
    @EnvironmentObject private var library: PhotoLibraryService

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            Text("PicDeck needs photo access")
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)

            Text("Everything happens on your device. PicDeck never uploads your photos.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if library.authorizationStatus == .denied || library.authorizationStatus == .restricted {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Allow Photo Access") {
                    Task { await library.requestAuthorization() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
