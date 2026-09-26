# PicDeck device updates

After changing the PicDeck app, build and install the latest app on all three development targets before handing work back:

- iPhone 18 Pro simulator: `609C7D8C-52C7-4AED-AB7C-DF5ADE289D0D`
- iPhone 14 Pro Max simulator: `A6068813-D220-4272-B019-9DAA57BE0934`
- Physical iPhone 14 Pro Max: `00008120-0001241C01EB401E`

Use bundle ID `com.picdeck.app`. Preserve app data; do not erase, uninstall, or reset a device to update. Build the simulator and physical-device variants as needed. Install and launch on the simulators; install on the physical phone when connected and available. If a device is unavailable or locked, complete the other installations and report the exact remaining step. Do not wait for a confirmation to perform this routine update.

Verify each change automatically with a build and focused checks appropriate to the change. For visual layout changes, inspect both simulator sizes and both appearance modes when relevant. The user has authorized this routine verification and device update without a new confirmation each time.

## 功能規範查閱與修改確認機制（鐵律）

1. **先查規範再動工**：
   - 專案的完整功能、位置、操作手勢與模式定義詳見 `docs/product/PicDeck功能與操作規範.md`。
   - 任何程式碼修改或新功能實作前，**必須先比對該規範文件**，確保既有行為與手勢邏輯不被破壞。
2. **變更確認機制**：
   - 當使用者提出修改或新做法時，若牽涉到既有功能、操作流程或模式手勢的變動，**必須主動向使用者確認是否要同步調整規範文件**，獲得確認後方可執行並更新規範。

## 單圖檢視（`PhotoDetailView`）核心不變規範（嚴禁破壞）

1. **手勢分層與資訊面板（Inspector）收合鐵律**：
   - 當資訊面板（`PhotoInspectorPanelView`）處於展開狀態時，使用者手指在**面板頂部把手（Capsule 位置 1）或面板內部向下滑動，必須「僅收起／關閉資訊面板」，絕對不可關閉整個單圖檢視（嚴禁 dismiss 單圖）**。
   - 頂部把手與面板頂部區域必須採用 `highPriorityGesture` 或明確手勢攔截，防止被外層父視圖手勢或系統的互動式退出手勢（如 iOS 18 zoomDestination）攔截吃掉。
   - **僅有在資訊面板已收合狀態下**，使用者在照片區域向下滑動超過閥值（> 110pt），才可關閉單圖全螢幕檢視。
2. **模組統一性**：
   - 全專案點擊單張照片的入口（選集、標籤、相簿、照片、日記、整理）一律使用同一 `PhotoDetailView` 模組，完整提供「資訊、標籤、相簿、喜愛、刪除」。
3. **色彩模式與全域保護**：
   - 單圖檢視（`PhotoDetailView`）與所有全螢幕視圖全面跟隨使用者的外觀模式（淺色模式下為淺色背景與深色圖文；深色模式下為沉浸深色背景）。
   - **嚴禁在任何單圖、Modal、Sheet 或全螢幕視圖中使用 `.preferredColorScheme(.dark)`**，避免污染全域 `UIWindow` 造成淺色模式閃黑、變暗或色彩錯亂。

## 照片「全部（.all）」檢視核心不變規範（嚴禁破壞）

1. **定位與排序鐵律**：
   - 「全部」模式下最新照片固定在最下方。
   - 當照片超過一頁時，預設定位必須保持在最新照片（底部），切換至全部時必須精確對齊最新照片。
   - **不滿一頁頂部對齊規範**：當照片數量較少、總高度不足一頁時，自動取消底部錨定，自頂部標題下方起自然排列，下方留黑（與原生「照片.app」一致），嚴禁將不足一頁的照片推至底部。
2. **禁止銷毀與重建（防止黑屏）**：
   - `PhotosTabView` 必須使用 `ZStack` 搭配 `opacity` 與 `allowsHitTesting` 來保留 `allGridContent`（`CompactGridView`）在 View Hierarchy 中。
   - **嚴禁**改回使用 `if scale == .all { allGridContent }`。若銷毀重建，iOS 的 `LazyVGrid` 在尚未完成排版時進行底部定位會導致視圖一片漆黑、需手動滑動才出圖。
   - 任何改動不得更動此生命週期與底部錨定架構。

## UI 卡頓排查優先順序

遇到 PicDeck 卡頓時，先沿著卡頓互動路徑檢查 UI 主執行緒是否同步執行整個相簿的排序、篩選、日期／屬性讀取、分組、索引建置或大型集合轉換，以及狀態變更或快速手勢是否造成重複全量工作。優先將非 UI 批次計算移至可取消的背景任務，取消過期重建，對高頻輸入適量 debounce，並在大量資料的導覽索引評估加權取樣或分段快取。以 Instruments 在實機確認瓶頸後再改動，避免未量測就大幅重構；縮圖路徑另確認 PhotoKit 請求可取消、清晰結果處理與 continuation 完成狀態。完成修正後，依本檔裝置更新規範建置、安裝及驗證。
