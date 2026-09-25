# PicDeck device updates

After changing the PicDeck app, build and install the latest app on all three development targets before handing work back:

- iPhone 18 Pro simulator: `609C7D8C-52C7-4AED-AB7C-DF5ADE289D0D`
- iPhone 14 Pro Max simulator: `A6068813-D220-4272-B019-9DAA57BE0934`
- Physical iPhone 14 Pro Max: `00008120-0001241C01EB401E`

Use bundle ID `com.picdeck.app`. Preserve app data; do not erase, uninstall, or reset a device to update. Build the simulator and physical-device variants as needed. Install and launch on the simulators; install on the physical phone when connected and available. If a device is unavailable or locked, complete the other installations and report the exact remaining step. Do not wait for a confirmation to perform this routine update.

Verify each change automatically with a build and focused checks appropriate to the change. For visual layout changes, inspect both simulator sizes and both appearance modes when relevant. The user has authorized this routine verification and device update without a new confirmation each time.

## UI 卡頓排查優先順序

遇到 PicDeck 卡頓時，先沿著卡頓互動路徑檢查 UI 主執行緒是否同步執行整個相簿的排序、篩選、日期／屬性讀取、分組、索引建置或大型集合轉換，以及狀態變更或快速手勢是否造成重複全量工作。優先將非 UI 批次計算移至可取消的背景任務，取消過期重建，對高頻輸入適量 debounce，並在大量資料的導覽索引評估加權取樣或分段快取。以 Instruments 在實機確認瓶頸後再改動，避免未量測就大幅重構；縮圖路徑另確認 PhotoKit 請求可取消、清晰結果處理與 continuation 完成狀態。完成修正後，依本檔裝置更新規範建置、安裝及驗證。

## 照片「全部（.all）」檢視核心不變規範（嚴禁破壞）

1. **定位與排序鐵律**：
   - 「全部」模式下最新照片固定在最下方。
   - 預設定位必須保持在最新照片（底部），切換至全部時必須精確對齊最新照片。
2. **禁止銷毀與重建（防止黑屏）**：
   - `PhotosTabView` 必須使用 `ZStack` 搭配 `opacity` 與 `allowsHitTesting` 來保留 `allGridContent`（`CompactGridView`）在 View Hierarchy 中。
   - **嚴禁**改回使用 `if scale == .all { allGridContent }`。若銷毀重建，iOS 的 `LazyVGrid` 在尚未完成排版時進行底部定位會導致視圖一片漆黑、需手動滑動才出圖。
   - 任何改動不得更動此生命週期與底部錨定架構。
