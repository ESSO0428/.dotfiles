#!/usr/bin/env bash
# NOTE: tmux config
cp ~/.tmux/.tmux.conf ./.tmux/.tmux.conf
cp ~/.tmux.conf.local ./.tmux.conf.local

# NOTE: bin directory tools (ssh-tunnel, etc)
cp ~/bin/ssh-tunnel-manager ./bin/ssh-tunnel-manager
cp ~/bin/reverse-ssh-tunnel-manager ./bin/reverse-ssh-tunnel-manager


