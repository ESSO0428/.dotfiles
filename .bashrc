# export LIBGL_ALWAYS_INDIRECT=1
export DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0.0
export DISPLAY=:0
# LIBGL_ALWAYS_INDIRECT=0

# [ -f ~/.fzf.bash ] && source ~/.fzf.bash

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
export FZF_DEFAULT_OPTS="--no-mouse --bind 'alt-k:preview-down,alt-i:preview-up'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'ctrl-k:down,ctrl-i:up'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'tab:toggle-out,shift-tab:toggle-in'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'alt-d:toggle-preview'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'ctrl-j:change-preview-window(99%,right),ctrl-l:change-preview-window(50%,right)'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'alt-j:change-preview-window(99%,right),alt-l:change-preview-window(50%,right)'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --height 40% --layout=reverse --preview '([[ -f {} ]] && (bat --color=\"always\" --theme=\"Visual Studio Dark+\" {} || cat {})) || ([[ -d {} ]] && ( tree -C {} | head -200)) || echo {} 2> /dev/null | head -200'"
# FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'f1:execute(vim -c \"execute \\\"edit\\\" expand({})\" >/dev/tty),f2:execute(code {})'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'f1:execute(~/nvim.appimage {}),f2:execute(code {})'"



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
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window hidden:wrap"

export PATH=$PATH:/mnt/c/Program\ Files/Notepad++
alias npp="notepad++.exe"
# alias j2dp="cd /mnt/y"
alias open="/mnt/c/AP/Anaconda3/Scripts/open.exe"

. "$HOME/.cargo/env"


# mkdir -p /mnt/y
# sudo mount -t drvfs Y: /mnt/y

# ranger
alias ra="ranger"
export RANGER_LOAD_DEFAULT_RC FALSE

# user bin
PATH=$HOME/bin/:$PATH

alias nvim="~/nvim.appimage"
PATH=/root/.local/bin:$PATH
# golang (go)
# wget https://go.dev/dl/go1.19.10.linux-amd64.tar.gz
PATH=$HOME/bin/go/bin/:$PATH


