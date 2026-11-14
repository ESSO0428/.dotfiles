#Requires -Version 7
<#
.SYNOPSIS
  Windows 版 link-claude-skills：把 ~/.agents/skills（唯一來源）以 junction 發佈到 ~/.claude/skills

.DESCRIPTION
  規則和 link-claude-skills.sh 相同，只是改用 junction（連目錄不需要系統管理員或開發人員模式）：
    - 來源 <name>/SKILL.md 存在          → 連到 <name>
    - 否則 <name>/skills/<name>/SKILL.md → 連到該子目錄（整個 repo 型，如 ppt-master）
    - 目的地已是連結                     → 改指向正確位置
    - 目的地是實體目錄，且與來源相同（忽略 .venv）→ 刪除後改成 junction
    - 目的地是實體目錄但內容不同          → 搬到 ~/.claude/skills-backup/<時間>/ 再建 junction
    - 目的地指向來源、但來源已不存在的連結 → 移除（skill 已解除安裝）
    - 其他目的地項目（如 synced/）不碰

.EXAMPLE
  link-claude-skills.ps1 -WhatIf     # 只顯示會做什麼
  link-claude-skills.ps1
#>
[CmdletBinding(SupportsShouldProcess)]
param(
  [string]$HomeDir = $HOME
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()
# PowerShell 變數不分大小寫：$SrcRoot / $DstRoot 不能和迴圈裡的 $dst 同名，否則會被覆蓋
$SrcRoot = Join-Path $HomeDir '.agents\skills'
$DstRoot = Join-Path $HomeDir '.claude\skills'
$Backup = Join-Path $HomeDir ".claude\skills-backup\$(Get-Date -Format 'yyyyMMdd-HHmmss')"

function Get-LinkTarget($path) {
  $item = Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
  if (-not $item -or -not $item.LinkType) { return $null }
  $t = $item.LinkTarget
  if (-not [IO.Path]::IsPathRooted($t)) { $t = Join-Path (Split-Path $path) $t }
  return [IO.Path]::GetFullPath($t)
}

# 檔案清單與內容都相同（忽略 .venv 與 CRLF / LF 差異）
function Test-SameDir($a, $b) {
  $list = {
    param($root)
    Get-ChildItem -LiteralPath $root -Recurse -File -Force |
      Where-Object { $_.FullName -notmatch '[\\/]\.venv[\\/]' } |
      ForEach-Object { [IO.Path]::GetRelativePath($root, $_.FullName) } | Sort-Object
  }
  $fa = @(& $list $a); $fb = @(& $list $b)
  if (($fa -join "`n") -ne ($fb -join "`n")) { return $false }
  foreach ($rel in $fa) {
    $x = Join-Path $a $rel; $y = Join-Path $b $rel
    if ((Get-FileHash -LiteralPath $x).Hash -eq (Get-FileHash -LiteralPath $y).Hash) { continue }
    if (([IO.File]::ReadAllText($x) -replace "`r`n", "`n") -cne ([IO.File]::ReadAllText($y) -replace "`r`n", "`n")) { return $false }
  }
  return $true
}

function New-Junction($dst, $target) {
  if ($PSCmdlet.ShouldProcess("$dst → $target", '建立 junction')) {
    New-Item -ItemType Junction -Path $dst -Target $target | Out-Null
  }
}

if (-not (Test-Path -LiteralPath $SrcRoot -PathType Container)) {
  Write-Host "找不到 $SrcRoot，沒有可連結的 skill"
  return
}
if ($PSCmdlet.ShouldProcess($DstRoot, '建立目錄')) { New-Item -ItemType Directory -Force -Path $DstRoot | Out-Null }

foreach ($dir in Get-ChildItem -LiteralPath $SrcRoot -Directory -Force) {
  $name = $dir.Name
  $target = if (Test-Path -LiteralPath (Join-Path $dir.FullName 'SKILL.md')) {
    $dir.FullName
  } elseif (Test-Path -LiteralPath (Join-Path $dir.FullName "skills\$name\SKILL.md")) {
    Join-Path $dir.FullName "skills\$name"
  } else {
    Write-Host "skip ${name}：找不到 SKILL.md"
    continue
  }
  $target = [IO.Path]::GetFullPath($target)
  $dst = Join-Path $DstRoot $name
  $item = Get-Item -LiteralPath $dst -Force -ErrorAction SilentlyContinue

  if ($item -and $item.LinkType) {
    if ((Get-LinkTarget $dst) -eq $target) { continue }
    if ($PSCmdlet.ShouldProcess($dst, '移除指向錯誤位置的連結')) { $item.Delete() }
    New-Junction $dst $target
  } elseif ($item -and $item.PSIsContainer) {
    if ((Test-SameDir $dst $target) -or (Test-SameDir $dst $dir.FullName)) {
      if ($PSCmdlet.ShouldProcess($dst, '刪除與來源相同的實體目錄')) { Remove-Item -LiteralPath $dst -Recurse -Force }
    } else {
      Write-Warning "${name}：內容與來源不同，備份到 $Backup\$name"
      if ($PSCmdlet.ShouldProcess($dst, "搬到 $Backup\$name")) {
        New-Item -ItemType Directory -Force -Path $Backup | Out-Null
        Move-Item -LiteralPath $dst -Destination (Join-Path $Backup $name)
      }
    }
    New-Junction $dst $target
  } elseif ($item) {
    Write-Host "skip ${name}：$dst 不是目錄也不是連結"
  } else {
    New-Junction $dst $target
  }
}

# 清掉指向來源、但來源已被移除的連結
$srcFull = [IO.Path]::GetFullPath($SrcRoot).TrimEnd('\') + '\'
foreach ($item in Get-ChildItem -LiteralPath $DstRoot -Force -ErrorAction SilentlyContinue) {
  if (-not $item.LinkType) { continue }
  $t = Get-LinkTarget $item.FullName
  if ($t -and $t.StartsWith($srcFull, 'OrdinalIgnoreCase') -and -not (Test-Path -LiteralPath $t)) {
    if ($PSCmdlet.ShouldProcess($item.FullName, '移除來源已不存在的連結')) { $item.Delete() }
  }
}
