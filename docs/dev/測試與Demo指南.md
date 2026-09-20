# PicDeck 測試與 Demo 指南

2026-09-20

這份文件記錄如何在桌機（Mac 模擬器）測試 PicDeck，以及如何把 App 裝到自己的 iPhone 上做 Demo。指令都經過實際驗證，可直接複製使用。

## 專案位置與環境

| 項目 | 內容 |
| --- | --- |
| 專案路徑 | `/Library/WebServer/Documents/photo-app/PicDeck` |
| Xcode 專案 | `PicDeck/PicDeck.xcodeproj` |
| Bundle ID | `com.picdeck.app` |
| 版本 | 0.1.0 |
| 開發環境 | Xcode 16.4、iOS 18.5 SDK |
| 最低支援 | iOS 17.0 |
| 裝置 | 目前只做 iPhone 直式（未做 iPad） |

---

## 一、桌機測試（Mac + 模擬器）

這是日常開發最常用的方式，不需要實體 iPhone，也不需要 Apple 開發者帳號。

### 1-1 用 Xcode 圖形介面跑（最簡單）

1. 用 Finder 打開 `/Library/WebServer/Documents/photo-app/PicDeck/`，雙擊 `PicDeck.xcodeproj`。
2. Xcode 上方裝置選單選一台模擬器，例如 **iPhone 16**。
3. 按 **⌘R**（或左上角三角形播放鍵）執行。
4. 模擬器啟動後會看到權限說明畫面，點「允許取用照片」，系統對話框選「**允許完整取用**」。

停止執行按 **⌘.**（Command + 句點）。

### 1-2 用終端機指令跑（不開 Xcode）

```bash
cd /Library/WebServer/Documents/photo-app/PicDeck

# 編譯
xcodebuild -scheme PicDeck \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -configuration Debug build

# 開啟模擬器
xcrun simctl boot "iPhone 16"
open -a Simulator

# 安裝並啟動
APP=$(find ~/Library/Developer/Xcode/DerivedData/PicDeck-*/Build/Products/Debug-iphonesimulator \
       -maxdepth 1 -name "PicDeck.app" | head -1)
xcrun simctl install booted "$APP"
xcrun simctl launch booted com.picdeck.app
```

### 1-3 灌測試照片進模擬器

全新模擬器只有 6 張內建桌布，整理起來看不出效果。把 Mac 上的圖片丟進去：

```bash
# 指定資料夾裡的圖片
xcrun simctl addmedia booted ~/Desktop/測試照片/*.jpg

# 或用指令產生幾張純色測試圖
python3 -c "
import struct, zlib
def png(path, w, h, rgb):
    def chunk(t, d):
        c = t + d
        return struct.pack('>I', len(d)) + c + struct.pack('>I', zlib.crc32(c) & 0xffffffff)
    raw = b''
    for y in range(h):
        raw += b'\x00'
        for x in range(w):
            raw += bytes([(rgb[0]+x*255//w)%256, (rgb[1]+y*255//h)%256, rgb[2]])
    open(path,'wb').write(b'\x89PNG\r\n\x1a\n'
        + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0))
        + chunk(b'IDAT', zlib.compress(raw, 6)) + chunk(b'IEND', b''))
for i, c in enumerate([(220,60,60),(60,160,220),(240,200,60),(120,220,120)]):
    png(f'/tmp/test-{i}.png', 800, 1000, c)
"
xcrun simctl addmedia booted /tmp/test-*.png
```

### 1-4 重設照片權限

測試授權流程時需要讓 App 回到「尚未詢問」狀態：

```bash
xcrun simctl privacy booted reset photos com.picdeck.app
```

⚠️ **注意**：`xcrun simctl privacy booted grant photos com.picdeck.app` 這個「直接授權」指令在 iOS 18 模擬器上**對 PhotoKit 無效**，App 仍會讀到「尚未授權」。要授權只能在畫面上實際點按，或用下面的自動化測試。

### 1-5 截圖與錄影

```bash
xcrun simctl io booted screenshot ~/Desktop/picdeck.png
xcrun simctl io booted recordVideo ~/Desktop/picdeck.mp4   # Ctrl+C 停止
```

### 1-6 自動化冒煙測試

專案內建 `PicDeckUITests`，會自動走完：授權 → 照片首頁 → 月曆檢視 → 點年份跳到月 → 點月份跳到日 → 點某天跳到時間軸 → 時間軸子分頁 → 重啟驗證記憶子分頁 → 資料夾分頁 → 整理分頁 → 點月份進審核 → 保留 → 右滑回上一張 → 幫助 → 刪除 → 待刪清單，全程自動截圖。測試也會驗證右滑不會誤觸系統的「滑回上一頁」，以及全部子分頁的多選：勾選後底部要出現寫日記／標籤／最愛／加到相冊，批次加入最愛後會自動離開多選，批次寫日記會把勾選的照片預先帶進編輯畫面。

```bash
cd /Library/WebServer/Documents/photo-app/PicDeck

# 跑之前先重設權限，否則會卡在已拒絕狀態
xcrun simctl privacy booted reset photos com.picdeck.app

xcodebuild test -scheme PicDeck \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -resultBundlePath /tmp/picdeck-test.xcresult
```

看到 `** TEST SUCCEEDED **` 就是全部通過。

只想驗剛改的部分時，不必跑整份流程（整份約三分半）。用 `-only-testing` 指定單一測試：

```bash
xcodebuild test-without-building -scheme PicDeck \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:PicDeckUITests/PicDeckSmokeTests/testDuplicateTagNameIsRejected \
  -resultBundlePath /tmp/picdeck-tag.xcresult
```

目前有兩個測試：

| 測試 | 涵蓋範圍 | 約略耗時 |
| --- | --- | --- |
| `testCoreFlow` | 完整流程，含多選與批次操作 | 3.5 分鐘 |
| `testDuplicateTagNameIsRejected` | 只驗標籤名稱不可重複 | 45 秒 |
| `testAnniversaryTagAndJournalLayout` | 紀念日換算、只在篩選時顯示、日記卡片版面 | 2 分鐘 |
| `testIconPickerAndLibraryManager` | 圖示選擇器與管理相簿／標籤 | 85 秒 |

圖示存成一個字串，所以舊資料不用搬：表情符號直接存字元本身，系統圖示存成 `sf:<名稱>#<顏色>`，空字串代表沒有圖示。

`testAnniversaryTagAndJournalLayout` 用啟動參數 `-seedAnniversaryTag` 先放一個 2020/8/5 起算、名叫「堯」的標籤，免得在測試裡操作日期選擇器。正常啟動不會執行這段。測試會自己用 `Calendar` 算一次五種換算，再跟畫面上的數字對，所以不綁定執行日期。

換算的定義（與市面上的紀念日 App 一致，以 2020/8/5 到 2026/9/20 為例）：

| 方式 | 結果 | 說明 |
| --- | --- | --- |
| D-day | D+2237 | 起算日當天是 D+0 |
| 日數 | 2238 天 | 起算日當天算第 1 天，比 D-day 多一天 |
| 週數 | 319 週 5 天 | 由日數換算 |
| 月數 | 73 個月 15 天 | 由月曆的月份差換算 |
| 年、月、日 | 6 年 1 個月 15 天 | 由月曆的年月日差換算 |

先跑過一次 `build-for-testing` 之後，改測試碼再用 `test-without-building` 可以省下重新編譯的時間。

把測試過程的截圖抓出來：

```bash
rm -rf /tmp/shots && mkdir -p /tmp/shots
xcrun xcresulttool export attachments \
  --path /tmp/picdeck-test.xcresult --output-path /tmp/shots
open /tmp/shots
```

最近一次通過的截圖已存在 `docs/dev/screenshots/`。

### 1-7 桌機測試常見問題

| 症狀 | 原因與解法 |
| --- | --- |
| 一直停在權限畫面，按鈕寫「前往設定」 | 之前被拒絕過。執行 `xcrun simctl privacy booted reset photos com.picdeck.app` 後重開 App |
| 整理畫面沒有照片 | 模擬器相簿是空的，用 1-3 灌照片 |
| 測試在「來源列表沒有出現」失敗 | 權限沒重設，跑測試前先執行 1-4 |
| `xcodebuild` 找不到模擬器 | 用 `xcrun simctl list devices available` 查可用名稱，替換 `name=` 後面的字 |
| 編譯結果找不到 `.app` | DerivedData 路徑會變，用 1-2 的 `find` 指令動態取得 |

---

## 二、手機 Demo（裝到自己的 iPhone）

### 2-1 你需要什麼

| 項目 | 說明 |
| --- | --- |
| iPhone | iOS 17.0 以上 |
| 傳輸線 | USB 連接 Mac（第一次必須用線，之後可改無線） |
| Apple ID | 免費帳號即可，不必付 99 美元／年 |

**免費帳號的限制**：App 憑證 7 天後過期，過期就打不開，要重新用 Xcode 安裝一次。想給別人測試或要長期使用，才需要付費的 Apple Developer Program。

### 2-2 第一次設定（只需做一次）

**步驟 1：在 Xcode 加入你的 Apple ID**

1. 打開 Xcode → 選單列 **Xcode → Settings**（或 ⌘,）
2. 切到 **Accounts** 分頁 → 左下角 **+** → 選 **Apple ID** → 登入

**步驟 2：設定簽章**

1. 打開 `PicDeck.xcodeproj`
2. 左側點最上面藍色的 **PicDeck** 專案圖示
3. 中間 TARGETS 選 **PicDeck** → 上方分頁選 **Signing & Capabilities**
4. 勾選 **Automatically manage signing**
5. **Team** 下拉選你的 Apple ID（會顯示成「你的名字 (Personal Team)」）
6. 如果出現紅字說 Bundle Identifier 已被使用，把 **Bundle Identifier** 改成獨一無二的字串，例如 `com.你的名字.picdeck`

**步驟 3：iPhone 開啟開發者模式**

1. 用線把 iPhone 接上 Mac
2. iPhone 會跳出「信任這台電腦？」→ 點 **信任** → 輸入密碼
3. iPhone 上打開 **設定 → 隱私權與安全性 → 開發者模式** → 打開 → 重新啟動手機
4. 重開機後會再問一次是否啟用，點 **打開**

> 找不到「開發者模式」選項？先用 Xcode 對這支手機執行一次，選項就會出現。

### 2-3 安裝到手機

1. Xcode 上方裝置選單，從模擬器改選你的 **iPhone 名稱**
2. 按 **⌘R**
3. 第一次會失敗並顯示「Untrusted Developer」，這是正常的
4. iPhone 上打開 **設定 → 一般 → VPN 與裝置管理** → 點你的 Apple ID → 點 **信任**
5. 回到 Xcode 再按一次 **⌘R**

App 圖示就會出現在 iPhone 主畫面，之後可以直接點開，不用接電腦。

### 2-4 Demo 時的注意事項

- **第一次開會要求照片權限**，請選「**允許完整取用**」。選「限制取用」只會看到你挑的那幾張。
- **上滑標記的照片不會馬上消失**，要到「待刪」分頁按「永久刪除」才會真的刪掉，刪掉後仍會進 iOS「最近刪除」，30 天內可救回。
- **免費版每天 30 張**。Demo 時若想解除限制，到「設定 → 解鎖 PicDeck → 以 NT$99 贊助開發」，目前是本機模擬解鎖，不會扣款。要還原成免費版，點「設定 → 重設解鎖狀態（測試用）」。
- **「歸檔」會在 iOS 照片 App 真的建立同名相簿**，Demo 前可先建幾個資料夾（如購物、旅行）比較有畫面。
- **按錯了可以右滑回上一張**，會一併撤銷剛才的動作。右滑請從卡片中間開始，太靠左邊會觸發 iOS 系統的「滑回上一頁」。
- **左滑是保留**，代表這張已整理過，之後不會再出現在未整理清單。跟刪除不同，照片不會被刪掉。
- **7 天後 App 會失效**（免費帳號限制），重接電腦按 ⌘R 重裝即可。

### 2-5 無線安裝（設定過一次後）

1. iPhone 接上線，Xcode 選單 **Window → Devices and Simulators**
2. 選你的 iPhone，勾選 **Connect via network**
3. 拔掉線，之後同一個 Wi-Fi 下就能直接按 ⌘R 安裝

### 2-6 給別人測試（TestFlight）

要讓朋友或測試者裝，需要付費的 Apple Developer Program（99 美元／年），流程是：

1. Xcode 選單 **Product → Archive**
2. Archive 完成後在 Organizer 視窗點 **Distribute App → TestFlight & App Store**
3. 上傳後到 [App Store Connect](https://appstoreconnect.apple.com) 的 TestFlight 分頁
4. 新增測試人員的 Email，對方會收到邀請信，用 TestFlight App 安裝

依企劃書規劃，測試期間買斷價是 NT$99（開發贊助），之後才漲到早鳥 NT$249、正式 NT$499。

---

## 三、目前版本做了什麼

v0.1.0 已實作的核心流程：

| 功能 | 狀態 |
| --- | --- |
| 照片權限請求與說明畫面 | 完成 |
| 照片分頁為首頁，開啟直接顯示所有照片 | 完成 |
| 子分頁：年、月、日、時間軸、全部 | 完成 |
| 月檢視為月曆卡片，標示有照片的日期與今天 | 完成 |
| 日檢視為月曆格狀（週日起始），每格顯示當天首張照片與張數 | 完成 |
| 子分頁會記住上次選的項目 | 完成 |
| 點年份／月份／某天會切換子分頁並定位，不推入新畫面，分頁列全程保留 | 完成 |
| 子分頁：日記（付費） | 完成（僅呈現，不提供寫日記） |
| 篩選：所有項目、喜好項目、照片、影片、截圖（付費） | 完成 |
| 長按照片的操作選單：寫日記、標籤、喜愛、加到相冊（子選單） | 完成 |
| 自訂標籤：長按照片或審核畫面加標籤（免費）、標籤篩選（付費）、更多分頁管理標籤 | 完成 |
| 標籤名稱不可重複，忽略前後空白與大小寫、全形半形差異，改名也擋重複 | 完成 |
| 標籤紀念日：起算日 + 五種換算（D-day、日數、週數、月數、年月日） | 完成 |
| 共用圖示選擇器：表情符號／系統圖示兩頁、搜尋、隨機、移除、最近使用、圖示配色 | 完成 |
| 日記心情與標籤符號共用同一個選擇器 | 完成 |
| 更多 → 管理相簿與標籤；資料夾分頁右上角也有同一個入口 | 完成 |
| 相簿新增、改名、刪除（刪相簿不刪照片），同名相簿擋下來 | 完成 |
| 紀念日只在篩選到該標籤時顯示（時間軸日期標題與日記卡片），沒篩選維持原樣 | 完成 |
| 日記卡片版面：心情圓標、日期星期、紀念日、長文收合、一排四張方形照片 | 完成 |
| 多選：全部與時間軸右上角的選擇按鈕，可批次寫日記、加標籤、加入最愛、加到相冊 | 完成 |
| 批次寫日記只在同一天時出現；批次加入最愛會跳過原本就已是最愛的照片 | 完成 |
| 長按照片選寫日記時，該張照片預設已勾選 | 完成 |
| 日記：一天一篇，含心情表情、文字與自選照片，日檢視格子右上角顯示心情 | 完成 |
| 日記分頁只列有日記的日子，一排四張照片，超過四張標示 +N | 完成 |
| 資料夾分頁：列出本機相簿 | 完成 |
| 整理分頁：三個固定入口（付費）＋ 月＋年分組（免費） | 完成 |
| 逐張審核：左滑保留、右滑回上一張、上滑刪除、下拉喜愛、雙擊放大 | 完成 |
| 幫助說明與手勢教學 | 完成 |
| 歸檔到本機相簿 | 完成 |
| 兩階段刪除（待刪清單 → 確認 → iOS 最近刪除） | 完成 |
| 每日 30 張額度，付費解除 | 完成 |
| 繁體中文 / 英文雙語 | 完成 |
| 深色／淺色模式跟隨系統 | 完成 |

尚未實作，留待後續：

- **StoreKit 實際金流**：目前「解鎖」只在本機記錄，不會扣款。
- **地圖分頁**：延後到 V2。
- **日記的照片與相簿無關**：日記附的照片只是引用，不會被加進任何相簿，刪掉照片後該篇日記的縮圖會少一張。
- **多裝置同步已整理狀態**：保留紀錄目前只存在本機，換裝置不會同步，之後接 CloudKit。
- **iOS 27 設計語言**：目前 Xcode 只有 iOS 18.5 SDK，等 Xcode 更新後才能採用 iOS 27 的新元件。
- **iPad 版面**：目前只做 iPhone 直式。
- **V2 功能**：批次壓縮、OCR 複製截圖文字、日曆視圖。

---

## 四、常用指令速查

```bash
# 專案位置
cd /Library/WebServer/Documents/photo-app/PicDeck

# 編譯
xcodebuild -scheme PicDeck -destination 'platform=iOS Simulator,name=iPhone 16' build

# 跑自動化測試（記得先重設權限）
xcrun simctl privacy booted reset photos com.picdeck.app
xcodebuild test -scheme PicDeck -destination 'platform=iOS Simulator,name=iPhone 16'

# 模擬器操作
xcrun simctl list devices available          # 列出可用模擬器
xcrun simctl boot "iPhone 16"                # 開機
xcrun simctl addmedia booted ~/圖片/*.jpg     # 灌照片
xcrun simctl io booted screenshot out.png    # 截圖
xcrun simctl erase "iPhone 16"               # 清空模擬器（會刪掉照片與 App 資料）

# 查看接上的實體裝置
xcrun devicectl list devices
```
