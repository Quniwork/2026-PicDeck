# PicDeck 與 iOS 系統「照片.app」資料結合及 PhotoKit 同步全覽規範

> **建立日期**：2026-09-25  
> **適用平台**：iOS 17.0 ~ iOS 27.0+（最新 SDK）  
> **維護目的**：完整定義 PicDeck 各項產品功能如何深度結合 iOS 系統「照片.app」，列出所有 PhotoKit 已啟用、可擴充之雙向同步機制，並附上 Apple 官方 SDK 來源檔案與方法簽名。

---

## 零、架構哲學：原生共生（Native Coexistence）

PicDeck 的核心原則是**「與 iOS 照片庫深度融合，不做資料孤島」**：
1. **零實體拷貝**：App 不重複儲存照片/影片實體檔案，100% 依託 iOS 系統照片庫（PhotoKit）。
2. **系統照片庫同步**：喜愛、系統相簿及 iOS 27 起的說明與標籤名稱會寫入系統照片庫。標籤圖示、紀念日與釘選等 PicDeck 專屬屬性仍由 PicDeck 保存。外部照片庫異動由 PhotoKit 通知後刷新。
3. **無損與安全暫存**：破壞性操作（如刪除）採兩階段保護（App 待刪清單暫存 → 觸發系統「最近刪除」對話框），絕不繞過系統保護機制。

---

## 一、PicDeck 功能與 iOS 照片庫資料映射總覽表

| PicDeck 功能模組 | 對應 iOS「照片.app」欄位 / 功能 | PhotoKit 核心 API | 同步狀態 |
| :--- | :--- | :--- | :---: |
| **喜愛（Favorite）** | 照片愛心圖示（喜好項目） | `PHAssetChangeRequest.isFavorite` | ✅ **已開啟** |
| **刪除（Delete）** | 移至「最近刪除（Recently Deleted）」 | `PHAssetChangeRequest.deleteAssets(_:)` | ✅ **已開啟** |
| **相簿歸檔（Albums）** | 使用者自訂相簿（User Albums） | `PHAssetCollectionChangeRequest` | ✅ **已開啟** |
| **資料夾階層（Folders）**| 相簿資料夾（Collection Lists） | `PHCollectionListChangeRequest` | ✅ **已開啟** |
| **照片備註（Notes）** | 資訊面板中的**「說明（Caption）」** | `PHAssetChangeRequest.caption` | ✅ **iOS 27 起已開啟** |
| **自訂標籤（Tags）** | 資訊面板中的**「關鍵字（Keywords）」** | `PHAssetChangeRequest.addKeyword(_:)` / `removeKeyword(_:)` | ✅ **iOS 27 起已開啟** |
| **檔案名稱（Filename）**| 資訊面板的原始檔名（如 `IMG_8077`） | `PHAssetExtendedMetadata.originalFilename` / `PHAssetResource` | ✅ **已開啟** |
| **時間軸與年月瀏覽** | 拍攝時間與照片時間線 | `PHAsset.creationDate` | ✅ **已開啟** |
| **媒體分類（篩選）** | 影片、截圖、自拍、動態照片 | `PHAssetCollection.fetchAssetCollections(with: .smartAlbum...)` | ✅ **已開啟** |
| **星級評分（Rating）** | 照片星級（1~5 星評分） | `PHAssetChangeRequest.rating` | 🚀 **可擴充 (iOS 27)** |
| **隱藏照片（Hidden）** | 移至系統「已隱藏（Hidden）」相簿 | `PHAssetChangeRequest.isHidden` | 🚀 **可擴充** |
| **時間修改（Date Edit）**| 調整拍攝日期與時間 | `PHAssetChangeRequest.creationDate` | 🚀 **可擴充** |
| **地點調整（Location）**| 調整拍攝地理位置 GPS | `PHAssetChangeRequest.location` | 🚀 **可擴充** |
| **圖庫異動即時更新** | 其他 App 刪除、編輯相片時通知 | `PHPhotoLibraryChangeObserver` | ✅ **已開啟** |

---

## 二、PhotoKit 同步功能深度詳解與官方來源依據

### 1. 照片「說明 / 備註」（Caption / Description）同步

- **iOS 照片.app 表現**：照片向上滑動打開 Info 面板，最上方顯著的「加入說明」文字欄。
- **PicDeck 結合方式**：
  - 讀取：打開詳細資訊面板時，優先讀取系統 Caption 做為初始備註。
  - 寫入：在 PicDeck 編輯備註後，透過 PhotoKit 寫回系統相簿；iOS 26 以下維持 PicDeck 本機備註。
- **PhotoKit 官方 SDK 來源**：
  - **標頭檔路徑**：`/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/Photos.framework/Headers/PHAssetChangeRequest.h`
  - **寫入屬性**（第 43 行）：
    ```objc
    /// An asset description to change to.
    /// Set to nil or an empty string to clear the caption.
    @property (nonatomic, copy, readwrite, nullable) NSString *caption API_AVAILABLE(ios(27), macos(27), tvos(27), visionos(27));
    ```
  - **讀取屬性**（`PHAssetExtendedMetadata.h` 第 23 行）：
    ```objc
    @property (copy, readonly, nullable) NSString *caption;
    ```
- **Swift 實作範例**（已實作於 `NoteStore.swift` & `PhotoLibraryService.swift`）：
  ```swift
  // 寫入說明
  try await PHPhotoLibrary.shared().performChanges {
      let request = PHAssetChangeRequest(for: asset)
      request.caption = text.isEmpty ? nil : text
  }
  // 讀取說明
  let sysCaption = asset.extendedMetadata.caption
  ```

---

### 2. 照片「關鍵字 / 標籤」（Keywords / Tags）同步（iOS 27 全新功能）

- **iOS 照片.app 表現**：iOS 27 全新在 Info 面板最下方加入**「加入關鍵字」**按鈕，點擊可新增、選取膠囊關鍵字（如 `test`、`旅行`、`家人`）。
- **PicDeck 結合方式**：
  - PicDeck 的標籤名稱與照片.app 關鍵字對應；新增、移除、改名或刪除標籤時，系統照片的關鍵字會跟著變動。
  - 照片.app 新增或移除關鍵字後，PicDeck 在開啟照片或標籤選擇器時載入；與既有 PicDeck 標籤同名時自動關聯。未知關鍵字顯示在資訊面板，使用者可手動加入為 PicDeck 標籤。初次同步合併兩邊既有名稱。
  - `tags.json` 繼續保存標籤 ID、圖示、紀念日、釘選與照片關聯；iOS 26 以下不支援系統關鍵字讀寫。
- **PhotoKit 官方 SDK 來源**：
  - **標頭檔路徑**：`PHAssetChangeRequest.h`（第 68~71 行）
  - **宣告內容**：
    ```objc
    /// Add or remove a keyword associated with this asset
    /// Adding a keyword that is already associated (or removing a keyword that is not) will be silently ignored
    - (void)addKeyword:(NSString *)keyword API_AVAILABLE(macos(27), ios(27), tvos(27), visionos(27));
    - (void)removeKeyword:(NSString *)keyword API_AVAILABLE(macos(27), ios(27), tvos(27), visionos(27));
    ```
  - **讀取宣告**（`PHAssetExtendedMetadata.h` 第 28~29 行）：
    ```objc
    /// The keywords associated with this asset
    @property (copy, readonly) NSArray<NSString *> *keywords;
    ```
- **Swift 擴充實作範例**：
  ```swift
  // 為照片同步加入標籤至系統關鍵字
  try await PHPhotoLibrary.shared().performChanges {
      let request = PHAssetChangeRequest(for: asset)
      request.addKeyword("美食")
  }
  ```

---

### 3. 照片原始檔案名稱（Original Filename）讀取

- **iOS 照片.app 表現**：日期時間下方顯示拍攝檔名（如 `IMG_8077` 或 `IMG_0111.HEIC`）。
- **PicDeck 結合方式**：
  - 於單圖檢視詳細資訊面板（`PhotoInspectorPanelView`）頂部規格列顯示（`1,290 × 2,796 • 照片 • IMG_8077`）。
- **PhotoKit 官方 SDK 來源**：
  - **標頭檔路徑**：`PHAssetExtendedMetadata.h`（第 26 行）
    ```objc
    /// The original file name of this asset.
    @property (copy, readonly, nullable) NSString *originalFilename;
    ```
  - **跨版本備援路徑**：`PHAssetResource.assetResources(for: asset).first?.originalFilename`

---

### 4. 喜愛項目（Favorites）雙向同步

- **iOS 照片.app 表現**：底部的愛心圖示，點選加入「喜好項目」智慧相簿。
- **PicDeck 結合方式**：
  - 單圖操作列愛心按鈕、卡片模式下拉手勢、柵欄模式批次喜愛按鈕。
  - 觸發時伴隨觸覺震動回饋，並立即改變系統相簿狀態。
- **PhotoKit 官方 SDK 來源**：
  - **標頭檔路徑**：`PHAssetChangeRequest.h`（第 58 行）
    ```objc
    @property (nonatomic, assign, readwrite, getter=isFavorite) BOOL favorite;
    ```

---

### 5. 安全刪除與待刪除清單（Two-Stage Deletion）

- **iOS 照片.app 表現**：照片被移入「最近刪除」相簿，保留 30 天，可由使用者 Face ID 解鎖救回或永久抹除。
- **PicDeck 結合方式**：
  - **第一階段（PicDeck 待刪清單暫存）**：上滑卡片或點擊刪除按鈕時，相片先進入 App 內部安全暫存清單（`PendingTrashView`），不立即驚擾系統。
  - **第二階段（真正刪除）**：在待刪清單確認清空時，批次調用 PhotoKit 刪除，觸發 iOS 官方安全彈窗「允許 PicDeck 刪除這 X 張照片嗎？」。
- **PhotoKit 官方 SDK 來源**：
  - **標頭檔路徑**：`PHAssetChangeRequest.h`（第 47 行）
    ```objc
    + (void)deleteAssets:(id<NSFastEnumeration>)assets;
    ```

---

### 6. 相簿與資料夾階層管理（Albums & Folder Hierarchies）

- **iOS 照片.app 表現**：「相簿」分頁中的使用者自訂相簿、相簿資料夾階層。
- **PicDeck 結合方式**：
  - 支援讀取完整的樹狀階層結構（資料夾包含子資料夾與相簿）。
  - 支援在 PicDeck 內新建相簿、新建資料夾、歸檔相片、移出相片，100% 映射至系統照片庫。
- **PhotoKit 官方 SDK 來源**：
  - **相簿標頭檔**：`PHAssetCollectionChangeRequest.h`
    ```objc
    + (instancetype)creationRequestForAssetCollectionWithTitle:(NSString *)title;
    - (void)addAssets:(id<NSFastEnumeration>)assets;
    - (void)removeAssets:(id<NSFastEnumeration>)assets;
    ```
  - **資料夾標頭檔**：`PHCollectionListChangeRequest.h`
    ```objc
    + (instancetype)creationRequestForCollectionListWithTitle:(NSString *)title;
    - (void)addChildCollections:(id<NSFastEnumeration>)collections;
    ```

---

### 7. 未來可擴充之 PhotoKit 同步能力（Feature Extensions）

| 功能項目 | iOS 照片庫對應能力 | PhotoKit API 來源與方法 | 未來可落地的 PicDeck 體驗 |
| :--- | :--- | :--- | :--- |
| **星級評分 (Rating)** | 專業相片評級（1~5 星） | `PHAssetChangeRequest.rating` (`API_AVAILABLE(ios(27))`) | 整理時快速給照片打 1~5 顆星，篩選出 5 星精選相片。 |
| **隱藏照片 (Hidden)** | 移入 Face ID 保護的「已隱藏」相簿 | `PHAssetChangeRequest.hidden = YES` | 私密相片整理時，一鍵上鎖移入隱藏相簿。 |
| **拍攝時間微調** | 調整照片 EXIF 拍攝時間 | `PHAssetChangeRequest.creationDate` | 相機時鐘錯誤或掃描舊相片時，批量微調日期。 |
| **地點位置校正** | 調整拍攝座標 GPS | `PHAssetChangeRequest.location` | 無 GPS 相機拍攝照片，就地補上旅行打卡地點。 |
| **動態照片播放切換** | 關閉 Live Photo 的影片播放部分 | `PHAssetChangeRequest.setLivePhotoVideoPlaybackEnabled:` (`API_AVAILABLE(ios(27))`) | 控制 Live Photo 的播放呈現；不可假定會減少檔案容量。 |

---

## 三、變更監聽與多工響應機制（Observer Pattern）

為了防止使用者在外部「照片.app」或其他修圖 App 修改照片後，PicDeck 介面出現過期或不同步狀態，PicDeck 實作了全域變更監聽器：

- **官方 API 來源**：`PHPhotoLibrary.shared().register(changeObserver)`
- **實作模組**：[`PhotoLibraryService.swift`](../../PicDeck/PicDeck/Services/PhotoLibraryService.swift)
- **響應機制**：
  ```swift
  final class LibraryChangeObserver: NSObject, PHPhotoLibraryChangeObserver {
      var onChange: (() -> Void)?
      func photoLibraryDidChange(_ changeInstance: PHChange) {
          onChange?()
      }
  }
  ```
  當系統通知照片刪除、喜愛、新增或修改時，清除記憶體快取（`assetCache.removeAll()`）並觸發重新整理。通知與介面更新為非同步，不能保證零延遲。

---

## 四、技術總結與架構優勢

1. **系統資料與 PicDeck 資料分工**：
   系統相簿、喜愛與 iOS 27 起寫入的說明、標籤名稱保存在照片庫；PicDeck 標籤的附加屬性、日記、備註完成狀態與已整理紀錄另有自己的儲存與備份機制。
2. **純淨輕量，極致省電**：
   不自行啟動背景影像特徵掃描，不消耗多餘電池電量與網路頻寬，發揮 Apple 晶片原生硬體加速優勢。
3. **iOS 27 API 支援範圍**：
   Caption 與 Keywords 均已在 PicDeck 實作雙向同步；iOS 26 以下保留原本 PicDeck 本機資料模式。
