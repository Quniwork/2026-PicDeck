import SwiftUI
import Photos

@MainActor
final class PhotosSelectionAccessory: ObservableObject {
    @Published var selectedCount = 0
    @Published var allAreFavorites = false
    var onTags: (() -> Void)?
    var onAlbum: (() -> Void)?
    var onFavorite: (() -> Void)?
    var onDelete: (() -> Void)?
}

struct PhotosSelectionAccessoryBar: View {
    @ObservedObject var accessory: PhotosSelectionAccessory

    var body: some View {
        ActionBarRow {
            ActionBarButton(key: "標籤", icon: "tag", id: "batch.tags", iconOnly: false) {
                accessory.onTags?()
            }
            Spacer(minLength: 4)
            ActionBarButton(key: "相簿", icon: "rectangle.stack.badge.plus", id: "batch.album", iconOnly: false) {
                accessory.onAlbum?()
            }
            Spacer(minLength: 4)
            ActionBarButton(key: accessory.allAreFavorites ? "取消喜愛" : "喜愛",
                            icon: accessory.allAreFavorites ? "heart.slash" : "heart",
                            id: "batch.favorite", iconOnly: false) {
                accessory.onFavorite?()
            }
            Spacer(minLength: 4)
            ActionBarButton(key: "刪除", icon: "xmark", id: "batch.delete", isDestructive: true, iconOnly: false) {
                accessory.onDelete?()
            }
        }
        .disabled(accessory.selectedCount == 0)
        .padding(.vertical, 8)
        .modifier(SelectionBarSurface())
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, PageMetrics.edge)
        .padding(.vertical, 6)
    }
}

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
    @StateObject private var selectionAccessory = PhotosSelectionAccessory()

    @ViewBuilder
    var body: some View {
        if #available(iOS 26.1, *) {
            tabs
                .environmentObject(selectionAccessory)
                .tabBarMinimizeBehavior(.onScrollDown)
                .tabViewBottomAccessory(isEnabled: model.selectedTab == 2) {
                    photoBottomAccessory
                }
        } else if #available(iOS 26.0, *) {
            tabs
                .environmentObject(selectionAccessory)
                .tabBarMinimizeBehavior(.onScrollDown)
                .tabViewBottomAccessory {
                    if model.selectedTab == 2 {
                        photoBottomAccessory
                    }
                }
        } else {
            tabs.environmentObject(selectionAccessory)
        }
    }

    @available(iOS 26.0, *)
    @ViewBuilder
    private var photoBottomAccessory: some View {
        if model.isSelectingPhotos {
            PhotosSelectionAccessoryBar(accessory: selectionAccessory)
        } else {
            PhotosTabAccessory(appColorScheme: colorScheme)
        }
    }

    private var tabs: some View {
        // 順序：日記、選集、照片、整理、更多。預設開在日記。
        TabView(selection: $model.selectedTab) {
            JournalTabView()
                .tabItem { Label("日記", systemImage: "book") }
                .tag(0)

            HomeView()
                .tabItem { Label("選集", systemImage: "photo.stack") }
                .tag(1)

            PhotosTabView(appColorScheme: colorScheme)
                .tabItem { Label("照片", systemImage: "photo.on.rectangle") }
                .tag(2)

            OrganizeTabView()
                .tabItem { Label("整理", systemImage: "tray.fill") }
                .tag(3)

            MoreTabView()
                .tabItem { Label("更多", systemImage: "line.3.horizontal.circle.fill") }
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

            Text("PicDeck 需要存取您的照片庫")
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)

            Text("所有操作均在本機端完成，PicDeck 絕不會上傳您的任何照片。")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if library.authorizationStatus == .denied || library.authorizationStatus == .restricted {
                Button("前往「設定」開啟權限") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("允許相片存取權限") {
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
