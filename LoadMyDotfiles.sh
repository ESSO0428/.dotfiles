#!/usr/bin/env bash
# NOTE: tmux config
mv ~/.tmux/.tmux.conf ~/.tmux/.tmux.conf.old
mv ~/.tmux.conf.local ~/.tmux.conf.local.old
cp ./.tmux/.tmux.conf ~/.tmux/.tmux.conf
cp ./.tmux.conf.local ~/.tmux.conf.local

# NOTE: bin directory tools (fzf_rg, ssh-tunnel, etc)
mkdir -p ~/bin/
cp ./bin/fzf_rg ~/bin/fzf_rg
cp ./bin/ssh-tunnel-manager ~/bin/ssh-tunnel-manager
cp ./bin/reverse-ssh-tunnel-manager ~/bin/reverse-ssh-tunnel-manager

# NOTE: .config directory (ranger)
mkdir -p ~/.config/
cp -r ./.config/ranger/ ~/.config/

# NOTE: vim config
bash LoadMyVimConfigOnly.sh

# NOTE: chmod setting
chmod +x ~/.tmux/.tmux.conf
chmod +x ~/.tmux.conf.local

chmod +x ~/bin/fzf_rg
chmod +x ~/bin/ssh-tunnel-manager
chmod +x ~/bin/reverse-ssh-tunnel-manager

chmod +x ~/.config/ranger/

