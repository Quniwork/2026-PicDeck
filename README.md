# PicDeck（相牌）

一款整合式 iOS 相簿整理 App。目前已完成 v0.1.0 可執行版本，核心整理流程可用。專案資料夾名稱沿用 `photo-app`，App 正式名稱為 **PicDeck**。

## 快速開始

```bash
cd /Library/WebServer/Documents/photo-app/PicDeck
open PicDeck.xcodeproj    # 在 Xcode 開啟，選模擬器按 ⌘R
```

詳細的桌機測試與手機 Demo 步驟見 [`docs/dev/測試與Demo指南.md`](docs/dev/測試與Demo指南.md)。

## 專案結構

```
photo-app/
├── README.md                       本檔案
├── PicDeck/                        iOS App 專案
│   ├── PicDeck.xcodeproj
│   ├── PicDeck/                    App 原始碼
│   │   ├── Models/                 PhotoSource、Folder
│   │   ├── Services/               PhotoLibraryService、AppModel
│   │   ├── Views/                  各畫面
│   │   └── Localizable.xcstrings   繁中／英文字串
│   └── PicDeckUITests/             自動化冒煙測試
└── docs/
    ├── app-analysis/               競品功能分析
    │   ├── 相冊助手 功能分析.md
    │   ├── Slidebox 功能分析.md
    │   └── Clutter 功能分析.md
    ├── product/
    │   └── PicDeck 產品企劃.md      功能取捨、定價、路線圖
    └── dev/
        ├── 測試與Demo指南.md        桌機測試與手機安裝步驟
        └── screenshots/            最近一次測試通過的畫面截圖
```

## 目前狀態

- [x] 競品研究（相冊助手、Slidebox、Clutter）
- [x] 整合式產品企劃
- [x] App 名稱確定：PicDeck（相牌），已查無 App Store 撞名
- [x] v0.1.0 可執行版本：核心整理流程、雙語、深淺色模式
- [x] 自動化 UI 冒煙測試
- [ ] StoreKit 實際金流
- [ ] V2 功能（批次壓縮、OCR、日曆視圖、iPad 版面）

## 技術重點

- **SwiftUI + PhotoKit**，最低支援 iOS 17.0，開發環境 Xcode 16.4 / iOS 18.5 SDK。
- **所有結果寫回系統相簿**：刪除、最愛、歸檔都透過 PhotoKit 同步，App 不另存實體照片。
- **只用系統內建能力**：來源篩選走 PhotoKit 系統相簿與資產屬性，不自建相似度或重複偵測演算法。
- **純本機處理**：照片不上傳任何伺服器。
