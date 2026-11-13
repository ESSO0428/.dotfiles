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

# skill 的 Python 工具

系統 `python3` 與 `~/.venv` 都沒有這些 skill 的依賴。執行 skill 文件裡的 Python 指令時，一律寫成 `uv run --project <skill 根目錄> python <腳本絕對路徑> ...`，其餘參數照文件：

| skill | `<skill 根目錄>` | 文件裡的腳本路徑 → 絕對路徑 |
|---|---|---|
| hung-yi-lee-ai-mentor-skills | `~/.agents/skills/hung-yi-lee-ai-mentor-skills` | `hung-yi-lee-ai-mentor-skills/...` → `~/.agents/skills/hung-yi-lee-ai-mentor-skills/...` |
| ppt-master | `~/.agents/skills/ppt-master` | `skills/ppt-master/...` → `~/.agents/skills/ppt-master/skills/ppt-master/...` |
