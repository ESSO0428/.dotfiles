---
title: Win-Dotfiles
author: Andy6
date: Saturday, March, 02, 2024
---

# Windows dotfiles

Formerly the [`.win-dotfiles`](https://github.com/ESSO0428/.win-dotfiles) repo, merged into
`.dotfiles` with its history. Install with `install.ps1` at the repo root (see the root README);
the old `LoadMyVimKeyMapForAllEditorOnly.ps1`, `LoadUserDocument.ps1` and
`CopyImSelectToSystemPath.ps1` copy scripts were replaced by it.

```text
windows/
├── home/                 → ~               .ideavimrc (JetBrains), keymap.vim (VS Code)
├── localappdata/nvim/    → %LOCALAPPDATA%\nvim   Windows-only Neovim / Neovim Qt config
├── documents/            → Documents       config.xlaunch, PowerShell profile (template)
├── obsidian/             → Obsidian Vault  .obsidian.vimrc (copied, the vault syncs via OneDrive)
├── overrides/<package>/  replaces a shared file on Windows (claude settings.json without rtk)
├── im-select.exe         → ~ and C:\Windows (copied)
└── Nvim-QT-Right-Click.reg   import by hand
```

## VimKeyMap for other editors

- **Visual Studio Code**: `keymap.vim` in `C:\Users\Andy6`
- **JetBrains IDE**: `.ideavimrc` in `C:\Users\Andy6`
- **Obsidian**: `.obsidian.vimrc` in the vault. The vault lives in
  `OneDrive\應用程式\remotely-save\Obsidian Vault` (`Apps` / `Applications` on English Windows),
  so `install.ps1` copies it there instead of linking.

## Neovim

`localappdata/nvim/` is a separate, lighter config than the Linux one in `~/.config/nvim`:
Windows is slower, so it keeps fewer plugins. `install.ps1` links the whole directory with a
junction (no admin needed).

### Neovim Qt

Right-click menu: import `Nvim-QT-Right-Click.reg` (double-click it, needs admin). It points to
`C:\Program Files\neovim-qt 0.2.18\bin\nvim-qt.exe`; update the path after upgrading Neovim Qt.

Desktop shortcut:

```powershell
# NOTE: This script creates a Neovim Qt shortcut on the desktop.
#       If the shortcut already exists, it will be deleted and recreated (overwrite behavior).
$desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktop "nvim-qt.exe.lnk"

if (Test-Path $shortcutPath) {
    Remove-Item $shortcutPath -Force
}

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = "C:\Program Files\neovim-qt 0.2.18\bin\nvim-qt.exe"
$Shortcut.WorkingDirectory = "$env:USERPROFILE"
$Shortcut.IconLocation = "C:\Program Files\neovim-qt 0.2.18\bin\nvim-qt.exe"
$Shortcut.Description = "Launch Neovim Qt in Home Folder"
$Shortcut.Save()
```

## PowerShell profile

`documents/PowerShell/Microsoft.PowerShell_profile.ps1` is a template: `install.ps1` copies it
only when `Documents\PowerShell\` has none, because installers (conda, Chocolatey) append to the
live profile. For conda, run `conda init powershell` instead of copying
`documents/PowerShell/profile.ps1` (its path to `anaconda3` is machine specific).

## im-select

`im-select.exe` switches input methods on Windows. It also serves VS Code, Obsidian and Neovim /
LunarVim (remote or WSL; remote needs a reverse ssh tunnel, see `reverse-ssh-tunnel-manager` in
the root README).

- Installed to `C:\Windows` and `C:\Users\Andy6` (`C:\Windows` needs an administrator shell).
- Latest version: [download](https://github.com/daipeihust/im-select/raw/master/win/out/x86/im-select.exe)
