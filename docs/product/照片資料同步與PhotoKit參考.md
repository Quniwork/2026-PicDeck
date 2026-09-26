# PicDeck、照片.app 資料同步與 PhotoKit 參考

更新：2026-09-25。這份盤點區分「寫入系統照片庫」與「PicDeck 自己儲存」。只有前者會直接出現在照片.app；PicDeck 的 iCloud 備份也不會自動變成照片.app 的欄位。

## 已實作的資料關係

| 資料 | PicDeck 與照片.app 的關係 | 系統介面與條件 |
| --- | --- | --- |
| 照片、影片及一般拍攝資訊 | PicDeck 從系統照片庫讀取，同一張媒體在兩邊可見 | `PHAsset`、`PHImageManager`；需照片庫授權 |
| 說明 ↔ 備註文字 | 雙向讀寫同一張照片的 Caption；照片.app 的修改在開啟單圖／備註或照片庫變更時載入，PicDeck 編輯後寫回 | iOS 27 起 `PHAsset.extendedMetadata.caption` 與 `PHAssetChangeRequest.caption`；iOS 26 以下僅存 PicDeck 本機備註 |
| 喜愛 | PicDeck 切換時寫入系統照片庫；外部變更由 PhotoKit 變更通知刷新 | `PHAsset.isFavorite`、`PHAssetChangeRequest.isFavorite` |
| 系統相簿與資料夾 | PicDeck 使用系統相簿；建立、命名、刪除、加入及移出照片會反映到照片.app | `PHAssetCollection`、`PHCollectionList` 及其 Change Request |
| 刪除照片 | PicDeck 先放入自己的待刪除清單；使用者最後確認刪除時才向系統照片庫提交，並進入系統「最近刪除」 | `PHAssetChangeRequest.deleteAssets` |
| PicDeck 自訂標籤 ↔ 照片關鍵字 | iOS 27 起雙向同步標籤名稱與同張照片的關鍵字；PicDeck 的圖示、紀念日、釘選與標籤 ID 另存本機／iCloud | `PHAsset.extendedMetadata.keywords`、`PHAssetChangeRequest.addKeyword`／`removeKeyword`；iOS 26 以下僅存 `tags.json` |
| 日記、分類、關聯照片 | PicDeck 自己儲存，照片.app 沒有對應的日記欄位 | `journal.json`、`journal-categories.json`；可由 PicDeck iCloud 容器備份 |
| 備註的完成狀態 | PicDeck 自己儲存；只有備註**文字**與系統說明同步 | `notes.json` 的 `isDone`；可由 PicDeck iCloud 容器備份 |
| 已整理／保留狀態 | PicDeck 自己儲存；照片.app 不顯示 | `kept-records.json` |

PicDeck 的四個 JSON 檔 `tags.json`、`journal.json`、`journal-categories.json`、`notes.json` 由 `CloudSyncService` 同步到 PicDeck 的 iCloud ubiquity container，另有本機備份。這條路徑與 iCloud 照片是兩套資料機制；此處程式碼沒有使用 CloudKit Private Database。`kept-records.json` 不在目前 `CloudSyncService` 的同步清單。

## iPhone 18 Pro 模擬器實測

- 目標：iPhone 18 Pro，iOS 27 模擬器 `609C7D8C-52C7-4AED-AB7C-DF5ADE289D0D`，同一張新加入的測試 PNG。
- 在照片.app 輸入 `PHOTOS_TO_PICDECK_20260925`，按右上角勾選完成儲存；系統照片庫持續保存該說明。
- 開啟 PicDeck 該照片的資訊面板，備註欄出現相同文字；專項 UI 測試通過。
- 在 PicDeck 備註欄輸入新文字並按完成；系統照片庫同一張照片的說明已更新。這一步以系統照片庫資料的唯讀檢查確認，未在照片.app 介面重新開啟該張照片驗證顯示。
- 此次實測覆蓋說明／備註文字。喜愛、相簿、刪除等項目是根據現有程式碼盤點，沒有在此次測試逐一操作。

照片.app 的說明編輯畫面必須按右上角勾選才算儲存；只輸入文字而留在編輯畫面時，PicDeck 不會讀到未提交的內容。

## 未來開發可用的 Apple framework

| Framework / API | 可用於 PicDeck 的功能 | 參考 |
| --- | --- | --- |
| **Photos（PhotoKit）**：`PHPhotoLibrary`、`PHAsset`、`PHFetchOptions` | 照片庫授權、查詢照片／影片及中繼資料 | [Photos](https://developer.apple.com/documentation/photos)、[PHPhotoLibrary](https://developer.apple.com/documentation/photos/phphotolibrary) |
| **Photos（PhotoKit）**：`PHAssetChangeRequest`、`PHAssetCollectionChangeRequest`、`PHCollectionListChangeRequest` | 在 `performChanges` 中修改說明、喜愛、照片與相簿／資料夾 | [PHAssetChangeRequest](https://developer.apple.com/documentation/photos/phassetchangerequest)、[相簿修改範例](https://developer.apple.com/documentation/photokit/browsing-and-modifying-photo-albums) |
| **Photos（PhotoKit）**：`PHPhotoLibraryChangeObserver` | 接收照片.app、其他 App 或 iCloud 照片造成的照片庫變更並重新取值 | [觀察照片庫變更](https://developer.apple.com/documentation/photokit/observing-changes-in-the-photo-library) |
| **Photos（PhotoKit）**：`PHImageManager`、`PHCachingImageManager` | 載入、快取縮圖與原始媒體 | [載入與快取](https://developer.apple.com/documentation/photokit/loading-and-caching-assets-and-thumbnails) |
| **PhotosUI**：`PhotosPicker`、`PHPickerViewController`、`PHLivePhotoView` | 用系統選取器讓使用者挑照片，或顯示 Live Photo；選取器不是完整照片庫編輯介面 | [PhotosUI](https://developer.apple.com/documentation/photosui)、[PhotosPicker](https://developer.apple.com/documentation/photosui/photospicker) |

### iOS 27 新增的說明與關鍵字

- **說明**：讀取 `PHAsset.extendedMetadata.caption`，於 `PHPhotoLibrary.shared().performChanges` 中設定 `PHAssetChangeRequest(for: asset).caption`。[讀取](https://developer.apple.com/documentation/photos/phassetextendedmetadata/caption)／[寫入](https://developer.apple.com/documentation/photos/phassetchangerequest/caption)。
- **關鍵字**：讀取 `PHAsset.extendedMetadata.keywords`，在照片庫變更區塊中使用 `PHAssetChangeRequest.addKeyword(_:)`、`removeKeyword(_:)`。[讀取](https://developer.apple.com/documentation/photos/phassetextendedmetadata/keywords)／[新增](https://developer.apple.com/documentation/photos/phassetchangerequest/addkeyword%28_%3A%29)／[移除](https://developer.apple.com/documentation/photos/phassetchangerequest/removekeyword%28_%3A%29)。PicDeck 已把標籤名稱接到這組 API；標籤其他屬性維持 PicDeck 自己儲存。
- 本機 Xcode iOS SDK 將這些介面標為 `API_AVAILABLE(ios(27))`。Apple 線上文件目前仍把部分項目標為 Beta，正式採用前應以目標 Xcode／iOS SDK 再確認可用性。

實作入口：`PicDeck/PicDeck/Services/PhotoLibraryService.swift`、`NoteStore.swift`、`TagStore.swift`、`JournalStore.swift`、`CloudSyncService.swift`。
