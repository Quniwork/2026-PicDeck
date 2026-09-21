# PicDeck TestFlight 測試指南

目的：讓你人在外面，用自己的 iPhone 透過 TestFlight 安裝並測試 PicDeck，不用接 Mac。

> **誠實聲明**：我沒有你的 Apple Developer 帳號，也沒有實際上傳過，這份指南是依這個專案的設定與 Apple 的流程寫的，
> 畫面文字可能和你看到的略有出入，以你螢幕上的為準。上傳那一步必須由你在自己的 Mac 上操作。

---

## 一、先確認的前提

| 項目 | 說明 |
| --- | --- |
| **付費帳號** | TestFlight 一定要 **Apple Developer Program**（99 美元／年）。免費 Apple ID 不能用。 |
| Mac | 已裝 Xcode 27，並用同一個 Apple ID 登入（Xcode → Settings → Accounts）。 |
| iPhone | 裝好 App Store 的 **TestFlight** App，用同一個 Apple ID 登入。iOS 17 以上。 |
| 網路 | 上傳需要網路；之後在外面更新測試版也是走網路。 |

## 二、專案目前的狀態（我查到的）

| 項目 | 現況 | 要做什麼 |
| --- | --- | --- |
| Bundle ID | `com.picdeck.app` | 有可能已被別人用，被佔用就改成自己的，例如 `com.你的名字.picdeck`。**改了 ID，App 在手機上會被當成新 App，資料不會帶過去。** |
| 簽章 | 自動（Automatic），**沒有設定 Team** | 在 Xcode 選你的 Team（見 3-1）。 |
| 版本 | 0.1.0（build 1） | 每次上傳新版，**build 號要比上次大**（見 3-4）。 |
| 圖示 | 已有（`AppIcon.icon`） | 不用動。 |
| 相簿權限說明 | 已內建 | 審核會看，內容清楚。 |
| 隱私清單（PrivacyInfo） | **沒有** | 見 3-5，App Store Connect 可能會要求。 |
| 加密聲明 | **沒有設定** | 見 3-6，不設每次上傳都會被問一次。 |
| 名稱 | 顯示名稱是 PicDeck | 你在考慮改 PicBoo，**名稱請在第一次上傳前決定**，改名字要動不少地方。 |

## 三、一次性設定

### 3-1 選 Team
1. 打開 `PicDeck/PicDeck.xcodeproj`。
2. 左邊點藍色 **PicDeck** → TARGETS 選 **PicDeck** → **Signing & Capabilities**。
3. 勾 **Automatically manage signing**，**Team** 選你的付費帳號。
4. 若說 Bundle ID 已被使用，改成獨一無二的字串。
5. 測試用的 `PicDeckUITests` 不用動。

### 3-2 在 App Store Connect 建立 App
1. 到 <https://appstoreconnect.apple.com> → **App** → **＋** → **新增 App**。
2. 平台選 iOS；名稱填 App 名稱（App Store 上要唯一，可能要換）；主要語言選繁體中文；
   **套件識別碼** 選你在 3-1 用的那個；SKU 隨便填一個（例如 `picdeck-001`）。
3. 名稱被別人用了會直接擋下，這也是一個檢查「PicBoo」可不可用的方法。

### 3-3 加測試者
- **內部測試**（最快）：App Store Connect → 使用者與存取權限，把你自己或朋友加進來。**最多 100 人**，上傳完成處理好就能測，**不用 Apple 審核**。
- **外部測試**：最多 1 萬人，用邀請連結或 email；**第一個 build 要通過 Apple 的 Beta 審核**（通常一兩天）。

你自己測的話用內部測試就夠了。

### 3-4 版本與 build 號
- 打開 Target → **General** → **Identity**：**Version** 是對外版本，**Build** 是內部號。
- 同一個版本每次上傳，Build 一定要比上次大（1、2、3…）。忘了改會上傳失敗。

### 3-5 隱私清單（建議做）
PicDeck 讀取照片、把標籤／日記存在本機，**沒有網路傳輸**。建議在專案加一個 `PrivacyInfo.xcprivacy`：
- 不追蹤使用者（Tracking = NO）。
- 宣告有用到 **UserDefaults**（原因碼 `CA92.1`）與檔案時間戳（App 內存 JSON）。
如果你要我幫你加，跟我說，我可以直接寫好。

### 3-6 加密聲明
PicDeck 沒有自己的加密。在 Target → **Info** 加一列 `ITSAppUsesNonExemptEncryption` = `NO`，
之後上傳就不會每次被問出口合規。這件事我也可以幫你加進專案設定。

## 四、上傳 build

1. Xcode 上方裝置選 **Any iOS Device (arm64)**（不是模擬器）。
2. 選單 **Product → Archive**，等它編譯完會開 Organizer。
3. 選剛出現的封存 → **Distribute App** → **TestFlight & App Store** → 依預設一路下一步 → **Distribute**。
4. 上傳成功後，App Store Connect → **TestFlight** 會先顯示「處理中」，**通常 5 到 30 分鐘**，好了會寄信通知。

用指令上傳也可以（適合重複做），但要先設定 API 金鑰，第一次建議用上面的圖形介面。

## 五、在 iPhone 上測試

1. 加為測試者後，手機會收到邀請信（內部測試者也可在 TestFlight App 直接看到）。
2. 打開 **TestFlight** App → 找到 PicDeck → **安裝**。
3. 第一次開會問照片權限，**選「允許完整取用」**，不然畫面會是空的。
4. 有新 build 時 TestFlight 會通知你更新。
5. 測試版有效期 **90 天**，過期要重新上傳新 build。
6. 在 TestFlight 裡可以直接截圖並寫回饋，會送到 App Store Connect。

## 六、要注意的事

- **App 會真的動到手機照片。** 先備份，先用少量照片測，細節看 [真機安裝與測試指南](./真機安裝與測試指南.md) 第四節。
- **TestFlight 裝的是正式簽章版，跟你用 Xcode 直接裝的 App 是同一個 Bundle ID**，會互相覆蓋，兩邊資料不共用。
- 免費帳號 7 天過期的限制，在 TestFlight 不存在。
- **App 資料只在手機上**（標籤、日記、備註存在 App 的 Documents），刪掉 App 就沒了；TestFlight 更新新版不會清掉。
- 首次上傳可能被要求填 **App 隱私問卷**（收集哪些資料）。PicDeck 不收集，選「不收集資料」。
- 圖示是玻璃風格的 `.icon`，上傳後在 TestFlight 顯示如何我沒驗證過。

## 七、常見錯誤

| 訊息 | 處理 |
| --- | --- |
| `No accounts with App Store Connect access` | Xcode 沒登入付費帳號，或帳號沒有 App Manager 以上權限。 |
| `Bundle ID is not available` | 被人用了，改 ID（3-1）。 |
| `The bundle version must be higher than the previously uploaded version` | Build 號沒加，改 3-4。 |
| `Missing Info.plist key… NSPhotoLibraryUsageDescription` | 專案已有，若出現代表設定被改掉。 |
| 上傳成功但 TestFlight 看不到 | 還在處理，等信；超過一小時再看 App Store Connect 的「活動」頁。 |
| 拒絕：缺少隱私清單 | 做 3-5。 |

## 八、我建議的順序

1. 決定名稱與 Bundle ID（PicBoo 與否）。
2. 讓我補上 `PrivacyInfo.xcprivacy` 與加密聲明。
3. 你選 Team、在 App Store Connect 建立 App。
4. Archive → 上傳 → 等處理 → 內部測試。
