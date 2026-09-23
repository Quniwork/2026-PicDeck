# ai-memory 安裝與簡易使用說明

適用：macOS 終端機、Codex CLI、Claude Code。整理日期：2026 年 9 月 22 日。

這份說明採 Mac 原生安裝。指令請貼到「終端機」執行；文中的對話範例則貼到 AI 對話內。這是操作教學，尚未在你的 Mac 上執行安裝。Windows 請改看文末官方平台文件。

## 1 認識用途

ai-memory 為程式開發 AI 保存專案知識與交接內容，可供不同代理查詢。基本模式不用設定額外模型 API 金鑰；你原本使用 Codex 或 Claude 的帳號需求仍照舊。

兩個整合都要安裝：MCP 讓 AI 讀寫記憶，hooks 負責在工作過程中收集事件。以下先以 CLI 為準，不推定 VS Code 擴充套件或網頁版有完全相同的生命週期支援。[1][3]

## 2 下載程式

在 Mac 按 Command＋空白鍵，搜尋「終端機」。先查看晶片：

```bash
uname -m
```

- `arm64`：選 Apple Silicon，例如 M1、M2、M3 等。
- `x86_64`：通常選 Intel；若 M 系列 Mac 的終端機透過 Rosetta 執行，請以「關於這台 Mac」顯示的晶片為準。

建立安裝位置：

```bash
mkdir -p "$HOME/Applications/ai-memory"
cd "$HOME/Applications/ai-memory"
```

**Apple Silicon 執行這組：**

```bash
curl -fL -o package.tar.gz \
  https://github.com/akitaonrails/ai-memory/releases/latest/download/ai-memory-macos-aarch64.tar.gz
tar -xzf package.tar.gz
```

**Intel 執行這組，兩組擇一：**

```bash
curl -fL -o package.tar.gz \
  https://github.com/akitaonrails/ai-memory/releases/latest/download/ai-memory-macos-x86_64.tar.gz
tar -xzf package.tar.gz
```

下載失敗就先停下，不要繼續解壓縮。請完整保留解壓縮後的資料夾，hooks 也會用到其中的檔案。[2]

## 3 初始化並啟動服務

接著在同一個終端機執行：

```bash
./ai-memory --version
./ai-memory init
./ai-memory serve --transport http --bind 127.0.0.1:49374 --enable-web
```

**這個視窗要保持開著。** 最後一行是持續執行的服務，沒有回到輸入提示符是正常現象。`init` 只建立資料，不會啟動服務。[2]

## 4 接上你的 AI 工具

按 Command＋T 開新分頁。先執行：

```bash
cd "$HOME/Applications/ai-memory"
./ai-memory status
```

能取得狀態後，依照工具選一組；兩個都有使用就兩組都裝。

**Codex CLI：**

```bash
./ai-memory install-mcp --client codex --apply
./ai-memory install-hooks --agent codex --apply
```

**Claude Code：**

```bash
./ai-memory install-mcp --client claude-code --apply
./ai-memory install-hooks --agent claude-code --apply
```

完成後關閉並重新開啟 AI CLI，讓設定重新載入。安裝指令會變更對應工具設定；專案說明指出會建立帶時間戳的備份。[1][3]

## 5 確認真的有記住

在新分頁進入「你的程式專案」，不是 ai-memory 安裝資料夾。下面路徑要換成實際位置：

```bash
cd "/你的專案完整路徑"
```

接著啟動其中一個：

```bash
codex
```

或：

```bash
claude
```

在 AI 對話中輸入：

> 請呼叫 ai-memory 的 memory_status，確認連線與目前專案。然後用 memory_write_page 保存一筆測試記憶：本專案記憶測試代號為「藍色資料夾 0922」。請回報寫入結果。

正常離開，再從同一個專案資料夾開新對話，輸入：

> 請使用 ai-memory 的 memory_query 查詢，本專案的記憶測試代號是什麼？請依實際查詢結果回答。

查到代號代表跨對話讀寫可用。另在終端機重新執行下列指令，觀察工作前後的 sessions／observations 計數，檢查 hooks 是否也有收集事件：

```bash
"$HOME/Applications/ai-memory/ai-memory" status
```

手動寫入成功，不代表自動收集也必定成功；這兩項分開確認。[3][4]

## 6 每天怎麼使用

每次開機後，先在終端機啟動服務：

```bash
"$HOME/Applications/ai-memory/ai-memory" serve \
  --transport http --bind 127.0.0.1:49374 --enable-web
```

再用另一個分頁進入專案，啟動 Codex 或 Claude。若服務已在執行，不用重複啟動。

可以在對話中這樣說：

- 接續工作：「請查詢 ai-memory，告訴我這個專案上次做到哪裡。」
- 查以前決定：「請用 memory_query 查詢，我們為什麼選這個做法？」
- 保存長期知識：「請用 memory_write_page 記錄這個專案的圖片上傳流程。」
- 結束前交接：「請用 memory_handoff_begin 保存已完成項目、未完成項目、遇到的問題與下一步。」

若要從 Claude 換到 Codex，先保存交接、結束原對話，再從同一專案資料夾開另一工具。Codex CLI 0.145.0 以上有原生 SessionEnd 整合；舊版本或不確定退出是否成功時，可在離開前用上述手動交接方式。[3][4]

## 7 查看記憶與常見問題

服務使用 `--enable-web` 啟動後，在瀏覽器開啟：

http://127.0.0.1:49374/web

這是唯讀記憶頁面。剛安裝時沒有頁面屬正常；先完成上面的測試。[4]

| 現象 | 處理方式 |
| --- | --- |
| Connection refused | 先執行第 3 節的 serve，並保持視窗開著。 |
| Address already in use | 49374 可能已有服務；先執行 status 確認，不要再啟動一份。 |
| command not found | 本說明使用完整路徑；若用 `./ai-memory`，必須先進入安裝資料夾。 |
| could not locate hooks directory | 重新完整解壓縮官方壓縮檔，從安裝資料夾執行安裝 hooks 指令。 |
| AI 看不到 memory 工具 | 確認 MCP 安裝對應的工具正確，並重開該 CLI。 |
| 有工具卻查不到記憶 | 確認是同一專案，先跑第 5 節讀寫測試，再檢查事件計數。 |

要停止手動啟動的服務，在該視窗按 Control＋C。服務停止期間無法正常使用記憶功能。若希望登入 Mac 後自動啟動，官方 macOS 文件的「Run as a Login Service」提供進階設定。[2]

## 8 範圍與資料

這份教學先不設定 LLM provider。舊專案的 `bootstrap` 匯入需要額外設定模型供應者，所以不要把它當成本教學的必做步驟。[4]

預設 Mac 資料位置是 `~/Library/Application Support/ai-memory`。程式安裝與記憶資料是兩個位置；重新開機不會直接刪除已保存的資料。這份流程只開放本機連線，未設定跨電腦同步。[1][2]

## 官方資料來源

以下依查閱當日文件整理；更新版本後若指令不同，以官方文件及 `--help` 為準。

1. 專案首頁：https://github.com/akitaonrails/ai-memory
2. Mac 安裝：https://github.com/akitaonrails/ai-memory/blob/main/docs/macos.md
3. MCP 與各工具整合：https://github.com/akitaonrails/ai-memory/blob/main/docs/mcp-install.md
4. 日常使用：https://github.com/akitaonrails/ai-memory/blob/main/docs/usage.md
5. Windows 安裝：https://github.com/akitaonrails/ai-memory/blob/main/docs/windows.md
