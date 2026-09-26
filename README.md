# PicDeck（相牌）

[![iOS 17+](https://img.shields.io/badge/iOS-17.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org/)
[![PhotoKit](https://img.shields.io/badge/PhotoKit-Native-green.svg)](https://developer.apple.com/documentation/photokit)

**PicDeck** 是一款專為 iPhone 打造的高效率相簿整理與生活回憶圖文 App。結合卡牌式直覺滑動、網格多選連選、日記圖文生活記錄、智慧標籤相簿分類，以及與系統「照片.app」的深度雙向同步。

---

## 跨 AI 開發工具指引（Multi-Agent Guidelines）

本專案支援多款 AI 輔助開發工具（Gemini Antigravity、Claude Code、Codex、Cursor 等）無縫切換：

- **Claude Code 專用**：請自動讀取根目錄 [`CLAUDE.md`](CLAUDE.md)
- **Gemini / 通用代理專用**：請自動讀取根目錄 [`AGENTS.md`](AGENTS.md)
- **Codex / Cursor / Windsurf 專用**：請自動讀取根目錄 [`.cursorrules`](.cursorrules)
- **專案最高規範準則（SSOT）**：任何功能實作或手勢修改**必須優先查閱** [`docs/product/PicDeck功能與操作規範.md`](docs/product/PicDeck功能與操作規範.md)
- **完整文件索引中心**：詳見 [`docs/README.md`](docs/README.md)

---

## 核心功能架構（五大主分頁）

```
[ 日記 ]  [ 選集 ]  [ 照片 ]  [ 整理 ]  [ 更多 ]
```

1. **日記（Journal）**：
   - 依日期時間由近到遠分組的生活圖文紀錄。
   - 支援心情 Emoji、分類標籤、關聯照片橫向預覽。
2. **選集（Collection）**：
   - 精選回憶、那年今天、自訂標籤集與相簿分類瀏覽。
3. **照片（Photos）**：
   - **時間軸（Timeline）**：依年、月、日結構化縮放瀏覽，右側配有 Scrubber 快速滑動桿。
   - **全部（All）**：滿版網格檢視，最新照片固定在底部（採用 ZStack 常駐架構防止黑屏）。
   - **滑動連選整排（SwipeToSelect）**：手指一滑跨欄連續多選，打勾狀態固定在相片右下角。
4. **整理（Organize）**：
   - **卡片滑動清理模式（ReviewSessionView）**：左滑保留、上滑待刪除、下拉喜愛、右滑回上一張。
   - **柵欄整理模式（OrganizeGridView）**：批次網格連選，底部操作列「標籤」與「相簿」展開水平快速膠囊列（QuickAssetChipsBar），不跳出彈窗。
   - **安全待刪除清單（PendingTrashView）**：暫存待刪照片，支援一鍵全選復原或永久刪除。
5. **更多（More）**：
   - 外觀模式（淺色／深色／跟隨系統）、iCloud 雙軌同步與自動備份、自訂 App 圖示、Paywall。

---

## 核心設計規範（不可妥協原則）

1. **單圖檢視（`PhotoDetailView`）全專案共用**：
   - 點開單張照片的入口一律使用同一模組。
   - **資訊面板手勢分層**：資訊面板展開時，頂部把手向下滑動**僅收起資訊面板，絕對不可關閉單圖**；只有面板收合時在照片下滑才關閉單圖。
   - **照片直角呈現**：外層底板維持圓角（RoundedRectangle），中央相片與影片本體一律以俐落直角呈現。
2. **全域外觀保護**：
   - 單圖檢視與所有全螢幕視圖全面跟隨外觀模式。
   - 嚴禁使用 `.preferredColorScheme(.dark)` 覆蓋全域 `UIWindow`。
3. **與系統「照片.app」深度整合**：
   - 所有刪除、喜愛、歸檔皆寫回系統相簿。
   - 照片「備註」與系統「照片.app」的「說明（Caption）」欄位達成**雙向同步**。

---

## 開發環境與目標設備

### 系統環境
- **Xcode**：Xcode 16 / 27，相容 iOS 17.0+
- **Bundle Identifier**：`com.picdeck.app`
- **專案路徑**：`/Library/WebServer/Documents/photo-app/PicDeck`

### 三大必測驗證裝置（每次修改自動部署）
- **iPhone 18 Pro 模擬器**：`609C7D8C-52C7-4AED-AB7C-DF5ADE289D0D`
- **iPhone 14 Pro Max 模擬器**：`A6068813-D220-4272-B019-9DAA57BE0934`
- **實體 iPhone 14 Pro Max**：`00008120-0001241C01EB401E`

---

## 常用指令速查

```bash
# 切換至專案目錄
cd /Library/WebServer/Documents/photo-app/PicDeck

# 模擬器建置
xcodebuild -scheme PicDeck -destination "id=609C7D8C-52C7-4AED-AB7C-DF5ADE289D0D" -derivedDataPath build_sim build

# 模擬器安裝與啟動
xcrun simctl install 609C7D8C-52C7-4AED-AB7C-DF5ADE289D0D build_sim/Build/Products/Debug-iphonesimulator/PicDeck.app
xcrun simctl launch 609C7D8C-52C7-4AED-AB7C-DF5ADE289D0D com.picdeck.app

# 實體機建置與安裝
xcodebuild -scheme PicDeck -destination "id=00008120-0001241C01EB401E" -derivedDataPath build_device build
xcrun devicectl device install app --device 00008120-0001241C01EB401E build_device/Build/Products/Debug-iphoneos/PicDeck.app
```

---

## 文件地圖（Documentation Map）

詳細文件索引與分類請參閱 [`docs/README.md`](docs/README.md)。
- **功能與操作規範手冊**：[`docs/product/PicDeck功能與操作規範.md`](docs/product/PicDeck功能與操作規範.md)
- **真機安裝與測試指南**：[`docs/dev/真機安裝與測試指南.md`](docs/dev/真機安裝與測試指南.md)
- **桌面模擬器與 Demo 指南**：[`docs/dev/測試與Demo指南.md`](docs/dev/測試與Demo指南.md)
- **TestFlight 測試發布指南**：[`docs/dev/TestFlight測試指南.md`](docs/dev/TestFlight測試指南.md)
- **商業化方案建議書**：[`docs/product/PicDeck 上架前商業化與計費方案調整建議書.md`](docs/product/PicDeck%20上架前商業化與計費方案調整建議書.md)
