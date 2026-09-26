# PicDeck 開發規範與 AI 代理指引（Claude Code 專用）

> **最高原則**：本檔案為 Claude Code 進入 PicDeck 專案時的權威指引。所有回答與註解**一律使用繁體中文（Traditional Chinese）**。

---

## 零、功能規範查閱與修改確認機制（鐵律）

1. **先查規範再動工**：
   - 專案的完整功能、位置、操作手勢與模式定義詳見：[`docs/product/PicDeck功能與操作規範.md`](docs/product/PicDeck功能與操作規範.md)。
   - 任何程式碼修改或新功能實作前，**必須先比對該規範文件**，確保既有行為與手勢邏輯不被破壞。
2. **變更確認機制**：
   - 當使用者提出修改或新做法時，若牽涉到既有功能、操作流程或模式手勢的變動，**必須主動向使用者確認是否要同步調整規範文件**，獲得確認後方可執行並更新規範。

---

## 一、三台開發目標設備部署規範（必備流程）

每次變更 PicDeck 程式碼後，**必須在交差前回報前自動建置並安裝至以下三台裝置進行驗證**（保留 App 既有資料，不可清除或重置）：

- **iPhone 18 Pro 模擬器**：`609C7D8C-52C7-4AED-AB7C-DF5ADE289D0D`
- **iPhone 14 Pro Max 模擬器**：`A6068813-D220-4272-B019-9DAA57BE0934`
- **實體 iPhone 14 Pro Max**：`00008120-0001241C01EB401E`

### 常用建置與安裝指令

```bash
# 1. 模擬器建置（於 PicDeck 目錄下執行）
cd /Library/WebServer/Documents/photo-app/PicDeck
xcodebuild -scheme PicDeck -destination "id=609C7D8C-52C7-4AED-AB7C-DF5ADE289D0D" -derivedDataPath build_sim build

# 2. 安裝並啟動至兩台模擬器
xcrun simctl install 609C7D8C-52C7-4AED-AB7C-DF5ADE289D0D build_sim/Build/Products/Debug-iphonesimulator/PicDeck.app
xcrun simctl launch 609C7D8C-52C7-4AED-AB7C-DF5ADE289D0D com.picdeck.app

xcrun simctl install A6068813-D220-4272-B019-9DAA57BE0934 build_sim/Build/Products/Debug-iphonesimulator/PicDeck.app
xcrun simctl launch A6068813-D220-4272-B019-9DAA57BE0934 com.picdeck.app

# 3. 實體機建置
xcodebuild -scheme PicDeck -destination "id=00008120-0001241C01EB401E" -derivedDataPath build_device build

# 4. 安裝至實體機（若裝置鎖定請回報剩餘步驟）
xcrun devicectl device install app --device 00008120-0001241C01EB401E build_device/Build/Products/Debug-iphoneos/PicDeck.app
```

---

## 二、專案架構概覽

- **專案路徑**：`/Library/WebServer/Documents/photo-app/PicDeck`
- **Bundle ID**：`com.picdeck.app`
- **系統需求**：iOS 17.0+
- **架構特點**：SwiftUI + PhotoKit（純本機相片處理，無伺服器，所有歸檔與刪除同步回系統照片庫）。
- **五大主分頁（Tabs）**：
  1. **日記（Journal）**：生活圖文記錄、關聯相片、心情與分類。
  2. **選集（Collection）**：精選、那年今天、標籤集、自訂相簿分類。
  3. **照片（Photos）**：「時間軸（Timeline）」與「全部（All）」雙檢視，支援滑動連選整排照片（`SwipeToSelect`）。
  4. **整理（Organize）**：
     - 卡片滑動清理（`ReviewSessionView`）：左滑保留、上滑待刪除、下拉喜愛。
     - 柵欄整理模式（`OrganizeGridView`）：批次網格連選，底部操作列點擊「標籤」或「相簿」在上方水平展開快速膠囊列（`QuickAssetChipsBar`，無彈窗）。
  5. **更多（More）**：外觀模式、iCloud 雙軌同步與自動備份、自訂 App 圖示、Paywall。

---

## 三、核心不變規範（嚴禁破壞）

1. **單圖檢視（`PhotoDetailView`）手勢分層鐵律**：
   - 資訊面板（`PhotoInspectorPanelView`）展開時，使用者在面板頂部把手（Capsule）或內部向下滑動，**必須「僅收起資訊面板」，絕對不可關閉單圖檢視（嚴禁 dismiss 單圖）**。
   - 僅在資訊面板已收合狀態下，照片區域向下滑動超過閥值（> 110pt）才關閉單圖全螢幕檢視。
2. **中央照片直角呈現與底板圓角**：
   - 照片外層的容器底板卡片維持優雅圓角（`RoundedRectangle`）。
   - 中央顯示的相片與影片本體一律以直角呈現（無 `clipShape(RoundedRectangle)`），真實呈現相片原始直角邊界。
3. **全域外觀模式保護**：
   - 單圖檢視全面跟隨使用者的外觀模式。
   - **嚴禁在任何單圖、Modal、Sheet 或全螢幕視圖中使用 `.preferredColorScheme(.dark)`**，避免污染全域 `UIWindow` 造成淺色模式閃黑或變暗。
4. **照片「全部（.all）」檢視生命週期**：
   - `PhotosTabView` 必須使用 `ZStack` 搭配 `opacity` 與 `allowsHitTesting` 來保留 `allGridContent`（`CompactGridView`）在 View Hierarchy 中，最新照片固定在最下方。
   - **嚴禁改回使用 `if scale == .all { allGridContent }`**，避免 LazyVGrid 銷毀重建導致黑屏。
5. **備註（Note）與照片.app 說明（Caption）雙向同步與防抖**：
   - 備註輸入使用本地防抖（Debounce 800ms）及焦點/關閉事件儲存，嚴禁每字即時寫入 Store 造成 UI 卡頓。
   - 支援讀取與同步寫入系統「照片.app」的說明欄位（`PHAssetChangeRequest.caption`）。
