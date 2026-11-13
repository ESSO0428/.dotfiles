# oh-my-zsh 設定（只給 zsh，由 ~/.zshrc source，會同步到每台）

# NOTE: install oh-my-zsh and it's plugins
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
## p10k theme (if you want reset p10k preset, execute `p10k configure`)
# git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
## zsh plugins
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
DEFAULT_USER=$USER
ZSH_THEME="powerlevel10k/powerlevel10k"

# 只啟用這台裝得到的 plugin（缺 plugin 或缺工具時 oh-my-zsh 會報錯）
plugins=(git)
for _p in fzf zsh-autosuggestions autojump zsh-syntax-highlighting web-search; do
  [[ -d $ZSH/plugins/$_p || -d ${ZSH_CUSTOM:-$ZSH/custom}/plugins/$_p ]] || continue
  case $_p in
    fzf)      (( $+commands[fzf] )) || [[ -d ~/.fzf ]] || continue ;;
    autojump) (( $+commands[autojump] )) || [[ -s ~/.autojump/etc/profile.d/autojump.sh ]] || continue ;;
  esac
  plugins+=($_p)
done
unset _p

[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"
