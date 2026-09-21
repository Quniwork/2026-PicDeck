# PicDeck AppIcon 與深淺佈景安裝指令

此資料夾包含：

- `AppIcon.appiconset/AppIcon-Light.png`：預設／淺色圖示，1024×1024、無 Alpha。
- `AppIcon.appiconset/AppIcon-Dark.png`：深色圖示，1024×1024、透明背景。
- `AppIcon.appiconset/AppIcon-Tinted.png`：Tinted 圖示，1024×1024、灰階透明背景。
- `AppIcon.appiconset/Contents.json`：iOS Single Size AppIcon 設定。
- `PicDeck-Foreground-Transparent.png`：可匯入 Icon Composer 的透明前景圖。

## 使用方式

1. 將整個 `PicDeck-AppIcons` 資料夾放到 Xcode 專案根目錄，與 `.xcodeproj` 或 `.xcworkspace` 同一層。
2. 在 Terminal 切換到專案根目錄。
3. 執行 `claude`。
4. 將下方「給 Claude CLI 的完整指令」整段貼入。

## 給 Claude CLI 的完整指令

```text
你正在修改目前目錄中的 PicDeck iOS／Xcode 專案。請先檢查專案結構，再完成 App icon 與深淺佈景支援。來源圖片位於：

./PicDeck-AppIcons/AppIcon.appiconset/AppIcon-Light.png
./PicDeck-AppIcons/AppIcon.appiconset/AppIcon-Dark.png
./PicDeck-AppIcons/AppIcon.appiconset/AppIcon-Tinted.png

工作要求：

1. 找出實際使用的 `.xcworkspace` 或 `.xcodeproj`、主要 App target、Assets.xcassets，以及 build setting `ASSETCATALOG_COMPILER_APPICON_NAME` 指向的 AppIcon set。不要猜路徑。
2. 在修改前讀取現有 `AppIcon.appiconset/Contents.json`。保留 macOS、watchOS、visionOS、舊版尺寸或其他 target 所需的既有 entries，不要刪除無關設定。
3. 將三張圖片複製進實際使用的 AppIcon set，檔名維持：
   - `AppIcon-Light.png`
   - `AppIcon-Dark.png`
   - `AppIcon-Tinted.png`
4. 若專案使用 iOS Single Size AppIcon，將 iOS universal 1024×1024 entries 設為：
   - Light／Any：無 `appearances`
   - Dark：`appearance = luminosity`、`value = dark`
   - Tinted：`appearance = luminosity`、`value = tinted`
5. 若現有 asset catalog 格式不是 Single Size，請採用與目前 Xcode 版本相容的合併方式，不要整份覆蓋 `Contents.json`；完成後說明你實際採用的格式。
6. 驗證圖片：三張都是 1024×1024；Light 必須完全不透明；Dark 可保留透明背景；Tinted 必須是灰階且可保留透明背景。
7. 檢查 App 是否為 SwiftUI：
   - 若是 SwiftUI，新增或整合 `AppTheme` 三種模式：`system`、`light`、`dark`。
   - 使用既有設定架構；若沒有，再使用 `@AppStorage("appTheme")` 保存選擇。
   - 在 App 根視圖套用 `.preferredColorScheme(...)`；`system` 必須回傳 `nil`，讓畫面跟隨裝置設定。
   - 主要頁面背景使用 `Color(uiColor: .systemBackground)`，次層卡片優先使用 `Color(uiColor: .secondarySystemBackground)`，文字使用 `.primary`／`.secondary`。
   - 不要把背景寫死為 `.white` 或 `.black`。
8. 若是 UIKit，使用 `UIColor.systemBackground`、`UIColor.secondarySystemBackground`、`UIColor.label`，並依現有設定架構實作 system／light／dark；不要同時再建立一套 SwiftUI 主題系統。
9. 若專案已有主題設定，請整合進現有實作，不要建立重複的 Settings 頁面、資料模型或 AppStorage key。
10. 不要修改圖片內容、商業邏輯、Bundle Identifier、簽章、Deployment Target、套件版本或無關檔案。
11. 完成後先用 `xcodebuild -list` 找出正確 scheme；優先使用 workspace（若存在），再以 iOS Simulator、Debug、`CODE_SIGNING_ALLOWED=NO` 執行一次 build 驗證。
12. 若 build 失敗，先判斷是否為本次修改造成。只修正與 AppIcon／主題相關的錯誤；既有且無關的錯誤只需列出，不要擴大修改範圍。
13. 最後回報：
   - 修改的完整檔案清單
   - AppIcon set 的實際路徑
   - Light／Dark／Tinted 是否都正確登錄
   - 主題切換放在哪個畫面
   - build 指令與結果
   - 仍需要我在 Xcode 或實機手動確認的項目
```

## Claude CLI 建議驗證重點

- 模擬器切換「設定 → 顯示與亮度」時，選擇「跟隨系統」的 PicDeck 應同步改變。
- PicDeck 內手動選擇淺色或深色後，重開 App 仍保留選擇。
- 長按 iPhone 主畫面並切換 App icon 的 Light、Dark、Tinted 外觀，三種圖示都應清楚可辨識。
- App Store 用的 Light 圖示不可含透明像素；Dark 與 Tinted 則依 Apple 現行規則保留透明／灰階版本。
