# shellcheck shell=bash
# 工具初始化（fzf / nvm / cargo / autojump），bash 與 zsh 都會 source
# 每段都先檢查工具是否存在，沒裝就跳過；這台要不同設定時在 ~/.tool.local 覆寫

# ---------------------------------------------------------------- fzf
# bat (酷炫版的 cat 具有語法高量的功能)
# wget https://github.com/sharkdp/bat/releases/download/v0.21.0/bat-v0.21.0-x86_64-unknown-linux-musl.tar.gz
# tar -zxvf bat-v0.21.0-x86_64-unknown-linux-musl.tar.gz
# cd ~/bat-v0.21.0-x86_64-unknown-linux-musl
# cp ./bat ~/bin
# cp ./bat.1 ~/share/man/man1/
# 安裝 bat 的主題 (也可不裝，它有很多預設的主題)
# mkdir -p "$(bat --config-dir)/themes"
# cd "$(bat --config-dir)/themes"
# git clone https://github.com/greggb/sublime-snazzy

export FZF_DEFAULT_COMMAND="fd --type file"
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --preview '(highlight -O ansi {} || cat {}) 2> /dev/null | head -500' --bind 'alt-d:toggle-preview'"
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --preview '(highlight -O ansi {} || bat --color=\"always\" {}) 2> /dev/null | head -500' --bind 'alt-d:toggle-preview'"
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --preview '(highlight -O ansi {} || bat --color=\"always\" --theme=\"Sublime Snazzy\" {}) 2> /dev/null | head -500' --bind 'alt-d:toggle-preview'"
# server
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --preview '([[ -f {} ]] && (bat --color=\"always\" --theme=\"Visual Studio Dark+\" {} || cat {})) || ([[ -d {} ]] && (tree -C {} | head -200)) || echo {} 2> /dev/null | head -200' --bind 'alt-d:toggle-preview,f1:execute(vim -c \"execute \\\"edit\\\" expand({})\" >/dev/tty),f2:execute(code {})'"

# wsl
# export FZF_DEFAULT_OPTS="--no-mouse --bind 'alt-j:preview-down,alt-k:preview-up' --height 40% --layout=reverse --preview '([[ -f {} ]] && (bat --color=\"always\" --theme=\"Visual Studio Dark+\" {} || cat {})) || ([[ -d {} ]] && (tree -C {} | head -200)) || echo {} 2> /dev/null | head -200' --bind 'alt-d:toggle-preview,f1:execute(notepad++.exe {}),f2:execute(code {})'"
export FZF_DEFAULT_OPTS="--no-mouse --bind 'ctrl-o:preview-down,ctrl-u:preview-up'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'alt-k:down,alt-i:up'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'tab:toggle-out,shift-tab:toggle-in'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'alt-d:toggle-preview'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'alt-j:change-preview-window(99%,right),alt-l:change-preview-window(50%,right)'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --height 40% --layout=reverse --preview '([[ -f {} ]] && (bat --color=\"always\" --theme=\"Visual Studio Dark+\" {} || cat {})) || ([[ -d {} ]] && (tree -C {} | head -200)) || echo {} 2> /dev/null | head -200'"
# FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'f1:execute(vim -c \"execute \\\"edit\\\" expand({})\" >/dev/tty),f2:execute(code {})'"
# f1 用 env.sh 決定的 $EDITOR（nvim / nvim.appimage / vim）
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'f1:execute($EDITOR {}),f2:execute(code {})'"

# kitty image preview (requeir openGL3.3 above in Lab PC [we don't have])
# export FZF_DEFAULT_OPTS="--no-mouse --height 40% --layout=reverse --preview '([[ -f {} ]] && (kitty icat --clear --place 200x40@0x0 --transfer-mode file {} || bat --color=\"always\" --theme=\"Visual Studio Dark+\" {} || cat {})) || ([[ -d {} ]] && (tree -C {} | head -200)) || echo {} 2> /dev/null | head -200' --bind 'alt-d:toggle-preview,f1:execute(notepad++.exe {}),f2:execute(code {})'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    export|unset) fzf "$@" --preview "eval 'echo \$'{}" ;;
    ssh)          fzf "$@" --preview 'dig {}' ;;
    *)            fzf "$@" ;;
  esac
}

# export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200' --bind 'alt-j:preview-down,alt-k:preview-up'"
# export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window hidden:wrap"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200' --bind 'alt-k:preview-down,alt-i:preview-up'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window hidden:wrap --bind 'alt-d:toggle-preview'"

# fzf 安裝腳本產生的 key binding（~/.fzf.bash / ~/.fzf.zsh，不進 repo）
if [ -n "$ZSH_VERSION" ]; then
  [ -f ~/.fzf.zsh ] && . ~/.fzf.zsh
elif [ -n "$BASH_VERSION" ]; then
  [ -f ~/.fzf.bash ] && . ~/.fzf.bash
fi

# ---------------------------------------------------------------- nvm
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  # 預設用 nvm alias default；這台要固定版本就在 ~/.tool.local 寫 nvm use 20
  nvm use default >/dev/null 2>&1
fi

# ---------------------------------------------------------------- cargo
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# ---------------------------------------------------------------- autojump
# zsh 由 oh-my-zsh 的 autojump plugin 載入，這裡只處理 bash
if [ -n "$BASH_VERSION" ] && [ -s "$HOME/.autojump/etc/profile.d/autojump.sh" ]; then
  . "$HOME/.autojump/etc/profile.d/autojump.sh"
fi
