export DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0.0
export DISPLAY=:0

shell_name=$(ps -p $$ -o comm=)
SHELL=$shell_name


# NOTE: install oh-my-zsh and it's plugins
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
## p10k theme (if you want reset p10k preset, execute `p10k configure`)
# git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
## zsh plugins 
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# NOTE: load .bashrc (Optional) and oh-my-zsh
# source $HOME/.bashrc
source $ZSH/oh-my-zsh.sh


PATH=$HOME/bin/:$PATH
# alias tmux='~/bin/tmux/tmux'
export PATH="$HOME/bin/tmux:$PATH"
PATH=$HOME/.local/bin:$PATH
# golang (go)
# wget https://go.dev/dl/go1.19.10.linux-amd64.tar.gz
PATH=$HOME/bin/go/bin/:$PATH


# for ranger
alias ra="ranger"
export RANGER_LOAD_DEFAULT_RC FALSE
alias nvim="~/nvim.appimage"
export VISUAL="lvim"
export EDITOR="lvim"
export RANGER_LOAD_DEFAULT_RC=FALSE

# install cargo and nvm
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm use 20
. "$HOME/.cargo/env"


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# warning inhibition (Optional) 
# typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
# typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
