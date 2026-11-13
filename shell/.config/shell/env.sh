# shellcheck shell=bash
# 共用環境變數與 PATH（bash 與 zsh 都會 source，在 oh-my-zsh 之前載入）
# 只放每台機器都成立的設定；機器專屬的放 ~/.tool.local（範本：~/.config/shell/tool.local.example）

# 目錄存在才加進 PATH 最前面，已在 PATH 裡就跳過（重複 source 不會越疊越長）
_path_prepend() {
  [ -d "$1" ] || return 0
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

# 後加的優先：bob 管理的 nvim > ~/bin > ~/bin/tmux（server 上自編的 tmux）> ~/.local/bin > ...
for _d in \
  "$HOME/go/bin" \
  "$HOME/bin/go/bin" \
  "$HOME/.cargo/bin" \
  "$HOME/.local/bin" \
  "$HOME/.agents/scripts" \
  "$HOME/bin/tmux" \
  "$HOME/bin" \
  "$HOME/.local/share/bob/nvim-bin"; do
  _path_prepend "$_d"
done
unset _d
export PATH

# editor：有 nvim 用 nvim，server 上只有 appimage 就用 appimage，否則 vim
if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
elif [ -x "$HOME/nvim.appimage" ]; then
  export EDITOR="$HOME/nvim.appimage"
else
  export EDITOR="vim"
fi
export VISUAL="$EDITOR"

# ranger
export RANGER_LOAD_DEFAULT_RC=FALSE

# NOTE: DISPLAY 很重要（X11 視窗、剪貼簿、im-select 等都靠它），只在 WSL 本機自動設定
#   - WSL 判斷：WSL 會自動設定 $WSL_DISTRO_NAME
#   - 從別台 ssh 進來（$SSH_CONNECTION 有值）時不設，保留 ssh -Y / -X 帶入的 DISPLAY
#   - 遠端 server、Linux 桌面都不會進這段；WSL2 改用 Windows 端 X server 時，在 ~/.tool.local 覆寫：
#     export DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0.0
if [ -n "${WSL_DISTRO_NAME:-}" ] && [ -z "${SSH_CONNECTION:-}" ]; then
  export DISPLAY=:0
  export LIBGL_ALWAYS_INDIRECT=1
fi
