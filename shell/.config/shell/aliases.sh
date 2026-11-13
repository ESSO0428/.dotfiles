# shellcheck shell=bash
# 共用 alias（bash 與 zsh 都會 source）
# lab 的 ssh alias 放 ~/.alias.local（範本：~/.config/shell/alias.local.example）
# 只在某台機器有的工具（WSL 的 notepad++、clip.exe 等）放 ~/.tool.local

alias ra="ranger"

# server 上沒有系統 nvim、只有 appimage 時
if ! command -v nvim >/dev/null 2>&1 && [ -x "$HOME/nvim.appimage" ]; then
  alias nvim="$HOME/nvim.appimage"
fi

command -v kitty >/dev/null 2>&1 && alias icat="kitty +kitten icat"
[ -f "$HOME/fzf_exp.txt" ] && alias fzf_exp="cat ~/fzf_exp.txt"
