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
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var model: AppModel

    @ViewBuilder
    var body: some View {
        if #available(iOS 26.1, *) {
            tabs
                .tabBarMinimizeBehavior(.onScrollDown)
                .tabViewBottomAccessory(isEnabled: model.selectedTab == 2 && !model.isSelectingPhotos) {
                    PhotosTabAccessory(appColorScheme: colorScheme)
                }
        } else if #available(iOS 26.0, *) {
            tabs
                .tabBarMinimizeBehavior(.onScrollDown)
                .tabViewBottomAccessory {
                    if model.selectedTab == 2 && !model.isSelectingPhotos {
                        PhotosTabAccessory(appColorScheme: colorScheme)
                    }
                }
        } else {
            tabs
        }
    }

    private var tabs: some View {
        // 順序：日記、選集、照片、整理、更多。預設開在日記。
        TabView(selection: $model.selectedTab) {
            JournalTabView()
                .tabItem { Label("Journal", systemImage: "book") }
                .tag(0)

            HomeView()
                .tabItem { Label("Collections", systemImage: "photo.stack") }
                .tag(1)

            PhotosTabView(appColorScheme: colorScheme)
                .tabItem { Label("Photos", systemImage: "photo.on.rectangle") }
                .tag(2)

            OrganizeTabView()
                .tabItem { Label("Organize", systemImage: "tray.fill") }
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
