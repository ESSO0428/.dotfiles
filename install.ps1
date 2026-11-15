#Requires -Version 7
<#
.SYNOPSIS
  Windows 版安裝程式：把 dotfiles 連結或複製到 Windows 的對應位置（Linux 請用 install.sh）

.DESCRIPTION
  不帶參數執行時進入互動模式：勾選 package，再逐一決定和 repo 不同的檔案怎麼處理。

  package      內容                                              方式
  claude       ~/.claude（和 Linux 共用同一份 settings.json）          symlink
  opencode     ~/.config/opencode                                symlink
  pi           ~/.pi/agent                                       symlink
  agents       ~/.agents/skills.list、scripts/*.ps1（.sh 與 bash 腳本不會連結）  symlink
               之後把 ~/.agents/scripts 加進使用者 PATH，並執行 sync-skills.ps1
  vimrc        ~/.ideavimrc、~/keymap.vim                         symlink
  nvim         %LOCALAPPDATA%\nvim（整個目錄）                     junction
  documents    Documents\config.xlaunch                           symlink
               Documents\PowerShell\*（不存在時才從範本複製）        copy once
  obsidian     OneDrive 的 remotely-save\Obsidian Vault\.obsidian.vimrc  copy
  im-select    ~/im-select.exe、C:\Windows\im-select.exe（需要系統管理員）  copy

  目標已存在、而且不是指向 repo 的檔案，預設先搬到 ~/.dotfiles-backup/<時間>/ 再連結（repo 版本優先）。

  需要 PowerShell 7（pwsh）。建立 symlink 需要「開發人員模式」或系統管理員權限：
  兩者都沒有時（或要複製 im-select.exe 到 C:\Windows 時），會詢問是否以系統管理員身分在新視窗
  繼續（跳出 UAC）。提權後仍是同一個帳號；目標路徑會在提權前決定好再傳過去。

.EXAMPLE
  .\install.ps1                      # 互動模式
  .\install.ps1 -WhatIf              # 只顯示會做什麼
  .\install.ps1 -Status              # 列出每個檔案的狀態
  .\install.ps1 -Interactive         # 強制互動模式（自動判斷失準時）
  .\install.ps1 -All                 # 不詢問，全部 package，以 repo 為準
  .\install.ps1 claude nvim          # 不詢問，只處理指定 package
  .\install.ps1 -Adopt pi            # 以這台的版本為準，收進 repo（之後用 git diff 檢查）
#>
[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Position = 0, ValueFromRemainingArguments)]
  [string[]]$Packages = @(),
  [switch]$All,
  [switch]$Adopt,
  [switch]$Status,
  # 強制互動模式（自動判斷失準時用，例如從 WSL 呼叫 pwsh.exe）
  [switch]$Interactive,
  # 測試用：改變目標位置
  [string]$HomeDir = $HOME,
  [string]$LocalAppData = $env:LOCALAPPDATA,
  [string]$Documents = [Environment]::GetFolderPath('MyDocuments'),
  [string]$OneDriveRoot = '',
  # 內部用：自動提權後的視窗用來接續執行，格式 "claude=repo,pi=adopt"
  [string]$Plan = '',
  [switch]$Elevated
)

$ErrorActionPreference = 'Stop'
# 輸出用 UTF-8，否則中文和 ✔ 會被轉成主控台的字碼頁（Big5）而變成亂碼或問號
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()
$Repo = $PSScriptRoot
$Win = Join-Path $Repo 'windows'
$Backup = Join-Path $HomeDir ".dotfiles-backup\$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$Cmdlet = $PSCmdlet

$AllPackages = 'claude', 'opencode', 'pi', 'agents', 'vimrc', 'nvim', 'documents', 'obsidian', 'im-select'
$Desc = @{
  'claude'    = 'Claude Code 設定、agents、commands'
  'opencode'  = 'opencode 設定、tui、quota'
  'pi'        = 'pi 設定、sidebar、擴充設定、agents'
  'agents'    = 'skills 清單、sync-skills.ps1（並加進 PATH）'
  'vimrc'     = '.ideavimrc、keymap.vim（JetBrains、VS Code）'
  'nvim'      = 'Windows 版 nvim（%LOCALAPPDATA%\nvim）'
  'documents' = 'config.xlaunch、PowerShell profile（只在不存在時複製）'
  'obsidian'  = '.obsidian.vimrc（複製到 OneDrive 的 Obsidian Vault）'
  'im-select' = 'im-select.exe（複製到家目錄與 C:\Windows）'
}

# symlink 不能指向 \\wsl.localhost：WSL 沒開時 Windows 程式就讀不到
if ($Repo -like '\\*') {
  throw "請在 Windows 的 clone 執行（例如 $HOME\.dotfiles），不要透過 $Repo"
}

# ---------------------------------------------------------------- 項目清單
# 每個項目：Package、Source、Target、Kind（link / junction / copy / template）
function New-Entry($pkg, $src, $dst, $kind) {
  [pscustomobject]@{ Package = $pkg; Source = $src; Target = $dst; Kind = $kind }
}

# 檔案開頭是 bash / sh 的 shebang，或副檔名是 .sh，Windows 上不連結
function Test-PosixScript($path) {
  if ($path -like '*.sh') { return $true }
  $first = Get-Content -LiteralPath $path -TotalCount 1 -ErrorAction SilentlyContinue
  return [bool]($first -match '^#!.*\b(bash|sh)\b')
}

# 共用 package：檔案在 repo\<pkg>\ 底下，相對路徑等於在家目錄的位置
# windows\overrides\<pkg>\ 有同路徑的檔案時改用 Windows 版
function Get-SharedEntries($pkg) {
  $root = Join-Path $Repo $pkg
  Get-ChildItem -LiteralPath $root -Recurse -File -Force | ForEach-Object {
    $rel = [IO.Path]::GetRelativePath($root, $_.FullName)
    if (Test-PosixScript $_.FullName) { return }
    $override = Join-Path $Win "overrides\$pkg\$rel"
    $src = if (Test-Path -LiteralPath $override) { $override } else { $_.FullName }
    New-Entry $pkg $src (Join-Path $HomeDir $rel) 'link'
  }
}

function Find-ObsidianVault {
  $roots = @($OneDriveRoot, $env:OneDriveConsumer, $env:OneDrive, (Join-Path $HomeDir 'OneDrive')) |
    Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Container) } | Select-Object -Unique
  foreach ($root in $roots) {
    foreach ($apps in '應用程式', 'Apps', 'Applications') {
      $vault = Join-Path $root "$apps\remotely-save\Obsidian Vault"
      if (Test-Path -LiteralPath $vault -PathType Container) { return $vault }
    }
  }
  return $null
}

function Test-Admin {
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  return ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-Entries($pkg) {
  switch ($pkg) {
    { $_ -in 'claude', 'opencode', 'pi', 'agents' } { Get-SharedEntries $pkg }
    'vimrc' {
      Get-ChildItem -LiteralPath (Join-Path $Win 'home') -File -Force | ForEach-Object {
        New-Entry $pkg $_.FullName (Join-Path $HomeDir $_.Name) 'link'
      }
    }
    'nvim' { New-Entry $pkg (Join-Path $Win 'localappdata\nvim') (Join-Path $LocalAppData 'nvim') 'junction' }
    'documents' {
      New-Entry $pkg (Join-Path $Win 'documents\config.xlaunch') (Join-Path $Documents 'config.xlaunch') 'link'
      # PowerShell profile 會被 conda init、Chocolatey 等安裝程式修改，所以和 Linux 的 rc 檔一樣只複製範本
      # profile.ps1 只有 conda init 產生的區塊（路徑寫死），交給 `conda init powershell` 產生，不自動複製
      $ps = 'Microsoft.PowerShell_profile.ps1'
      New-Entry $pkg (Join-Path $Win "documents\PowerShell\$ps") (Join-Path $Documents "PowerShell\$ps") 'template'
    }
    'obsidian' {
      $vault = Find-ObsidianVault
      if ($vault) {
        New-Entry $pkg (Join-Path $Win 'obsidian\.obsidian.vimrc') (Join-Path $vault '.obsidian.vimrc') 'copy'
      } else {
        Write-Warning "找不到 OneDrive\(應用程式|Apps|Applications)\remotely-save\Obsidian Vault，略過 obsidian"
      }
    }
    'im-select' {
      $exe = Join-Path $Win 'im-select.exe'
      New-Entry $pkg $exe (Join-Path $HomeDir 'im-select.exe') 'copy'
      New-Entry $pkg $exe 'C:\Windows\im-select.exe' 'copy'
    }
  }
}

# ---------------------------------------------------------------- 狀態
function Get-LinkTarget($path) {
  $item = Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
  if (-not $item -or -not $item.LinkType) { return $null }
  $t = $item.LinkTarget
  if (-not [IO.Path]::IsPathRooted($t)) { $t = Join-Path (Split-Path $path) $t }
  return [IO.Path]::GetFullPath($t)
}

# 內容相同就算相同，忽略 CRLF / LF 的差異（舊腳本從 Windows clone 複製出去的檔案是 CRLF）
function Test-SameFile($a, $b) {
  if ((Get-FileHash -LiteralPath $a).Hash -eq (Get-FileHash -LiteralPath $b).Hash) { return $true }
  if ((Get-Item -LiteralPath $a).Length -gt 5MB -or $a -like '*.exe') { return $false }
  $ta = [IO.File]::ReadAllText($a) -replace "`r`n", "`n"
  $tb = [IO.File]::ReadAllText($b) -replace "`r`n", "`n"
  return $ta -ceq $tb
}

# 兩個目錄的檔案清單相同、每個檔案內容也相同（忽略 CRLF）
function Test-SameDir($a, $b) {
  if (-not (Test-Path -LiteralPath $a -PathType Container)) { return $false }
  $fa = @(Get-ChildItem -LiteralPath $a -Recurse -File -Force | ForEach-Object { [IO.Path]::GetRelativePath($a, $_.FullName) } | Sort-Object)
  $fb = @(Get-ChildItem -LiteralPath $b -Recurse -File -Force | ForEach-Object { [IO.Path]::GetRelativePath($b, $_.FullName) } | Sort-Object)
  if (($fa -join "`n") -ne ($fb -join "`n")) { return $false }
  foreach ($rel in $fa) {
    if (-not (Test-SameFile (Join-Path $a $rel) (Join-Path $b $rel))) { return $false }
  }
  return $true
}

# linked 已連到 repo；new 不存在；same 實體檔但內容和 repo 一樣；differ 不同；local 範本已存在（不覆蓋）
function Get-State($e) {
  $exists = Test-Path -LiteralPath $e.Target
  $isLink = [bool](Get-Item -LiteralPath $e.Target -Force -ErrorAction SilentlyContinue).LinkType
  switch ($e.Kind) {
    { $_ -in 'link', 'junction' } {
      if ($isLink -and (Get-LinkTarget $e.Target) -eq [IO.Path]::GetFullPath($e.Source)) { return 'linked' }
      if (-not $exists -and -not $isLink) { return 'new' }
      if ($e.Kind -eq 'link' -and -not $isLink -and (Test-SameFile $e.Target $e.Source)) { return 'same' }
      if ($e.Kind -eq 'junction' -and -not $isLink -and (Test-SameDir $e.Target $e.Source)) { return 'same' }
      return 'differ'
    }
    'copy' {
      if (-not $exists) { return 'new' }
      if (Test-SameFile $e.Target $e.Source) { return 'same' }
      return 'differ'
    }
    'template' { if ($exists) { return 'local' } else { return 'new' } }
  }
}

$Mark = @{ linked = '✔ 已連結'; new = '＋ 新增  '; same = '＝ 相同  '; differ = '≠ 不同  '; local = '・ 保留  ' }

function Show-Status($pkg) {
  Write-Host "== ${pkg}：$($Desc[$pkg])"
  foreach ($e in Get-Entries $pkg) {
    $state = Get-State $e
    $note = switch ($e.Kind) {
      'junction' { '（junction）' } 'copy' { '（複製）' } 'template' { '（範本，已存在就不動）' } default { '' }
    }
    Write-Host "  $($Mark[$state]) $($e.Target)$note"
  }
}

function Get-Summary($pkg) {
  $c = @{ linked = 0; new = 0; same = 0; differ = 0; local = 0 }
  foreach ($e in Get-Entries $pkg) { $c[(Get-State $e)]++ }
  '{0,-10} 已連結 {1,-3} 新增 {2,-3} 相同 {3,-3} 不同 {4,-3} {5}' -f $pkg, $c.linked, $c.new, $c.same, $c.differ, $Desc[$pkg]
}

# ---------------------------------------------------------------- 動作
function Invoke-Step($what, [scriptblock]$action) {
  # -WhatIf 時 ShouldProcess 會自己印出 "What if: ..."，並回傳 false
  if ($Cmdlet.ShouldProcess($what)) { & $action }
}

function Get-BackupPath($target) {
  $full = [IO.Path]::GetFullPath($target)
  $homeFull = [IO.Path]::GetFullPath($HomeDir).TrimEnd('\')
  $rel = if ($full.StartsWith("$homeFull\", 'OrdinalIgnoreCase')) { $full.Substring($homeFull.Length + 1) } else { $full -replace ':', '' }
  return Join-Path $Backup $rel
}

function Backup-Target($target) {
  $dst = Get-BackupPath $target
  Invoke-Step "備份 $target → $dst" {
    New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
    Move-Item -LiteralPath $target -Destination $dst -Force
  }
}

function New-Link($e) {
  Invoke-Step "連結 $($e.Target) → $($e.Source)" {
    New-Item -ItemType Directory -Force -Path (Split-Path $e.Target) | Out-Null
    $type = if ($e.Kind -eq 'junction') { 'Junction' } else { 'SymbolicLink' }
    New-Item -ItemType $type -Path $e.Target -Target $e.Source | Out-Null
  }
}

function Install-Entry($e, $mode) {
  $state = Get-State $e
  if ($state -in 'linked', 'local') { return }
  if ($e.Kind -eq 'copy' -and $state -eq 'same') { return }
  if ($e.Target -like 'C:\Windows\*' -and -not (Test-Admin)) {
    Write-Warning "略過 $($e.Target)：需要以系統管理員身分執行"
    return
  }

  switch ($e.Kind) {
    'template' {
      Invoke-Step "從範本建立 $($e.Target)" {
        New-Item -ItemType Directory -Force -Path (Split-Path $e.Target) | Out-Null
        Copy-Item -LiteralPath $e.Source -Destination $e.Target
      }
    }
    'copy' {
      if ($mode -eq 'adopt' -and $state -eq 'differ') {
        Invoke-Step "收進 repo：$($e.Target) → $($e.Source)" { Copy-Item -LiteralPath $e.Target -Destination $e.Source -Force }
      } else {
        if ($state -eq 'differ') { Backup-Target $e.Target }
        Invoke-Step "複製 $($e.Source) → $($e.Target)" {
          New-Item -ItemType Directory -Force -Path (Split-Path $e.Target) | Out-Null
          Copy-Item -LiteralPath $e.Source -Destination $e.Target -Force
        }
      }
    }
    default {
      # link / junction
      if ($state -ne 'new') {
        if ($mode -eq 'adopt' -and $e.Kind -eq 'link' -and -not (Get-Item -LiteralPath $e.Target -Force).LinkType) {
          Invoke-Step "收進 repo：$($e.Target) → $($e.Source)" {
            Copy-Item -LiteralPath $e.Target -Destination $e.Source -Force
            Remove-Item -LiteralPath $e.Target -Force
          }
        } else {
          if ($mode -eq 'adopt') { Write-Warning "$($e.Target) 不支援以這台為準，改為以 repo 為準（舊的先備份）" }
          Backup-Target $e.Target
        }
      }
      New-Link $e
    }
  }
}

# 建立 symlink 需要開發人員模式或系統管理員（junction 不需要）
function Test-CanSymlink {
  $probe = Join-Path ([IO.Path]::GetTempPath()) "dotfiles-symlink-probe-$PID"
  try {
    # -WhatIf:$false：這是能力測試，-WhatIf 時也要真的試，否則永遠回傳「可以」
    New-Item -ItemType SymbolicLink -Path $probe -Target $PSCommandPath -ErrorAction Stop -WhatIf:$false | Out-Null
    return $true
  } catch {
    return $false
  } finally {
    Remove-Item -LiteralPath $probe -Force -ErrorAction SilentlyContinue -WhatIf:$false
  }
}

# 以系統管理員身分在新視窗重新執行，並等它結束
# 目標路徑在提權前就決定好再傳過去：若 UAC 用的是另一個系統管理員帳號，$HOME 會變成那個帳號的
function Invoke-Elevated($work, $mode) {
  $plan = ($work | ForEach-Object { "$_=$($mode[$_])" }) -join ','
  $oneDrive = @($OneDriveRoot, $env:OneDriveConsumer, $env:OneDrive) | Where-Object { $_ } | Select-Object -First 1
  $argList = @(
    '-NoProfile', '-File', $PSCommandPath, '-Elevated', '-Plan', $plan,
    '-HomeDir', $HomeDir, '-LocalAppData', $LocalAppData, '-Documents', $Documents
  )
  if ($oneDrive) { $argList += '-OneDriveRoot', $oneDrive }
  $quoted = ($argList | ForEach-Object { if ($_ -match '^-\w+$') { $_ } else { '"' + $_ + '"' } }) -join ' '
  $pwsh = (Get-Process -Id $PID).Path
  if ($env:DOTFILES_ELEVATE_DRYRUN) { Write-Host "（DRYRUN）$pwsh $quoted"; return }
  Start-Process -FilePath $pwsh -ArgumentList $quoted -Verb RunAs -Wait -WorkingDirectory $Repo
}

# agents 裝好之後：把 ~/.agents/scripts 加進使用者 PATH，再跑 sync-skills.ps1
# 一律在原本的視窗執行（不在系統管理員視窗），npx 裝出來的 skill 才會是這個帳號的
function Invoke-AgentsExtras($interactive) {
  $scripts = Join-Path $HomeDir '.agents\scripts'
  $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
  if (($userPath -split ';') -notcontains $scripts) {
    if ($Cmdlet.ShouldProcess("使用者 PATH 加入 $scripts")) {
      [Environment]::SetEnvironmentVariable('Path', (($userPath.TrimEnd(';'), $scripts) -join ';'), 'User')
      Write-Host "已把 $scripts 加進使用者 PATH（新開的終端機才會生效）"
    }
  }
  $env:Path = "$scripts;$env:Path"
  Write-Host '== skills'
  $sync = Join-Path $Repo 'agents\.agents\scripts\sync-skills.ps1'
  # 明確傳 -Interactive：不讓 sync-skills 自己判斷終端機狀態（從 install.ps1 呼叫時可能誤判而直接全部安裝）
  if ($interactive) { & $sync -Interactive -HomeDir $HomeDir -WhatIf:$WhatIfPreference }
  else { & $sync -Install -HomeDir $HomeDir -WhatIf:$WhatIfPreference }
}

# ---------------------------------------------------------------- 互動
function Select-Packages {
  # 有 fzf：複選，右側預覽每個檔案的狀態（和 install.sh 一樣）
  if (Get-Command fzf -ErrorAction SilentlyContinue) {
    $pwsh = (Get-Process -Id $PID).Path
    $preview = "`"$pwsh`" -NoProfile -File `"$PSCommandPath`" -Status {1} " +
      "-HomeDir `"$HomeDir`" -LocalAppData `"$LocalAppData`" -Documents `"$Documents`""
    if ($OneDriveRoot) { $preview += " -OneDriveRoot `"$OneDriveRoot`"" }
    $picked = $AllPackages | ForEach-Object { Get-Summary $_ } |
      fzf --multi --reverse --height=80% --prompt='package> ' `
        --header="Tab 勾選（可複選）、Ctrl-A 全選、Enter 確認、Esc 取消`n右側是每個檔案的狀態：✔ 已連結  ＋ 新增  ＝ 相同  ≠ 不同  ・ 保留" `
        --bind=ctrl-a:select-all --preview=$preview --preview-window=right,55%,wrap
    return @($picked | ForEach-Object { ($_ -split '\s+')[0] } | Where-Object { $_ -in $AllPackages })
  }

  # 沒有 fzf：編號切換選單
  $selected = @{}
  while ($true) {
    Write-Host ''
    for ($i = 0; $i -lt $AllPackages.Count; $i++) {
      $p = $AllPackages[$i]
      $box = if ($selected[$p]) { '[x]' } else { '[ ]' }
      Write-Host (" $box {0}) {1}" -f ($i + 1), (Get-Summary $p))
    }
    $in = Read-Host '輸入編號切換勾選（可多個，以空白分隔），a 全選，s 看狀態，Enter 確認'
    if (-not $in) { break }
    switch -Regex ($in.Trim()) {
      '^a$' { $AllPackages | ForEach-Object { $selected[$_] = $true } }
      '^s$' { $AllPackages | ForEach-Object { Show-Status $_ } }
      default {
        foreach ($n in $in -split '\s+') {
          if ($n -match '^\d+$' -and [int]$n -ge 1 -and [int]$n -le $AllPackages.Count) {
            $p = $AllPackages[[int]$n - 1]; $selected[$p] = -not $selected[$p]
          }
        }
      }
    }
  }
  return $AllPackages | Where-Object { $selected[$_] }
}

function Select-Mode($pkg) {
  $differ = @(Get-Entries $pkg | Where-Object { (Get-State $_) -eq 'differ' })
  if ($differ.Count -eq 0) { return 'repo' }
  while ($true) {
    Write-Host ''
    Write-Host "$pkg 有 $($differ.Count) 個項目和 repo 不同："
    $differ | ForEach-Object { Write-Host "  ≠ $($_.Target)" }
    $ans = Read-Host '  [r] 以 repo 為準（這台的舊檔備份）  [a] 以這台為準（收進 repo）  [d] 看 diff  [s] 跳過'
    switch ($ans.Trim().ToLower()) {
      'r' { return 'repo' }
      'a' { return 'adopt' }
      's' { return 'skip' }
      # Out-Host：函式裡沒接住的輸出會變成回傳值，diff 會混進回傳的模式裡
      'd' { $differ | ForEach-Object { git -c core.autocrlf=false --no-pager diff --no-index -- $_.Target $_.Source 2>&1 | Out-Host } }
    }
  }
}

# ---------------------------------------------------------------- main
if ($Status) {
  $list = if ($Packages) { $Packages } else { $AllPackages }
  $list | ForEach-Object { Show-Status $_ }
  return
}

$interactive = -not $Plan -and ($Interactive -or (-not ($Packages -or $All -or $Adopt) -and [Environment]::UserInteractive -and -not [Console]::IsInputRedirected))
$mode = @{}
if ($Plan) {
  # 提權後接續執行：沿用原本視窗選好的 package 與模式
  $Packages = @()
  foreach ($item in $Plan -split ',') {
    $p, $m = $item -split '=', 2
    if ($p -notin $AllPackages -or $m -notin 'repo', 'adopt', 'skip') { throw "無法解析 -Plan：$item" }
    $Packages += $p; $mode[$p] = $m
  }
} elseif ($interactive) {
  $Packages = @(Select-Packages)
  if (-not $Packages) { Write-Host '沒有選擇任何 package'; return }
  foreach ($p in $Packages) { $mode[$p] = Select-Mode $p }
  Write-Host ''
  Write-Host '即將執行：'
  foreach ($p in $Packages) {
    $text = @{ repo = '以 repo 為準'; adopt = '以這台為準（收進 repo，之後 git diff 檢查）'; skip = '跳過' }[$mode[$p]]
    Write-Host "  ${p}：$text"
  }
  if ($WhatIfPreference) { Write-Host '  （WhatIf：只顯示，不會變更）' }
  $ok = Read-Host '確認執行？(Y/n)'
  if ($ok -and $ok.Trim().ToLower() -ne 'y') { Write-Host '已取消'; return }
} else {
  if (-not $Packages) { $Packages = $AllPackages }
  foreach ($p in $Packages) {
    if ($p -notin $AllPackages) { throw "沒有 package：$p（可用：$($AllPackages -join ', ')）" }
    $mode[$p] = if ($Adopt) { 'adopt' } else { 'repo' }
  }
}

$work = @($Packages | Where-Object { $mode[$_] -ne 'skip' })
$entries = @($work | ForEach-Object { Get-Entries $_ })
$needSymlink = @($entries | Where-Object { $_.Kind -eq 'link' -and (Get-State $_) -ne 'linked' }).Count -gt 0
$needWindowsDir = @($entries | Where-Object { $_.Target -like 'C:\Windows\*' -and (Get-State $_) -notin 'same', 'linked' }).Count -gt 0
$symlinkBlocked = $needSymlink -and -not (Test-CanSymlink)
$adminMissing = $needWindowsDir -and -not (Test-Admin)

if (($symlinkBlocked -or $adminMissing) -and -not $WhatIfPreference -and -not $Elevated) {
  $why = @()
  if ($symlinkBlocked) { $why += '建立 symlink（沒有開發人員模式）' }
  if ($adminMissing) { $why += '複製 im-select.exe 到 C:\Windows' }
  Write-Host ''
  Write-Host "需要系統管理員權限：$($why -join '、')"
  Write-Host '（或開啟「設定 → 系統 → 開發人員專用 → 開發人員模式」，之後建立 symlink 就不必提權）'
  $ans = if ([Environment]::UserInteractive) { Read-Host '要以系統管理員身分在新視窗繼續嗎？會跳出 UAC 視窗 (Y/n)' } else { 'n' }
  if (-not $ans -or $ans.Trim().ToLower() -eq 'y') {
    Invoke-Elevated $work $mode
    Write-Host '系統管理員視窗已結束，目前狀態：'
    foreach ($p in $work) { Write-Host "  $(Get-Summary $p)" }
    if ('agents' -in $work) { Invoke-AgentsExtras $interactive }
    return
  }
  if ($symlinkBlocked) { throw '沒有建立 symlink 的權限，已停止（沒有做任何改動）' }
  # 只缺 C:\Windows：繼續執行，那一項會被略過
}

$adopted = $false
foreach ($p in $work) {
  Write-Host "== $p（$(if ($mode[$p] -eq 'adopt') { '以這台為準' } else { '以 repo 為準' })）"
  foreach ($e in Get-Entries $p) { Install-Entry $e $mode[$p] }
  if ($mode[$p] -eq 'adopt') { $adopted = $true }
}

if (Test-Path -LiteralPath $Backup) { Write-Host "原有檔案已備份到 $Backup" }
if ($adopted) { Write-Host "有 package 以這台為準，請到 $Repo 用 git diff 檢查：每台都要的就 commit，不要的用 git checkout -- <檔案> 還原" }
# settings.json 和 Linux 共用，裡面有 rtk hook：沒裝 rtk 時 Bash 仍會執行，只是每次都顯示 hook 錯誤
if ('claude' -in $work -and -not (Get-Command rtk -ErrorAction SilentlyContinue)) {
  Write-Warning '這台沒有 rtk：Claude 每次執行 Bash 都會顯示 rtk hook 的錯誤（指令仍會執行）。請安裝 rtk。'
}
if ('agents' -in $work -and -not $Elevated) { Invoke-AgentsExtras $interactive }
Write-Host '完成'
if ($Elevated) { Read-Host '按 Enter 關閉這個系統管理員視窗' | Out-Null }
