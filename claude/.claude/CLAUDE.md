@RTK.md

# 委派 subagent（節省用量）

`~/.claude/agents/` 定義了 `fixer`（sonnet，改程式碼）、`build`（haiku，跑測試與指令）、`observer`（sonnet，看圖與 PDF）。以下情況使用者授權主 agent 自行派遣，不必每次詢問：

- **改程式碼 → `fixer`**：已確定要改哪些檔案、怎麼改、怎麼驗證時派出。
- **跑指令 → `build`**：測試、lint、`DRY_RUN`、或使用者已授權的長時間腳本。
- **看圖、PDF → `observer`**：只需要從中取出特定資訊時。

主 agent 自己做，不派：

- subagent 必須讀大量 repo 脈絡才能動手（對話中已有的脈絡不會自動共享，重讀反而更耗用量）。
- 改動只有一兩處、或比寫派遣說明還短。
- subagent 卡在最後幾步達不到標準：主 agent 直接補完，不重派。

派出時 prompt 必須寫清楚：檔案路徑、要改什麼（或要跑什麼）、驗收指令、不能碰的範圍。回來後由主 agent 驗收（看 diff、跑驗收指令）再回報使用者；同一工作延續時優先用 SendMessage 續接原 agent。

## Workflow（ultracode）的模型分配

Workflow 的 `agent()` 不指定 `model` 時會繼承主模型，大量派出很快用完 5 小時額度。因此：

- **預設每個 `agent()` 都寫 `model: 'sonnet'`**：閱讀、搜尋、抽取、合併、一般複核與彙整都用 Sonnet；純機械性步驟可用 `'haiku'`。
- **Opus 只給真正重要的少數 agent**：使用者會據以做決定的最終判斷、困難的反駁複核。啟動前說明哪幾個用 Opus。也可以讓 Sonnet 產出後，由主 agent（Opus）親自讀一遍抽查，不另開 Opus agent。
- **大量工作分小批**：先跑最有價值的一批，每個 agent 完成就把結果寫入檔案，下一批再依結果決定範圍；撞到額度上限時已落檔的部分不會丟。不要一次排上百個 agent。
- 輸出寫到持久位置（例如專案內的 `scratch/`），不要只放在 session 暫存目錄。

# skill 的 Python 工具

系統 `python3` 與 `~/.venv` 都沒有這些 skill 的依賴。執行 skill 文件裡的 Python 指令時，一律寫成 `uv run --project <skill 根目錄> python <腳本絕對路徑> ...`，其餘參數照文件：

| skill | `<skill 根目錄>` | 文件裡的腳本路徑 → 絕對路徑 |
|---|---|---|
| hung-yi-lee-ai-mentor-skills | `~/.agents/skills/hung-yi-lee-ai-mentor-skills` | `hung-yi-lee-ai-mentor-skills/...` → `~/.agents/skills/hung-yi-lee-ai-mentor-skills/...` |
| ppt-master | `~/.agents/skills/ppt-master` | `skills/ppt-master/...` → `~/.agents/skills/ppt-master/...` |
