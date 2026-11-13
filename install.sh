#!/usr/bin/env bash
# 用 GNU Stow 把各 package 連結到 $HOME
#
# 用法：
#   ./install.sh                  互動模式：複選 package、逐一決定衝突怎麼處理（在終端機執行時）
#   ./install.sh --all            不詢問，連結全部 package（以 repo 為準）
#   ./install.sh shell vim        不詢問，只連結指定 package
#   ./install.sh --adopt [pkg..]  家目錄已有同名檔時，把它收進 repo（之後 git diff 檢查）
#   ./install.sh --status [pkg..] 只列出每個檔案的狀態，不做任何變更
#   ./install.sh --no-skills      不跑 sync-skills
#   DRY_RUN=1 ./install.sh        只顯示會做什麼（互動模式也適用）
#
# 預設遇到家目錄已有同名的實體檔案時，先搬到 ~/.dotfiles-backup/<時間>/ 再連結（repo 版本優先）
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALL_PACKAGES=(shell vim tmux bin ranger claude opencode pi agents)
STOW_VERSION="2.4.1"
DRY_RUN="${DRY_RUN:-0}"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

declare -A DESC=(
  [shell]="env/omz/tools/functions/aliases、.profile（rc 檔只複製範本）"
  [vim]=".vimrc、.vim/vim/"
  [tmux]="oh-my-tmux 的 .tmux.conf、.tmux.conf.local"
  [bin]="~/bin 工具（fzf_rg、ssh-tunnel-manager…）"
  [ranger]=".config/ranger/"
  [claude]="Claude Code 設定、agents、commands、ccstatusline"
  [opencode]="opencode 設定、tui、quota"
  [pi]="pi 設定、sidebar、擴充設定、agents"
  [agents]="skills 清單、sync-skills、link-claude-skills.sh"
)

adopt=0
skills=1
all=0
status_only=0
packages=()
for arg in "$@"; do
  case "$arg" in
    --adopt) adopt=1 ;;
    --all) all=1 ;;
    --status) status_only=1 ;;
    --no-skills) skills=0 ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    -*) echo "未知參數 $arg" >&2; exit 1 ;;
    *) packages+=("$arg") ;;
  esac
done

run() { echo "+ $*"; [ "$DRY_RUN" = 1 ] || "$@"; }

# ---------------------------------------------------------------- 檔案狀態
# 每個檔案一行：<狀態>\t<相對路徑>
#   linked  已連到 repo
#   new     家目錄沒有，會新增
#   same    家目錄是實體檔，但內容和 repo 相同（換成 symlink 不會有差異）
#   differ  家目錄是實體檔或其他 symlink，內容和 repo 不同
file_states() {
  local pkg="$1" rel target src
  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    target="$HOME/$rel"
    src="$DOTFILES/$pkg/$rel"
    if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$src" ]; then
      printf 'linked\t%s\n' "$rel"
    elif [ ! -e "$target" ] && [ ! -L "$target" ]; then
      printf 'new\t%s\n' "$rel"
    elif cmp -s "$target" "$src"; then
      printf 'same\t%s\n' "$rel"
    else
      printf 'differ\t%s\n' "$rel"
    fi
  done < <(cd "$DOTFILES/$pkg" && find . -type f -print0 | sort -z)
}

count_state() { file_states "$1" | awk -F'\t' -v s="$2" '$1 == s' | wc -l | tr -d ' '; }

summary_line() {  # 每個 package 只掃一次檔案狀態
  local pkg="$1"
  file_states "$pkg" | awk -F'\t' -v pkg="$pkg" -v desc="${DESC[$pkg]}" '
    { c[$1]++ }
    END { printf "%-9s 已連結 %-3d 新增 %-3d 相同 %-3d 不同 %-3d %s\n",
                 pkg, c["linked"], c["new"], c["same"], c["differ"], desc }'
}

print_status() {
  local pkg="$1" state rel
  echo "== $pkg：${DESC[$pkg]}"
  while IFS=$'\t' read -r state rel; do
    case "$state" in
      linked) echo "  ✔ 已連結  ~/$rel" ;;
      new)    echo "  ＋ 新增    ~/$rel" ;;
      same)   echo "  ＝ 相同    ~/$rel（實體檔，內容和 repo 一樣）" ;;
      differ) echo "  ≠ 不同    ~/$rel"
              diff -u "$HOME/$rel" "$DOTFILES/$pkg/$rel" 2>/dev/null |
                sed -n '3,12p' | sed 's/^/        /' ;;
    esac
  done < <(file_states "$pkg")
}

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
  local pkg="$1" state rel
  while IFS=$'\t' read -r state rel; do
    case "$state" in
      same|differ)
        run mkdir -p "$BACKUP/$(dirname "$rel")"
        run mv "$HOME/$rel" "$BACKUP/$rel" ;;
    esac
  done < <(file_states "$pkg")
}

# mode：repo（以 repo 為準，舊檔備份）或 adopt（以家目錄為準，收進 repo）
link_package() {
  local pkg="$1" mode="$2"
  local args=(--no-folding --dir="$DOTFILES" --target="$HOME")
  [ "$DRY_RUN" = 1 ] && args+=(--simulate --verbose)
  echo "== $pkg（$( [ "$mode" = adopt ] && echo 以這台為準 || echo 以 repo 為準 )）"
  [ "$pkg" = tmux ] && prepare_tmux
  if [ "$mode" = adopt ]; then
    run stow "${args[@]}" --adopt --restow "$pkg"
  else
    backup_conflicts "$pkg"
    run stow "${args[@]}" --restow "$pkg"
  fi
}

# ---------------------------------------------------------------- 互動
ask() {  # ask <提示> <預設>：回傳使用者輸入（小寫），空白時用預設
  local reply
  read -r -p "$1" reply </dev/tty || true
  reply="${reply:-$2}"
  printf '%s' "${reply,,}"
}

choose_packages() {
  local lines=() pkg
  for pkg in "${ALL_PACKAGES[@]}"; do lines+=("$(summary_line "$pkg")"); done

  if command -v fzf >/dev/null 2>&1; then
    printf '%s\n' "${lines[@]}" |
      fzf --multi --reverse --height=80% --prompt="package> " \
        --header=$'Tab 勾選（可複選）、Ctrl-A 全選、Enter 確認、Esc 取消\n右側是每個檔案的狀態：✔ 已連結  ＋ 新增  ＝ 相同  ≠ 不同（附 diff）' \
        --bind='ctrl-a:select-all' \
        --preview="bash '$DOTFILES/install.sh' --status {1}" \
        --preview-window='right,55%,wrap' |
      awk '{ print $1 }'
  else
    # 沒有 fzf：編號切換選單
    local selected=() i input
    for pkg in "${ALL_PACKAGES[@]}"; do selected+=(0); done
    # 選單印到 stderr：stdout 只輸出最後選中的 package，給呼叫端讀取
    while true; do
      {
        echo
        for i in "${!ALL_PACKAGES[@]}"; do
          printf ' %s %d) %s\n' "$([ "${selected[$i]}" = 1 ] && echo '[x]' || echo '[ ]')" "$((i + 1))" "${lines[$i]}"
        done
      } >&2
      input=$(ask "輸入編號切換勾選（可多個，以空白分隔），a 全選，s 看狀態，Enter 確認：" "")
      case "$input" in
        "") break ;;
        a) for i in "${!selected[@]}"; do selected[$i]=1; done ;;
        s) for pkg in "${ALL_PACKAGES[@]}"; do print_status "$pkg"; done >&2 ;;
        *) for i in $input; do
             [[ "$i" =~ ^[0-9]+$ ]] && [ "$i" -ge 1 ] && [ "$i" -le ${#ALL_PACKAGES[@]} ] &&
               selected[$((i - 1))]=$((1 - selected[$((i - 1))]))
           done ;;
      esac
    done
    for i in "${!ALL_PACKAGES[@]}"; do
      [ "${selected[$i]}" = 1 ] && echo "${ALL_PACKAGES[$i]}"
    done
  fi
}

# 有「不同」的檔案時才詢問；回傳 repo / adopt / skip
choose_mode() {
  local pkg="$1" differ ans state rel
  differ=$(count_state "$pkg" differ)
  [ "$differ" = 0 ] && { echo repo; return; }
  while true; do
    {
      echo
      echo "$pkg 有 $differ 個檔案和 repo 不同："
      file_states "$pkg" | awk -F'\t' '$1 == "differ" { print "  ≠ ~/" $2 }'
    } >&2
    ans=$(ask "  [r] 以 repo 為準（這台的舊檔備份）  [a] 以這台為準（收進 repo）  [d] 看 diff  [s] 跳過 (r/a/d/s)：" "")
    case "$ans" in
      r) echo repo; return ;;
      a) echo adopt; return ;;
      s) echo skip; return ;;
      d) while IFS=$'\t' read -r state rel; do
           [ "$state" = differ ] || continue
           echo "--- ~/$rel（這台）  +++ repo"
           diff -u "$HOME/$rel" "$DOTFILES/$pkg/$rel" || true
         done < <(file_states "$pkg") | ${PAGER:-less -R} >/dev/tty ;;
    esac
  done
}

# ---------------------------------------------------------------- 收尾
setup_shell_files() {
  for f in tool alias; do
    [ -e "$HOME/.$f.local" ] || run cp "$DOTFILES/shell/.config/shell/$f.local.example" "$HOME/.$f.local"
  done
  # .bashrc / .zshrc 會被 conda init 等安裝程式修改，所以不用 symlink，只複製範本
  local s rc
  for s in bash zsh; do
    rc="$HOME/.${s}rc"
    if [ ! -e "$rc" ]; then
      run cp "$DOTFILES/shell/.config/shell/${s}rc.template" "$rc"
    elif ! grep -q '\.config/shell/' "$rc"; then
      echo "注意：$rc 沒有載入 ~/.config/shell/，請參考 ~/.config/shell/${s}rc.template 修改"
    fi
  done
}

run_skills() {
  local interactive="$1"
  echo "== skills"
  # 互動模式交給 sync-skills 自己的選單（沒有 fzf 時它會退回 --install）
  if [ "$interactive" = 1 ]; then
    DRY_RUN="$DRY_RUN" bash "$DOTFILES/agents/.agents/scripts/sync-skills" </dev/tty
  else
    DRY_RUN="$DRY_RUN" bash "$DOTFILES/agents/.agents/scripts/sync-skills" --install
  fi
}

# ---------------------------------------------------------------- main
if [ "$status_only" = 1 ]; then
  [ ${#packages[@]} -gt 0 ] || packages=("${ALL_PACKAGES[@]}")
  for pkg in "${packages[@]}"; do print_status "$pkg"; done
  exit 0
fi

interactive=0
if [ ${#packages[@]} -eq 0 ] && [ "$all" = 0 ] && [ "$adopt" = 0 ] && [ -t 0 ] && [ -t 1 ]; then
  interactive=1
fi

declare -A MODE=()
if [ "$interactive" = 1 ]; then
  mapfile -t packages < <(choose_packages)
  [ ${#packages[@]} -gt 0 ] || { echo "沒有選擇任何 package"; exit 0; }
  for pkg in "${packages[@]}"; do MODE[$pkg]=$(choose_mode "$pkg"); done
  echo
  echo "即將執行："
  for pkg in "${packages[@]}"; do
    case "${MODE[$pkg]}" in
      repo)  echo "  $pkg：以 repo 為準" ;;
      adopt) echo "  $pkg：以這台為準（收進 repo，之後 git diff 檢查）" ;;
      skip)  echo "  $pkg：跳過" ;;
    esac
  done
  [ "$DRY_RUN" = 1 ] && echo "  （DRY_RUN：只顯示，不會變更）"
  [ "$(ask "確認執行？(Y/n)：" y)" = y ] || { echo "已取消"; exit 0; }
else
  [ ${#packages[@]} -gt 0 ] || packages=("${ALL_PACKAGES[@]}")
  for pkg in "${packages[@]}"; do
    [ -d "$DOTFILES/$pkg" ] || { echo "沒有 package：$pkg" >&2; exit 1; }
    MODE[$pkg]=$( [ "$adopt" = 1 ] && echo adopt || echo repo )
  done
fi

ensure_stow
adopted=0
for pkg in "${packages[@]}"; do
  [ "${MODE[$pkg]}" = skip ] && continue
  link_package "$pkg" "${MODE[$pkg]}"
  [ "${MODE[$pkg]}" = adopt ] && adopted=1
  [ "$pkg" = shell ] && setup_shell_files
  if [ "$pkg" = agents ] && [ "$skills" = 1 ]; then run_skills "$interactive"; fi
done

[ -d "$BACKUP" ] && echo "原有檔案已備份到 $BACKUP"
[ "$adopted" = 1 ] && echo "有 package 以這台為準，請到 $DOTFILES 用 git diff 檢查：每台都要的就 commit，不要的用 git checkout -- <檔案> 還原"
echo "完成"
