#!/usr/bin/env bash
# 用 GNU Stow 把各 package 連結到 $HOME
#
# 用法：
#   ./install.sh                  連結全部 package
#   ./install.sh shell vim        只連結指定 package
#   ./install.sh --adopt [pkg..]  家目錄已有同名檔時，把它收進 repo（主力機用，之後 git diff 檢查）
#   ./install.sh --no-skills      不跑 sync-skills
#   DRY_RUN=1 ./install.sh        只顯示會做什麼
#
# 預設遇到家目錄已有同名的實體檔案時，先搬到 ~/.dotfiles-backup/<時間>/ 再連結（repo 版本優先）
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALL_PACKAGES=(shell vim tmux bin ranger claude opencode pi agents)
STOW_VERSION="2.4.1"
DRY_RUN="${DRY_RUN:-0}"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

adopt=0
skills=1
packages=()
for arg in "$@"; do
  case "$arg" in
    --adopt) adopt=1 ;;
    --no-skills) skills=0 ;;
    -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
    -*) echo "未知參數 $arg" >&2; exit 1 ;;
    *) packages+=("$arg") ;;
  esac
done
[ ${#packages[@]} -gt 0 ] || packages=("${ALL_PACKAGES[@]}")

run() { echo "+ $*"; [ "$DRY_RUN" = 1 ] || "$@"; }

# ---------------------------------------------------------------- stow
# 沒有 stow 時從 GNU 原始碼裝進 ~/.local（只需要 perl 與 make，不需要 root）
ensure_stow() {
  export PATH="$HOME/.local/bin:$PATH"
  command -v stow >/dev/null 2>&1 && return
  echo "找不到 stow，安裝 GNU Stow $STOW_VERSION 到 ~/.local"
  command -v perl >/dev/null 2>&1 || { echo "需要 perl" >&2; exit 1; }
  command -v make >/dev/null 2>&1 || { echo "需要 make" >&2; exit 1; }
  [ "$DRY_RUN" = 1 ] && { echo "+ (DRY_RUN) 略過安裝 stow"; return; }
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL "https://ftp.gnu.org/gnu/stow/stow-$STOW_VERSION.tar.gz" | tar -xz -C "$tmp"
  (cd "$tmp/stow-$STOW_VERSION" && ./configure --prefix="$HOME/.local" >/dev/null && make install >/dev/null)
  rm -rf "$tmp"
  command -v stow >/dev/null 2>&1 || { echo "stow 安裝失敗" >&2; exit 1; }
}

# ---------------------------------------------------------------- 前置
# oh-my-tmux：~/.tmux 是 gpakosz/.tmux 的 clone，要在 stow 之前存在，否則 stow 會建出空的 ~/.tmux
prepare_tmux() {
  if [ ! -d "$HOME/.tmux/.git" ] && [ ! -e "$HOME/.tmux" ]; then
    run git clone --single-branch https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
  fi
  if [ ! -e "$HOME/.tmux.conf" ]; then
    run ln -s .tmux/.tmux.conf "$HOME/.tmux.conf"
  fi
}

# 家目錄已有、但不是指向 repo 的同名檔案，搬到備份目錄
backup_conflicts() {
  local pkg="$1" rel target
  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    target="$HOME/$rel"
    if [ -L "$target" ]; then
      [ "$(readlink -f "$target")" = "$DOTFILES/$pkg/$rel" ] && continue
    elif [ ! -e "$target" ]; then
      continue
    fi
    run mkdir -p "$BACKUP/$(dirname "$rel")"
    run mv "$target" "$BACKUP/$rel"
  done < <(cd "$DOTFILES/$pkg" && find . -type f -print0)
}

# ---------------------------------------------------------------- main
ensure_stow

stow_args=(--no-folding --dir="$DOTFILES" --target="$HOME")
[ "$DRY_RUN" = 1 ] && stow_args+=(--simulate --verbose)

for pkg in "${packages[@]}"; do
  [ -d "$DOTFILES/$pkg" ] || { echo "沒有 package：$pkg" >&2; exit 1; }
  echo "== $pkg"
  [ "$pkg" = tmux ] && prepare_tmux
  if [ "$adopt" = 1 ]; then
    run stow "${stow_args[@]}" --adopt --restow "$pkg"
  else
    backup_conflicts "$pkg"
    run stow "${stow_args[@]}" --restow "$pkg"
  fi
done

# 每台各自管理、不同步的檔案：第一次安裝時從範本建立，已存在就不動
if [[ " ${packages[*]} " == *" shell "* ]]; then
  for f in tool alias; do
    [ -e "$HOME/.$f.local" ] || run cp "$DOTFILES/shell/.config/shell/$f.local.example" "$HOME/.$f.local"
  done
  # .bashrc / .zshrc 會被 conda init 等安裝程式修改，所以不用 symlink，只複製範本
  for s in bash zsh; do
    rc="$HOME/.${s}rc"
    if [ ! -e "$rc" ]; then
      run cp "$DOTFILES/shell/.config/shell/${s}rc.template" "$rc"
    elif ! grep -q '\.config/shell/' "$rc"; then
      echo "注意：$rc 沒有載入 ~/.config/shell/，請參考 ~/.config/shell/${s}rc.template 修改"
    fi
  done
fi

if [ "$skills" = 1 ] && [[ " ${packages[*]} " == *" agents "* ]]; then
  echo "== skills"
  DRY_RUN="$DRY_RUN" bash "$DOTFILES/agents/.agents/scripts/sync-skills"
fi

[ -d "$BACKUP" ] && echo "原有檔案已備份到 $BACKUP"
[ "$adopt" = 1 ] && echo "已用 --adopt 收進家目錄的版本，請在 $DOTFILES 用 git diff 檢查"
echo "完成"
