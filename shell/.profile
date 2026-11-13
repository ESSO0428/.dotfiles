# ~/.profile: executed by Bourne-compatible login shells.

# if [ "$BASH" ]; then
#   if [ -f ~/.bashrc ]; then
#     . ~/.bashrc
#   fi
# fi
# NOTE: .profile 也可能被 sh / dash 讀取（例如圖形登入），不能用 bash 的 [[ ]]
#   dash 不認得 [[，判斷失敗就不會 return，非互動登入也會跑到下面的 exec zsh
case $- in
  *i*) ;;
  *) return ;;
esac

# NOTE: 有 zsh 才切換，沒裝 zsh 時留在目前的 shell（exec 失敗會中斷登入流程）
if command -v zsh >/dev/null 2>&1; then
  exec zsh
fi
mesg n 2> /dev/null || true
# 沒裝 rust / cargo 時跳過
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi
