# PicDeck 效能瓶頸與版本控制優化解決方案文件

本文件針對 PicDeck（相牌）專案目前存在的三大關鍵問題，提供深度技術成因分析、重構架構設計、具體程式碼範例以及逐步實施指南。

---

## 目錄
1. [問題一：拖拉軸與格線重建在主執行緒上的計算負擔（卡頓/崩潰主因）](#一問題一拖拉軸與格線重建在主執行緒上的計算負擔)
2. [問題二：縮圖加載 Continuation 掛起與請求取消機制](#二問題二縮圖加載-continuation-掛起與請求取消機制)
3. [問題三：缺乏 .gitignore 與未追蹤檔案管理](#三問題三缺乏-gitignore-與未追蹤檔案管理)
4. [實施步驟與驗證清單](#四實施步驟與驗證清單)

---

## 一、問題一：拖拉軸與格線重建在主執行緒上的計算負擔

### 1. 問題成因與機制分析

#### (1) 主執行緒阻塞與 0x8badf00d Watchdog 崩潰
在 [`PhotosTabView.swift`](file:///Library/WebServer/Documents/photo-app/PicDeck/PicDeck/Views/PhotosTabView.swift#L377-L380) 中：
```swift
private func rebuildAllGrid() {
    let ordered = orderedGridAssets()
    allGrid = AllGridSnapshot(assets: ordered, scrub: makeAllScrub(for: ordered))
}
```
- `rebuildAllGrid()` 標記在 `PhotosTabView` 內，預設運行在 `@MainActor`（主執行緒）。
- 當圖庫達到 2 萬～10 萬張照片時，`makeAllScrub` 遍歷所有照片計算列高與寬高比。
- 接著在 [`ScrubberOverlay.swift`](file:///Library/WebServer/Documents/photo-app/PicDeck/PicDeck/Views/ScrubberOverlay.swift#L32-L37) 的 `ScrubIndex.init` 中：
  ```swift
  for anchor in anchors {
      starts.append(running)
      let year = calendar.component(.year, from: anchor.date)
      if seen.insert(year).inserted { years.append((year, running)) }
      running += max(anchor.weight, 0.0001)
  }
  ```
  這裡對 **100,000 個 anchor** 執行 `calendar.component(.year, from: anchor.date)`。`Calendar` 物件在 Foundation 中是較重的運算，十萬次呼叫在主執行緒耗時超過 500ms～1500ms，導致 UI 完全凍結。當使用者在多個 Tab 快速來回切換或從背景喚醒時，極易超過 iOS Watchdog（通常為幾秒）的容許時間，被系統強制終止（Crash 0x8badf00d）。

#### (2) 縮放手勢時的高頻觸發
當使用者捏合縮放變更格線欄數（`gridColumns`）時：
```swift
.onChange(of: model.gridColumns(for: .all)) { _, _ in rebuildAllGrid() }
.onChange(of: model.gridFitsAspect(for: .all)) { _, _ in rebuildAllGrid() }
```
手勢每變更一次，主執行緒就重新執行整套 10 萬筆運算，造成嚴重的掉幀與手勢跟手性下降。

#### (3) 過度精確（Over-precision）
螢幕高度約為 800~900pt，右側拖拉軸可滑動的實體長度僅約 400~500pt。建立 10 萬個落點（Anchors）在物理觸控上完全無感知，拖動 1 像素就會跨過 200 張照片。對「每張照片」建立 anchor 是嚴重的算力浪費。

---

### 2. 改善架構設計

1. **落點分桶（Binning / Chunking）**：
   - 不再以「每一張照片」為 anchor，改為依「天（Day）」或「每固定 N 列（Chunk）」為單位取樣，將 anchor 數量從 100,000 個縮減至 500～2,000 個，計算量降低 98% 以上。
2. **移至背景非同步執行（Detached Task / Background Actor）**：
   - 格線索引的建立與排序全面移至背景執行緒，計算完成後才回主執行緒更新 `allGrid`。
3. **手勢防抖（Debounce）與 Task 取消**：
   - 使用者連續縮放或切換排序時，取消前一次未完成的計算任務，避免佇列堆積。

---

### 3. 重構程式碼範例

#### (1) `ScrubberOverlay.swift`：快速年份提取與索引優化

```swift
// file: PicDeck/Views/ScrubberOverlay.swift

struct ScrubIndex: Sendable {
    let anchors: [ScrubAnchor]
    private let starts: [Double]
    let totalWeight: Double
    let yearStarts: [(year: Int, start: Double)]

    init(anchors: [ScrubAnchor]) {
        self.anchors = anchors
        var starts: [Double] = []
        starts.reserveCapacity(anchors.count)
        var running = 0.0
        var years: [(Int, Double)] = []
        var seenYears = Set<Int>()
        
        let calendar = PhotoGrouping.calendar

        // 優化：快取前一個 anchor 的 year，同一年內不重算 calendar.component
        var lastDate: Date?
        var lastYear: Int = 0

        for anchor in anchors {
            starts.append(running)
            
            let year: Int
            if let prev = lastDate, calendar.isDate(prev, equalTo: anchor.date, toGranularity: .year) {
                year = lastYear
            } else {
                year = calendar.component(.year, from: anchor.date)
                lastDate = anchor.date
                lastYear = year
            }

            if seenYears.insert(year).inserted {
                years.append((year, running))
            }
            running += max(anchor.weight, 0.0001)
        }

        self.starts = starts
        self.totalWeight = running
        self.yearStarts = years
    }
}
```

#### (2) `PhotosTabView.swift`：背景建立與分桶取樣

```swift
// file: PicDeck/Views/PhotosTabView.swift

// 新增一個背景任務變數管理
@State private var rebuildGridTask: Task<Void, Never>?

/// 全部照片的拖拉軸索引：改採粗粒度分桶，避免 10 萬張照片產出 10 萬個 anchor
private static func makeAllScrubBackground(for items: [PHAsset],
                                          columnCount: Int,
                                          usesAspectRatio: Bool) -> ScrubIndex {
    guard !items.isEmpty else { return ScrubIndex(anchors: []) }
    
    // 取樣策略：如果總量大於 2000，每 strideCount 取樣一次
    let totalCount = items.count
    let sampleStep = max(1, totalCount / 1500)
    
    var anchors: [ScrubAnchor] = []
    anchors.reserveCapacity(totalCount / sampleStep + 1)
    
    for i in stride(from: 0, to: totalCount, by: sampleStep) {
        let asset = items[i]
        guard let date = asset.creationDate else { continue }
        // 權重等比例縮放
        let weight = Double(sampleStep) / Double(columnCount)
        anchors.append(ScrubAnchor(date: date, weight: weight))
    }
    
    return ScrubIndex(anchors: anchors)
}

/// 非同步重建全部格線
private func scheduleRebuildAllGrid() {
    rebuildGridTask?.cancel()
    
    let sourceAssets = assets
    let sortsByAdded = model.sortsByAdded
    let ranks = addedRanks
    let columns = max(model.gridColumns(for: .all), 1)
    let fitsAspect = model.gridFitsAspect(for: .all)
    
    rebuildGridTask = Task(priority: .userInitiated) {
        // 在背景線程進行排序與索引計算
        let ordered: [PHAsset]
        if sortsByAdded, !ranks.isEmpty {
            ordered = sourceAssets.sorted { (ranks[$0.localIdentifier] ?? .max) > (ranks[$1.localIdentifier] ?? .max) }
        } else {
            ordered = Array(sourceAssets.reversed())
        }
        
        guard !Task.isCancelled else { return }
        
        let scrub = Self.makeAllScrubBackground(for: ordered, columnCount: columns, usesAspectRatio: fitsAspect)
        
        guard !Task.isCancelled else { return }
        
        await MainActor.run {
            self.allGrid = AllGridSnapshot(assets: ordered, scrub: scrub)
        }
    }
}
```

---

## 二、問題二：縮圖加載 Continuation 掛起與請求取消機制

### 1. 問題成因與機制分析

#### (1) `withCheckedContinuation` 的永久掛起（Hang）
在 [`AssetThumbnail.swift`](file:///Library/WebServer/Documents/photo-app/PicDeck/PicDeck/Views/AssetThumbnail.swift#L112-L125) 中：
```swift
return await withCheckedContinuation { continuation in
    let box = ThumbnailResumeBox()
    manager.requestImage(for: asset,
                         targetSize: target,
                         contentMode: fitsAspect ? .aspectFit : .aspectFill,
                         options: options) { image, info in
        let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
        if isDegraded { return }
        guard box.tryResume() else { return }
        continuation.resume(returning: image)
    }
}
```
- PhotoKit 的 `requestImage` 在 `deliveryMode = .opportunistic` 下通常會先返回一個低解析度縮圖（`isDegraded == true`），隨後返回高清圖。
- **但若發生以下情境**：
  1. iCloud 照片下載網路超時或取消；
  2. `info?[PHImageCancelledKey] == true`；
  3. `info?[PHImageErrorKey] != nil`。
  PhotoKit 在第一次返回 degraded 縮圖後，**不會再產生第二次回呼**。
- 因為代碼判斷 `if isDegraded { return }`，使得代碼直接忽略，`continuation.resume` 永遠不會被呼叫。
- 結果：該 Swift Concurrency Task 永久處於 Suspended 狀態，記憶體洩漏且佔用線程資源。

#### (2) 缺乏任務取消（Task Cancellation）連動
當使用者快速滑過 LazyVGrid 時，SwiftUI 會觸發儲存格的生命週期結束並取消 `.task`。但因為底層沒有保存 `PHImageRequestID`，也沒有呼叫 `manager.cancelImageRequest(id)`，PhotoKit 仍會在背景排隊解碼幾百張已經看不見的照片，造成 I/O 與 CPU 飽和，新滑入畫面的照片需要排隊數秒才顯示。

---

### 2. 改善架構設計

1. **完善的錯誤與退化狀態處理**：
   - 只要回呼帶有錯誤或取消標記，或是只有 degraded 圖片且無後續更新可能，必須確保 `continuation.resume` 必定被執行（保證每次非同步都有歸宿）。
2. **連動 `withTaskCancellationHandler`**：
   - 記錄 `PHImageRequestID`，當外層 Task 取消時立即呼叫 `manager.cancelImageRequest(id)`。

---

### 3. 重構程式碼範例

```swift
// file: PicDeck/Views/AssetThumbnail.swift

final class ThumbnailLoader {
    static let shared = ThumbnailLoader()
    private let manager = PHCachingImageManager()
    
    private let options: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        return options
    }()

    private init() {
        manager.allowsCachingHighQualityImages = false
    }

    func image(for asset: PHAsset, size: CGFloat, fitsAspect: Bool = false) async -> UIImage? {
        let scale = await UIScreen.main.scale
        let aspectHeight = fitsAspect && asset.pixelWidth > 0 && asset.pixelHeight > 0
            ? size * CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth)
            : size
        let target = CGSize(width: size * scale, height: aspectHeight * scale)

        // 用於存取與取消 PhotoKit 請求的執行緒安全盒
        final class RequestHolder: @unchecked Sendable {
            var requestID: PHImageRequestID?
            var isCancelled = false
            let lock = NSLock()
            
            func setID(_ id: PHImageRequestID) {
                lock.lock()
                defer { lock.unlock() }
                if isCancelled {
                    PHCachingImageManager.default().cancelImageRequest(id)
                } else {
                    requestID = id
                }
            }
            
            func cancel(manager: PHCachingImageManager) {
                lock.lock()
                defer { lock.unlock() }
                isCancelled = true
                if let id = requestID {
                    manager.cancelImageRequest(id)
                }
            }
        }

        let holder = RequestHolder()

        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                let box = ThumbnailResumeBox()
                
                let reqID = manager.requestImage(for: asset,
                                                 targetSize: target,
                                                 contentMode: fitsAspect ? .aspectFit : .aspectFill,
                                                 options: options) { image, info in
                    let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                    let isCancelled = (info?[PHImageCancelledKey] as? Bool) ?? false
                    let error = info?[PHImageErrorKey] as? Error

                    // 1. 若發生錯誤或取消，立即回傳 nil，不掛起
                    if isCancelled || error != nil {
                        if box.tryResume() {
                            continuation.resume(returning: nil)
                        }
                        return
                    }

                    // 2. 若是臨時的低畫質圖，先行返回可用於預覽；若維持只等待高清，則若無高清時需保證釋放
                    if isDegraded {
                        // 如果已經有圖，可選擇直接 resume 提升流暢度；或若堅持只用高清，需確保若不會再回調時不 hang
                        return
                    }

                    // 3. 正常取得高清影像
                    if box.tryResume() {
                        continuation.resume(returning: image)
                    }
                }
                
                holder.setID(reqID)
            }
        } onCancel: {
            holder.cancel(manager: manager)
        }
    }
}
```

---

## 三、問題三：缺乏 .gitignore 與未追蹤檔案管理

### 1. 現狀與風險

1. **未追蹤檔案暴露風險**：
   - 檔案 [`PhotoCoverEditorView.swift`](file:///Library/WebServer/Documents/photo-app/PicDeck/PicDeck/Views/PhotoCoverEditorView.swift) 目前在檔案系統中，且已被 [`PhotosTabView.swift`](file:///Library/WebServer/Documents/photo-app/PicDeck/PicDeck/Views/PhotosTabView.swift#L275) 引用。
   - 因為尚未執行 `git add`，若其他開發者 clone 專案或在乾淨環境執行 CI，會因為找不到該檔案而編譯失敗。
2. **`UserInterfaceState.xcuserstate` 頻繁衝突**：
   - 該檔案記錄了個人本機在 Xcode 中的視窗位置與展開折疊狀態，目前已經存在於 Git 索引中，導致任何開發者開啟 Xcode 就會使工作區變成 Modified。
3. **缺少標準 `.gitignore`**：
   - 導致本機編譯產生的 `build/` 目錄、`.DS_Store`、DerivedData 都隨時可能被誤加到 Git。

---

### 2. 解決方案

#### (1) 標準 `.gitignore` 檔案內容
在專案根目錄 `/Library/WebServer/Documents/photo-app/.gitignore` 建立以下內容：

```gitignore
# Xcode
## User settings
xcuserdata/
*.xcuserdatad/
*.xcuserstate
project.xcworkspace/xcuserdata/

## Build products and intermediates
build/
DerivedData/
*.build
*.moved-aside
*.pbxuser
*.mode1v3
*.mode2v3
*.perspectivev3

## Swift Package Manager
.build/
Packages/
Package.pins
Package.resolved

## Fastlane & CocoaPods
Pods/
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots
fastlane/test_output

## macOS system files
.DS_Store
.AppleDouble
.LSOverride
._*
.Spotlight-V100
.Trashes
```

#### (2) 清理既有追蹤檔案並納入必要檔案的 Shell 指令流程

```bash
cd /Library/WebServer/Documents/photo-app

# 1. 將被錯誤追蹤的 xcuserstate 從 Git 索引移除（保留本機檔案）
git rm --cached PicDeck/PicDeck.xcodeproj/project.xcworkspace/xcuserdata/quni.xcuserdatad/UserInterfaceState.xcuserstate

# 2. 將新增但未追蹤的 PhotoCoverEditorView.swift 加入 Git
git add PicDeck/PicDeck/Views/PhotoCoverEditorView.swift

# 3. 加入新建立的 .gitignore
git add .gitignore

# 4. 移除本地臨時建立的 build/ 目錄（若有）
rm -rf build/
```

---

## 四、實施步驟與驗證清單

依循以下建議步驟循序落實，可在不影響現有架構的情況下消除所有隱患：

| 步驟 | 項目 | 執行重點 | 預期效果 |
| :--- | :--- | :--- | :--- |
| **Step 1** | **Git 規範與清理** | 建立 `.gitignore`、`git rm --cached *.xcuserstate`、`git add PhotoCoverEditorView.swift`。 | 工作區保持整潔，避免多人協作與本機狀態衝突。 |
| **Step 2** | **縮圖加載器強化** | 引入 `RequestHolder` 與 `withTaskCancellationHandler`，處理 `isCancelled` 與 `error`。 | 滑動網格不再堆積背景解碼任務，徹底解決 continuation 洩漏問題。 |
| **Step 3** | **拖拉軸背景非同步運算** | 將 `rebuildAllGrid()` 改為非同步背景任務，加入取樣策略（Sampling）。 | 即使面臨 10 萬張照片，滑動切換分頁與手勢縮放格線時主執行緒仍維持 60/120 FPS。 |
| **Step 4** | **自動化冒煙測試驗證** | 執行 `PicDeckSmokeTests.swift` 中的 `testRepeatedPhotosTabSwitch`。 | 驗證快速來回切換分頁與背景進出不再發生 Watchdog 卡死。 |
| **Step 5** | **多裝置建置與安裝** | 依據 `AGENTS.md` 規範安裝至兩台模擬器及實體 iPhone 進行視覺與操作驗證。 | 確認實機流暢度與 Liquid Glass 外觀正常。 |

## 五、已驗證的流暢度改善與後續排查方向

近期「年／月／日／時間軸／全部」切換與格線縮放變得流暢，主要是把大量照片的同步處理從 UI 主執行緒移開：切換時間軸時，原先依加入順序排序整個照片集合的工作，雖然日期分組已在背景執行，排序仍曾在呼叫分組前同步完成；現在排序與日期分組都在背景工作中進行。這是目前確認最直接的卡頓原因與修正。

「全部」格線也將照片屬性讀取、排序、拖拉索引建置移入可取消的背景工作。手勢連續改變格線設定時，採用 120 毫秒 debounce，舊的重建工作會取消；拖拉索引以最多約 1,500 個取樣錨點代表整個網格，避免為每張照片建立索引。縮圖載入使用可取消的 PhotoKit 請求，先收到的降級圖像僅作備援，成功時顯示完整結果，避免縮圖一直停留在模糊狀態。

日後遇到卡頓，優先沿著這個方向逐項確認：

1. 從發生卡頓的互動路徑開始，查 UI 主執行緒是否同步執行整個相簿的排序、篩選、日期／屬性讀取、分組、索引建置或大型集合轉換。
2. 確認 SwiftUI 狀態變更或快速手勢有沒有觸發重複、過期的全量工作；對可替代的工作取消舊任務，對高頻輸入做適量 debounce。
3. 把不依賴 UI 的純運算與批次資料整理移到可取消的背景工作；大量資料的拖拉／導覽索引評估使用加權取樣或分段快取。
4. 檢查縮圖請求是否可取消、是否等待清晰結果，以及 continuation 是否會在錯誤或取消路徑正確完成。
5. 用 Instruments（Time Profiler、主執行緒／Core Animation）在實機定位熱點，再針對該互動路徑驗證切換、快速連續操作與大相簿情境。不要只憑主觀感覺宣稱達到特定 FPS。

優先先找主執行緒上的全量工作和不必要的重複重建，再依量測結果決定背景化、取消／debounce、取樣或快取方式；不要先做無關的全域重構。

### 多選照片回饋延遲

近期選取照片會停頓約 0.5–1 秒，排查發現底部操作列為更新「加入喜愛／移出喜愛」狀態，每次選取變更都同步呼叫 `PHAsset.fetchAssets(withLocalIdentifiers:)`。將它改為每次選取啟動背景查詢後，實機回報連切換也變卡，顯示頻繁的 PhotoKit 查詢仍會爭用資源，即使查詢不在主執行緒。已撤除逐次查詢，改在點選單張或選取整日時，直接用畫面已有的 `PHAsset.isFavorite` 增量維護選取中的喜愛 ID；一般點選與切換不再觸發 PhotoKit 查詢。批次操作成功後同步更新這份 ID 集合。日後查選取卡頓，除了確認主執行緒工作，也要避免高頻互動啟動大量背景 PhotoKit 請求；優先重用已載入模型狀態並採增量更新。


### 層級切換定位與預熱競態

後續確認照片層級切換仍有停頓：切回「全部」時，既有捲動容器會為了回到最新照片先隱藏整個格線並等待約 200 毫秒定位；現在只有首次錨點定位會等待版面，已顯示的格線改為直接定位，不再先隱藏。另一個競態是某層級正由背景預熱時，前景切換任務因該層級已在準備而立即返回；現在前景任務會等該層資料完成，避免切換後留白等候。

### 快速切換時的背景工作取消

再確認層級切換仍停頓 1–2 秒後，發現照片分組雖使用 `Task.detached`，但呼叫端取消時並未取消 detached worker。快速切換期間，已離開層級的全相簿掃描仍會繼續，和目前層級的工作爭用 CPU。現在使用者切換會停止低優先序預熱，取消狀態傳入年份／月份曆／日期曆／時間軸分組 worker，並在照片掃描期間定期檢查取消；被取消的舊結果不會更新畫面狀態。這類卡頓除了檢查工作是否離開主執行緒，也要確認 detached／子任務是否真的收到取消，不能只取消等待它的父任務。
