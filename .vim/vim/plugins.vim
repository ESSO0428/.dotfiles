call plug#begin()
  " The default plugin directory will be as follows:
  "   - Vim (Linux/macOS): '~/.vim/plugged'
  "   - Vim (Windows): '~/vimfiles/plugged'
  "   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
  " You can specify a custom plugin directory by passing it as the argument
  "   - e.g. `call plug#begin('~/.vim/plugged')`
  "   - Avoid using standard Vim directory names like 'plugin'

  " Make sure you use single quotes

  Plug 'gcmt/taboo.vim'

  if version >= 801
    Plug 'jayli/vim-easycomplete'
    Plug 'tpope/vim-obsession'
    Plug 'dhruvasagar/vim-prosession'
    Plug 'ojroques/vim-oscyank', {'branch': 'main'}
  endif

  Plug 'lfv89/vim-interestingwords'
  Plug 'tpope/vim-surround'
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'gcmt/taboo.vim'

  Plug 'jiangmiao/auto-pairs'
  Plug 'theniceboy/antovim'

  Plug 'frazrepo/vim-rainbow'
call plug#end()
