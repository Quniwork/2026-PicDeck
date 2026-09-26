# PicDeck 專案開發與規格文件總覽（Documentation Hub）

> **維護目的**：本文件為 PicDeck 專案的唯一文件導覽索引中心。為確保團隊成員與各 AI 工具（Gemini Antigravity、Claude Code、Codex 等）切換時皆能快速取得最新且正確的專案知識，特將全專案文件分類編目如下。

---

## 快速導航與權威分級（Document Hierarchy）

```
[ 權威規範 (SSOT) ] ──> docs/product/PicDeck功能與操作規範.md（最高準則，動工必讀）
         │
         ├─── [ AI 代理指令 ] ──> AGENTS.md / CLAUDE.md / .cursorrules（切換工具自動載入）
         ├─── [ 開發與測試 ] ──> docs/dev/（真機安裝、模擬器指令、自動化測試）
         ├─── [ 產品企劃案 ] ──> docs/product/（商業化、功能演進路線圖、歷史提案）
         └─── [ 競品與歷史 ] ──> docs/app-analysis/ & docs/dev/UIUX檢查報告.md
```

---

## 一、核心權威規範（Single Source of Truth, SSOT）

任何程式碼修改、手勢調整、佈局重構前，**必須優先查閱本檔案**；若有規範變更，必須獲得使用者確認後同步更新此手冊。

| 檔案路徑 | 狀態 | 權威層級 | 內容說明 |
| :--- | :---: | :---: | :--- |
| [`docs/product/PicDeck功能與操作規範.md`](product/PicDeck功能與操作規範.md) | **最新生效** | **最高準則** | 全專案功能定義、手勢分層（單圖下滑不關閉）、五大主分頁、網格滑動連選、直角相片、色彩模式、iCloud 同步與變更確認機制。 |
| [`docs/product/PicDeck與iOS系統照片庫功能結合與PhotoKit同步全覽.md`](product/PicDeck與iOS系統照片庫功能結合與PhotoKit同步全覽.md) | **最新生效** | **技術核心** | 系統照片.app 資料映射藍圖、PhotoKit 所有已啟用與可擴充之雙向同步功能清單（說明 Caption、關鍵字 Keywords、喜愛、相簿等），含 Apple 官方 SDK 來源檔案與方法簽名。 |

---

## 二、AI 代理指引文件（跨工具切換入口）

無論使用何種 AI 工具，啟動時皆會自動讀取對應的指引檔案，並統一受上方《功能與操作規範》約束：

| 檔案名稱 | 適用工具 | 狀態 | 內容說明 |
| :--- | :--- | :---: | :--- |
| [`AGENTS.md`](../AGENTS.md) | **Gemini (Antigravity)** / 通用代理 | **最新生效** | 三台目標設備部署指令、繁體中文規則、單圖與全部網格核心不變防禦機制、卡頓排查順序。 |
| [`CLAUDE.md`](../CLAUDE.md) | **Claude (Claude Code)** | **最新生效** | Claude Code 專屬啟動規則、常用 CLI 指令、規範優先機制與設備自動驗證步驟。 |
| [`.cursorrules`](../.cursorrules) | **Codex / Cursor / Windsurf** | **最新生效** | Cursor 與 OpenAI Codex 專屬代理規則，統一核心防禦原則與指令集。 |

---

## 三、開發與測試指南（Development & Testing）

工程實作、設備除錯、自動化測試與發布指南：

| 檔案路徑 | 狀態 | 適用對象 | 內容說明 |
| :--- | :---: | :--- | :--- |
| [`docs/dev/真機安裝與測試指南.md`](dev/真機安裝與測試指南.md) | **有效** | 開發者 / 測試者 | 實體 iPhone 14 Pro Max 安裝、免費帳號憑證、真機權限測試與常見問題排除。 |
| [`docs/dev/測試與Demo指南.md`](dev/測試與Demo指南.md) | **有效** | 開發者 | 模擬器快速啟動、展示測試流程與 UI 冒煙測試執行。 |
| [`docs/dev/TestFlight測試指南.md`](dev/TestFlight測試指南.md) | **有效** | 發布管理 | App Store Connect 打包、上傳 TestFlight、內部/外部測試員邀請步驟。 |
| [`docs/dev/ai-memory-繁體中文使用說明.md`](dev/ai-memory-繁體中文使用說明.md) | **工具指引** | AI 輔助開發 | 跨 AI 代理（Codex / Claude）共用專案記憶工具的安裝與設定教學。 |

---

## 四、產品企劃與商業化方案（Product Planning）

產品歷史背景、商業規劃與長線架構設計：

| 檔案路徑 | 狀態 | 內容說明 |
| :--- | :---: | :--- |
| [`docs/product/PicDeck 產品企劃.md`](product/PicDeck%20產品企劃.md) | **基礎規劃** | 專案起源定位、核心三層架構（照片庫、整理卡牌、標籤日記）、MVP 範圍。 |
| [`docs/product/PicDeck 上架前商業化與計費方案調整建議書.md`](product/PicDeck%20上架前商業化與計費方案調整建議書.md) | **規劃建議** | 免費額度設計、內購贊助買斷制、進階功能解鎖與商業化策略。 |
| [`docs/product/PicDeck 效能瓶頸與版本控制優化解決方案文件.md`](product/PicDeck%20效能瓶頸與版本控制優化解決方案文件.md) | **技術歷史** | 大圖庫記憶體、縮圖非同步載入、LazyVGrid 排版卡頓排查報告與 Git 最佳實踐。 |

---

## 五、競品分析與設計參考（Competitive Analysis & History）

專案初期對標三款競品之優缺點分析與歷史設計報告：

| 檔案路徑 | 狀態 | 內容說明 |
| :--- | :---: | :--- |
| [`docs/app-analysis/Slidebox 功能分析.md`](app-analysis/Slidebox%20功能分析.md) | 參考封存 | Slidebox 手勢整理、垃圾桶安全機制與相簿分類分析。 |
| [`docs/app-analysis/Clutter 功能分析.md`](app-analysis/Clutter%20功能分析.md) | 參考封存 | Clutter 清理邏輯、日曆視圖與統計功能分析。 |
| [`docs/app-analysis/相冊助手 功能分析.md`](app-analysis/相冊助手%20功能分析.md) | 參考封存 | 相冊助手之分類、壓縮與清理體驗評估。 |
| [`docs/app-analysis/Sub Camera 功能分析.md`](app-analysis/Sub%20Camera%20功能分析.md) | 參考封存 | 專屬相機與標籤照片流設計分析。 |
| [`docs/dev/UIUX檢查報告.md`](dev/UIUX檢查報告.md) | 歷史檢測 | 2026-09-20 ~ 2026-09-23 期間之 Apple HIG 檢查與滾動佈局測試紀錄。 |
