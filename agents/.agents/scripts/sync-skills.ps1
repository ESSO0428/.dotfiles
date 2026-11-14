#Requires -Version 7
<#
.SYNOPSIS
  Windows 版 sync-skills：管理 ~/.agents/skills.list，並補裝這台缺少的 skill（只補不刪）

.DESCRIPTION
  和 bash 版 sync-skills 共用同一份 skills.list，功能相同：
    sync-skills.ps1            互動模式（需要 fzf）：add 把這台的 skill 加進清單 / install 補裝 / remove 從清單移除
                               沒有 fzf 或不在終端機時，等同 -Install
    sync-skills.ps1 -Install   補裝清單裡有、這台沒裝的 skill，再把 skill 連到 ~/.claude/skills
    sync-skills.ps1 -Diff      只列出差異：清單有但沒裝 / 有裝但不在清單
    sync-skills.ps1 -Export    用這台的安裝狀態覆寫整份清單（只在主力機上跑，跑完用 git diff 檢查）
  加上 -WhatIf 只顯示會執行的指令。

  清單格式（# 開頭為註解）：
    <source>  <skill>
    mattpocock/skills  grilling
#>
[CmdletBinding(SupportsShouldProcess)]
param(
  [switch]$Install,
  [switch]$Diff,
  [switch]$Export,
  # 強制互動模式（自動判斷失準時用，例如從 WSL 呼叫 pwsh.exe）
  [switch]$Interactive,
  # 內部用：fzf 預覽
  [string]$Preview = '',
  [string]$PreviewSource = '',
  [string]$HomeDir = $HOME,
  [string]$List = ''
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()
if (-not $List) { $List = Join-Path $HomeDir '.agents\skills.list' }
$Lock = Join-Path $HomeDir '.agents\.skill-lock.json'
$SkillsDir = Join-Path $HomeDir '.agents\skills'
$Linker = Join-Path $PSScriptRoot 'link-claude-skills.ps1'

function Assert-List {
  if (-not (Test-Path -LiteralPath $List)) { throw "找不到清單 $List，請先執行 install.ps1 agents" }
}

# 已安裝的 skill：@{ skill = source }
function Get-Installed {
  $map = [ordered]@{}
  if (Test-Path -LiteralPath $Lock) {
    $lockJson = Get-Content -LiteralPath $Lock -Raw | ConvertFrom-Json
    foreach ($p in $lockJson.skills.PSObject.Properties) { $map[$p.Name] = $p.Value.source }
  }
  return $map
}

# 清單內容：@{ skill = source }
function Get-Wanted {
  Assert-List
  $map = [ordered]@{}
  foreach ($line in Get-Content -LiteralPath $List) {
    $f = @(($line -replace '#.*', '').Trim() -split '\s+' | Where-Object { $_ })
    if ($f.Count -ge 2) { $map[$f[1]] = $f[0] }
  }
  return $map
}

# 對照：State（both / missing / extra）、Source、Skill
function Get-States {
  $w = Get-Wanted; $i = Get-Installed
  $rows = foreach ($s in $w.Keys) {
    [pscustomobject]@{ State = $(if ($i.Contains($s)) { 'both' } else { 'missing' }); Source = $w[$s]; Skill = $s }
  }
  $rows += foreach ($s in $i.Keys) {
    if (-not $w.Contains($s)) { [pscustomobject]@{ State = 'extra'; Source = $i[$s]; Skill = $s } }
  }
  return $rows | Sort-Object Skill
}

function Format-Line($source, $skill) { '{0,-24} {1}' -f $source, $skill }

# LIST 可能是 symlink：用 WriteAllLines 寫回原檔，不會換掉連結；統一 LF，和 Linux 共用
function Set-ListContent([string[]]$lines) {
  if ($PSCmdlet.ShouldProcess($List, '寫入清單')) {
    [IO.File]::WriteAllText($List, (($lines -join "`n") + "`n"))
  }
}

# 依來源分組安裝，最後重建 ~/.claude/skills 的連結
function Install-Skills($rows) {
  foreach ($g in $rows | Group-Object Source) {
    # 不用 $args：那是 PowerShell 的自動變數
    $npxArgs = @('-y', 'skills', 'add', $g.Name, '-g', '-y')
    foreach ($r in $g.Group) { $npxArgs += '-s', $r.Skill }
    Write-Host "+ npx $($npxArgs -join ' ')"
    if ($PSCmdlet.ShouldProcess("npx $($npxArgs -join ' ')", '安裝')) {
      & npx @npxArgs
      $code = $LASTEXITCODE
      if ($code -ne 0) {
        # 失敗通常是環境問題（例如 Node.js 太舊），後面每一組都會一樣失敗，直接停下來
        # 先存 exit code：下面執行 node --version 會覆蓋 $LASTEXITCODE
        $node = (& node --version 2>$null)
        Write-Warning "npx skills add 失敗（exit $code），已停止，剩下的 skill 沒有安裝。"
        Write-Warning "目前 Node.js：$(if ($node) { $node } else { '找不到 node' })。若上面的錯誤是 EBADENGINE 或 node:zlib 的 SyntaxError，請升級 Node.js（例如 winget upgrade OpenJS.NodeJS.LTS），再執行 sync-skills -Install"
        return
      }
    }
  }
  if (Test-Path -LiteralPath $Linker) { & $Linker -HomeDir $HomeDir -WhatIf:$WhatIfPreference }
}

function Invoke-Install {
  $missing = @(Get-States | Where-Object State -eq 'missing')
  if (-not $missing) { Write-Host '清單裡的 skill 都已安裝' }
  Install-Skills $missing
}

function Show-Diff {
  $rows = @(Get-States)
  Write-Host '== 清單有、這台沒裝'
  $rows | Where-Object State -eq 'missing' | ForEach-Object { Write-Host "  $(Format-Line $_.Source $_.Skill)" }
  Write-Host '== 這台有裝、清單沒有（不會被移除）'
  $rows | Where-Object State -eq 'extra' | ForEach-Object { Write-Host "  $(Format-Line $_.Source $_.Skill)" }
}

function Invoke-Export {
  $lines = @('# 要安裝的 skill 清單，由 sync-skills --export 產生（主力機）', '# 格式：<source>  <skill>')
  $i = Get-Installed
  $lines += $i.Keys | Sort-Object | ForEach-Object { Format-Line $i[$_] $_ }
  Set-ListContent $lines
  Write-Host "已寫入 $List，請到 dotfiles repo 用 git diff 檢查後 commit"
}

function Show-Preview($skill, $source) {
  foreach ($f in (Join-Path $SkillsDir "$skill\SKILL.md"), (Join-Path $SkillsDir "$skill\skills\$skill\SKILL.md")) {
    if (Test-Path -LiteralPath $f) { Get-Content -LiteralPath $f -TotalCount 40; return }
  }
  "這台沒有安裝：$skill"
  "來源：$source"
}

# ---------------------------------------------------------------- 互動
# fzf 複選；回傳選中的列
function Select-Rows($rows, $header) {
  if (-not $rows) { Write-Host '沒有可選的 skill'; return @() }
  $pwsh = (Get-Process -Id $PID).Path
  $preview = "`"$pwsh`" -NoProfile -File `"$PSCommandPath`" -HomeDir `"$HomeDir`" -Preview {3} -PreviewSource {2}"
  $picked = $rows | ForEach-Object { "{0}`t{1}`t{2}" -f (Format-Line $_.Source $_.Skill), $_.Source, $_.Skill } |
    fzf --multi --reverse --height=80% --delimiter="`t" --with-nth=1 --prompt='skill> ' `
      --header="$header`nTab 勾選（可複選）、Ctrl-A 全選、Enter 確認、Esc 返回" `
      --bind=ctrl-a:select-all --preview=$preview --preview-window=right,55%,wrap
  $names = @($picked | ForEach-Object { ($_ -split "`t")[2] })
  return @($rows | Where-Object { $_.Skill -in $names })
}

function Invoke-Interactive {
  Assert-List
  while ($true) {
    $rows = @(Get-States)
    $n = { param($s) @($rows | Where-Object State -eq $s).Count }
    $listed = (& $n 'both') + (& $n 'missing')
    $action = @(
      "add      把這台的 skill 加進清單（這台有、清單沒有：$(& $n 'extra') 個）"
      "install  安裝清單裡這台缺少的 skill（$(& $n 'missing') 個）"
      "remove   從清單移除（清單共 $listed 個；已安裝的不會被刪）"
      'quit     離開'
    ) | fzf --reverse --height=40% --prompt='sync-skills> ' --header="清單：$List（改完到 dotfiles repo 用 git diff 檢查後 commit）"
    switch (($action -split '\s+')[0]) {
      'add' {
        $chosen = Select-Rows @($rows | Where-Object State -eq 'extra') '要加進清單的 skill（這台已安裝）'
        if (-not $chosen) { continue }
        # fzf 結束時會清掉自己的畫面，先印出選了什麼，捲動紀錄才看得到
        Write-Host "== add：$($chosen.Count) 個 skill"
        $lines = @(Get-Content -LiteralPath $List) + @($chosen | ForEach-Object { Format-Line $_.Source $_.Skill })
        Set-ListContent $lines
        Write-Host '已加入清單：'; $chosen | ForEach-Object { Write-Host "  $($_.Source)  $($_.Skill)" }
      }
      'install' {
        $chosen = Select-Rows @($rows | Where-Object State -eq 'missing') '要安裝的 skill（清單有、這台沒裝）'
        if ($chosen) {
          Write-Host "== install：$($chosen.Count) 個 skill"
          Install-Skills $chosen
        }
      }
      'remove' {
        $chosen = Select-Rows @($rows | Where-Object State -in 'both', 'missing') '要從清單移除的 skill（不會從這台解除安裝）'
        if (-not $chosen) { continue }
        Write-Host "== remove：$($chosen.Count) 個 skill"
        $drop = @($chosen.Skill)
        # 保留註解與其他行，只刪掉選中的 skill
        $lines = Get-Content -LiteralPath $List | Where-Object {
          $f = @(($_ -replace '#.*', '').Trim() -split '\s+' | Where-Object { $_ })
          -not ($f.Count -ge 2 -and $f[1] -in $drop)
        }
        Set-ListContent $lines
        Write-Host '已從清單移除：'; $drop | ForEach-Object { Write-Host "  $_" }
      }
      default { return }
    }
  }
}

# ---------------------------------------------------------------- main
if ($Preview) { Show-Preview $Preview $PreviewSource; return }
if ($Export) { Invoke-Export; return }
if ($Diff) { Show-Diff; return }
if ($Install) { Invoke-Install; return }
if ($Interactive -or ([Environment]::UserInteractive -and -not [Console]::IsInputRedirected -and (Get-Command fzf -ErrorAction SilentlyContinue))) {
  Invoke-Interactive
} else {
  Invoke-Install
}
