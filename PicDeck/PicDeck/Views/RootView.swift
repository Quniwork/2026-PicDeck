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

/// 底部五個分頁：照片、資料夾、整理、更多。地圖之後再加。
struct MainTabView: View {
    var body: some View {
        TabView {
            PhotosTabView()
                .tabItem { Label("Photos", systemImage: "square.grid.2x2") }

            AlbumsTabView()
                .tabItem { Label("Folders", systemImage: "folder") }

            OrganizeTabView()
                .tabItem { Label("Organize", systemImage: "rectangle.stack") }

            MoreTabView()
                .tabItem { Label("More", systemImage: "line.3.horizontal") }
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
