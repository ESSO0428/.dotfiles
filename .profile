# ~/.profile: executed by Bourne-compatible login shells.

# if [ "$BASH" ]; then
#   if [ -f ~/.bashrc ]; then
#     . ~/.bashrc
#   fi
# fi
if [[ $- != *i* ]]; then
  return
fi

exec zsh
mesg n 2> /dev/null || true
. "$HOME/.cargo/env"
