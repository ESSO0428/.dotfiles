# .bashrc

# Source global definitions (if jump from zshrc not read /etc/bashrc)
if [ "$JumpFromZSHRC" != "Y" ]; then
	if [ -f /etc/bashrc ]; then
		. /etc/bashrc
	fi
fi
# After skip read /etc/bashrc/ unset JumpFromZSHRC
if [ "$JumpFromZSHRC" = "Y" ]; then unset JumpFromZSHRC; fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH
#export PATH=$(echo $PATH | sed -e 's;/usr/bin;;')
#export PATH=$(echo $PATH | sed -e 's;/bin;;')
export PATH=$(echo $PATH | sed -e 's;/opt/anaconda3/bin;;')

export PATH=$PATH:$HOME/bin/tree-1.7.0
# export MODIN_ENGINE=ray
# export PATH=$PATH:$HOME/gatk-4.1.8.1

export PATH="$PATH:$HOME/.vscode-server/bin/899d46d82c4c95423fb7e10e68eba52050e30ba3/bin"

LD_LIBRARY_PATH=/home/Andy6/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH

# export R_HOME="/home/Andy6/anaconda3/envs/R4.1/lib/R"

# x86_64-conda-linux-gnu-cc 為了在 R 上安裝 languageserver
# export PATH="$PATH:/home/Andy6/anaconda3/envs/R4.1/bin/"
# export CC="/home/Andy6/anaconda3/envs/R4.1/bin/x86_64-conda-linux-gnu-cc"
# export CXX="/home/Andy6/anaconda3/envs/R4.1/bin/x86_64-conda-linux-gnu-g++"

# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --preview '(highlight -O ansi {} || cat {}) 2> /dev/null | head -500' --bind 'alt-d:toggle-preview'"
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --preview '(highlight -O ansi {} || bat --color=\"always\" {}) 2> /dev/null | head -500' --bind 'alt-d:toggle-preview'"
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --preview '(highlight -O ansi {} || bat --color=\"always\" --theme=\"Sublime Snazzy\" {}) 2> /dev/null | head -500' --bind 'alt-d:toggle-preview'"
# export FZF_DEFAULT_OPTS="--no-mouse --bind 'alt-j:preview-down,alt-k:preview-up'  --height 40% --layout=reverse --preview '([[ -f {} ]] && (bat --color=\"always\" --theme=\"Visual Studio Dark+\" {} || cat {})) || ([[ -d {} ]] && (tree -C {} | head -200)) || echo {} 2> /dev/null | head -200' --bind 'alt-d:toggle-preview'"

export FZF_DEFAULT_OPTS="--no-mouse --bind 'alt-k:preview-down,alt-i:preview-up'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'ctrl-k:down,ctrl-i:up'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'tab:toggle-out,shift-tab:toggle-in'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'alt-d:toggle-preview'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'ctrl-j:change-preview-window(99%,right),ctrl-l:change-preview-window(50%,right)'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'alt-j:change-preview-window(99%,right),alt-l:change-preview-window(50%,right)'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --height 40% --layout=reverse --preview '([[ -f {} ]] && (bat --color=\"always\" --theme=\"Visual Studio Dark+\" {} || cat {})) || ([[ -d {} ]] && (tree -C {} | head -200)) || echo {} 2> /dev/null | head -200'"

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
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200' --bind 'alt-j:preview-down,alt-k:preview-up'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window hidden:wrap"

# alias nvim="~/nvim.appimage"

# nodejs
# PATH=$HOME/bin/node-v18.12.1-linux-x64/bin:$PATH
# golang (go)
PATH=$HOME/bin/go/bin/:$PATH

. "$HOME/.cargo/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm use 19.8.1

# alias tmux='~/bin/tmux/tmux'
export PATH="$HOME/bin/tmux:$PATH"
# for ranger
alias ra="ranger"
export VISUAL="lvim"
export EDITOR="lvim"
export RANGER_LOAD_DEFAULT_RC=FALSE


export PATH=$PATH:~/bin/apache-maven-3.8.8/bin


