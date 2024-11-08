" ==================== Auto load for first time uses ====================
" for other server user can add alias uvim="vim -N -u /home/Andy6/.vimrc" to .bashrc
" (can use my local config <inculde plug and keymap> IsOnweriVrmc) 
" <if this .vimrc not in your directory but in my>
nmap <esc>[1;5D <C-Left>
nmap <esc>[1;5C <C-Right>
vnoremap <nowait> <Esc> <Esc>

tmap <c-v> <C-W>"+

cmap <esc>OH <home>
imap <esc>OH <home>
cmap <esc>OF <end>
imap <esc>OF <end>

function! s:metacode(key, clear)
  if a:clear
  exec "set <M-".a:key.">="
  else
  exec "set <M-".a:key.">=\e".a:key
  endif
endfunc

function! s:set_meta(clear)
  for i in range(10)
  call s:metacode(nr2char(char2nr('0') + i), a:clear)
  endfor
  for i in range(26)
  call s:metacode(nr2char(char2nr('a') + i), a:clear)
  let t = nr2char(char2nr('A') + i)
  call s:metacode(t, a:clear)
  endfor
  for c in [',', '.', '/', ';', '{', '}','\']
  call s:metacode(c, a:clear)
  endfor
  for c in ['?', ':', '-', '_', '+', '=', "'"]
  call s:metacode(c, a:clear)
  endfor
endfunction

" init
call s:set_meta(0)

function! s:auto_meta(clear)
  if &bt == 'terminal'
    if a:clear
      call s:set_meta(1)
    else
      call s:set_meta(0)
    endif
  endif
endfunction

augroup TermMeta
  autocmd!
  autocmd WinEnter * call <sid>auto_meta(1)
  autocmd WinLeave * call <sid>auto_meta(0)
augroup END
fu s:fix_terminal_readline() abort
  for key in map(range(char2nr('a'), char2nr('z')) + range(char2nr('A'), char2nr('Z')), 'nr2char(v:val)')
    exe 'tno <m-' .. key .. '> <esc>' .. key
  endfor
endfu
call s:fix_terminal_readline()

let use_custom_statusline = 0
let use_plugins = 1

let g:MYVIMRC="$HOME/.vimrc"
function! IsOwneriVrmc()
  for arg in v:argv
    if arg == '-u'
      return v:false
    endif
  endfor
  return v:true
endfunction

function! GetVimrcDir()
  let vimrc_path = ""
  let found_u = v:false
  for i in range(1, len(v:argv) - 1)
    if v:argv[i] == '-u'
      let vimrc_path = v:argv[i + 1]
      let found_u = v:true
      break
    endif
  endfor

  let vimrc_dir = fnamemodify(vimrc_path, ':p:h')

  return [found_u, vimrc_dir]
endfunction

let IsOwneriVrmc = IsOwneriVrmc()
let [IsFindOwnerVimrcDir, OwnerVimrcDir] = GetVimrcDir()

if IsOwneriVrmc
  if empty(glob($HOME.'/.vim/autoload/plug.vim')) && use_plugins
    silent !curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
	call system('chmod o+rx -R ' . expand('$HOME') . '/.vim/autoload')
  endif
endif

set hidden
set noswapfile
set mouse=a
set foldmethod=indent
set foldlevel=99
set foldenable
set hlsearch
set clipboard=unnamedplus
autocmd VimLeave * silent !echo -ne "\e[6 q"
syntax enable
" for i in range(97,122)
"   let c = nr2char(i)
"   exec "map \e".c." <M-".c.">"
"   exec "map! \e".c." <M-".c.">"
"   exec "map \e".c." <a-".c.">"
"   exec "map! \e".c." <a-".c.">"
" endfor

inoremap <a-j> <esc>
inoremap <a-i> <c-p>
inoremap <a-k> <c-n>

set nowarn
set number
set cursorline
" format tab to 4 space => not format
set noexpandtab
" set tabstop=2
set tabstop=4
" set shiftwidth=2
set shiftwidth=4
" set softtabstop=2
set softtabstop=4
set autoindent


set splitright
set splitbelow
set noequalalways


let mapleader=" "
nnoremap <leader>dft :diffthis<cr>
nnoremap <leader>dfw :diffoff<cr>
nnoremap <leader>dfW :diffoff!<cr>
nnoremap <leader>dfs :set scrollbind!<cr>
nnoremap <leader>dfe :widno set noscrollbind<cr>
autocmd BufRead,BufNewFile *.md inoremap <buffer> ,, <++>
      \| inoremap <buffer> ,c ```<++>```<CR><CR><++><Esc>2ki<CR><Esc>f>a<CR><Esc>2k$a
      \| inoremap <buffer> ,f <Esc>/<++><CR>:nohlsearch<CR>"_c4l
      \| inoremap <buffer> ,b `<++>`<Esc>F`a


hi NonText ctermfg=gray guifg=#414348
hi Visual cterm=reverse gui=reverse

hi LineNr ctermfg=244
hi CursorLine cterm=none ctermbg=236 ctermfg=none
hi CursorLineNr term=bold cterm=none ctermfg=226 gui=bold guifg=Brown

hi Folded ctermfg=14 ctermbg=242


set guifont=Courier\ New:h30
nnoremap Q :qa<CR>
nnoremap S :w<CR>
" Open the vimrc file anytime

" Undo operations
" colemak keyboard
" noremap l u
" normal keyboard
nmap u <Nop>
nnoremap z u
" Insert Key
noremap h i
noremap H I
" Copy to system clipboard
vnoremap Y "+y
" Find pair
nnoremap g{ %
vnoremap g{ %
nnoremap g} $%
vnoremap g} $%
" Search
noremap <LEADER><CR> :nohlsearch<CR>

" Folding
nnoremap <silent> <LEADER>o za
nnoremap <silent> <LEADER>Oa zM
nnoremap <silent> <LEADER>Od zR

vnoremap <silent> <LEADER>o za
vnoremap <silent> <LEADER>Oa zC
vnoremap <silent> <LEADER>Od zO

nnoremap <silent> [{ zk
nnoremap <silent> ]} zj
nnoremap <silent> <c-HOME> zk
nnoremap <silent> <c-END> zj
nnoremap <silent> <a-[> zk
nnoremap <silent> <a-]> zj


nnoremap o o<ESC>
nnoremap u O<ESC>
nnoremap O <Nop>
nnoremap O dd

noremap u O<ESC>
noremap U ddk
" noremap <c-y> yyp
nnoremap <a-i> <c-u>
nnoremap <a-k> <c-d>
nnoremap <c-d> yyp
" nmap < <<CR>
" nmap > ><CR>
nnoremap x "_x
nnoremap <leader>d "_d
nnoremap <leader>D "_D
nnoremap <leader>c "_c
nnoremap <leader>C "_C
vnoremap <leader>d "_d
vnoremap <leader>D "_D
vnoremap <leader>c "_c
vnoremap <leader>C "_C

" nnoremap <c-n> <tab>
nnoremap <Tab> >>_
nnoremap <S-Tab> <<_
inoremap <S-Tab> <C-D>
" inoremap <S-Tab> <CD>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
vnoremap <leader><c-c> "+y
vnoremap <leader><c-x> "+d
noremap gj J
vnoremap gj J
nnoremap <a-a> <c-x>
nnoremap <a-d> <c-a>

nnoremap <a-v> <c-v>
inoremap <c-v> <c-r>+
nnoremap <c-v> p

nnoremap <c-o> 10<C-E>
nnoremap <c-u> 10<C-Y>
" ==================== Cursor Movement ====================
" New cursor movement (the default arrow keys are used for resizing windows)
"   ^
"   i
" < j   l >
"   k
"   v

" normal keyborad
noremap <silent> i k
noremap <silent> j h
noremap <silent> k j
" noremap <silent> l l

" colemak keyborad
" noremap <silent> gu gk
" noremap <silent> ge gj
noremap <silent> \v v$h

" normal keyborad
noremap <silent> gi gk
noremap <silent> gk gj

" U/E keys for 5 times u/e (faster navigation)
" colemak keyborad
" noremap <silent> U 5k
" noremap <silent> E 5j
" normal keyborad
noremap <silent> I 5k
noremap <silent> K 5j


" N key: go to the start of the line
" colemak keyborad
" noremap <silent> N 0
" normal keyborad
noremap <silent> J 0
" I key: go to the end of the line
" colemak keyborad
" noremap <silent> I $
" normal keyborad
noremap <silent> L $
" Faster in-line navigation
noremap W 5w
noremap B 5b

" ==================== buffer control =======================
nnoremap <c-j> :bprevious<CR>
nnoremap <c-l> :bnext<CR>
nnoremap <c-w> :bd<CR>
nnoremap <leader><c-w> :bd!<CR>
nnoremap <leader>d<c-w> :bd!<CR>


" ==================== Window management ====================
" Use <space> + new arrow keys for moving the cursor around windows
" colemak keyboard
" noremap <LEADER>w <C-w>w
if version >= 801
  tnoremap <c-n> <C-w>N
endif  

" noremap <LEADER>u <C-w>k
" noremap <LEADER>e <C-w>j
" noremap <LEADER>n <C-w>h
" noremap <LEADER>i <C-w>l
noremap qf <C-w>o
" normal keyboard
noremap <LEADER>i <C-w>k
noremap <LEADER>k <C-w>j
noremap <LEADER>j <C-w>h
noremap <LEADER>l <C-w>l

noremap <LEADER>J <C-w>t
noremap <LEADER>n <C-w><C-p>

" Disable the default s key
noremap s <nop>
" split the screens to up (horizontal), down (horizontal), left (vertical), right (vertical)
" colemak keyboard
" noremap su :set nosplitbelow<CR>:split<CR>:set splitbelow<CR>
" noremap se :set splitbelow<CR>:split<CR>
" noremap sn :set nosplitright<CR>:vsplit<CR>:set splitright<CR>
" noremap si :set splitright<CR>:vsplit<CR>

" normal keyboard
noremap si :set nosplitbelow<CR>:split<CR>:set splitbelow<CR>
noremap sk :set splitbelow<CR>:split<CR>
noremap sj :set nosplitright<CR>:vsplit<CR>:set splitright<CR>
noremap sl :set splitright<CR>:vsplit<CR>

" Resize splits with arrow keys
noremap <up> :res +5<CR>
noremap <down> :res -5<CR>
noremap <left> :vertical resize-5<CR>
noremap <right> :vertical resize+5<CR>
" Place the two screens up and down
noremap sh <C-w>t<C-w>K
" Place the two screens side by side
noremap sv <C-w>t<C-w>H
" Rotate screens
noremap srh <C-w>b<C-w>K
noremap srv <C-w>b<C-w>H
" Press <SPACE> + q to close the window below the current window
noremap <silent> <leader>q :q<CR>


" ==================== Tab management ====================
" Create a new tab with tu
" colemak keyboard
" noremap tu :tabe<CR>
" noremap tU :tab split<CR>
" normal keyboard

" noremap ti :tabe<CR>
" noremap tI :tab split<CR>
" noremap ti :tabe<CR>
" noremap <F1> :tab split<CR>
nnoremap <a-'> :tab split<CR>


" Move around tabs with tn and ti
" colemak keyboard
" noremap tn :-tabnext<CR>
" noremap ti :+tabnext<CR>
" normal keyboard

" noremap tj :-tabnext<CR>
" noremap tl :+tabnext<CR>
" noremap <F2> :-tabnext<CR>
" noremap <F3> :+tabnext<CR>


" Move the tabs with tmn and tmi
" colemak keyboard
" noremap tmn :-tabmove<CR>
" noremap tmi :+tabmove<CR>
" normal keyboard
" noremap tmj :-tabmove<CR>
" noremap tml :+tabmove<CR>

nnoremap <a-'> :tab split<CR>
nnoremap <a-,> :tabprevious<CR>
nnoremap <a-.> :tabnext<CR>
" noremap <F6> :-tabmove<CR>
" noremap <F7> :+tabmove<CR>
nnoremap <C-left> :tabmove -1<CR>
nnoremap <c-right> :tabmove +1<CR>
nnoremap <a-/> :tabfirst<CR>
nnoremap <a-\> :tabclose<CR>
" noremap tc :tabclose<CR>
" noremap <F4> :tabclose<CR>


" ==================== Other useful stuff ====================
" Open a new instance of st with the cwd
nnoremap \t :tabe<CR>:-tabmove<CR>:term sh -c 'st'<CR><C-\><C-N>:q<CR>
" Opening a terminal window
nnoremap <c-\> :term<CR>
" nnoremap <LEADER>b- :b#<CR>
nnoremap <a--> :b#<CR>


" set wrap
set nowrap

" === gf control ===
autocmd BufEnter * if expand('%') != '' | set path=.,%:h | endif
nnoremap sF <c-w>F
nnoremap sf <c-w>f
nnoremap sgk <c-w>f
nnoremap sgl <c-w>vgf
nnoremap sgF <c-w>gF
nnoremap sgf <c-w>gf

function DeleteHiddenBuffers() " Vim with the 'hidden' option
  let tpbl=[]
  call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
  for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
    silent execute 'bwipeout' buf
  endfor
endfunction
command! DeleteHiddenBuffers call DeleteHiddenBuffers()
nnoremap <leader>bc :DeleteHiddenBuffers<cr>

function! SetWrapKeymaps()
  if exists('b:venn_enabled') && b:venn_enabled
    return
  endif
  if &wrap
    " 如果 wrap 為 true
    nnoremap <buffer><silent> i gk
    nnoremap <buffer><silent> k gj
    nnoremap <buffer><silent> I 5gk
    nnoremap <buffer><silent> K 5gj
    nnoremap <buffer><silent> J g0
    nnoremap <buffer><silent> L g$

    " vnoremap <buffer><silent> i gk
    " vnoremap <buffer><silent> i gk
    " vnoremap <buffer><silent> k gj
    " vnoremap <buffer><silent> I 5gk
    " vnoremap <buffer><silent> K 5gj
    " vnoremap <buffer><silent> J g0
    " vnoremap <buffer><silent> L g$
    " nowait (solution for the delay problem when plugin conflict)
    vnoremap <buffer><silent><nowait> i gk
    vnoremap <buffer><silent><nowait> k gj
    vnoremap <buffer><silent><nowait> I 5gk
    vnoremap <buffer><silent><nowait> K 5gj
    vnoremap <buffer><silent><nowait> J g0
    vnoremap <buffer><silent><nowait> L g$
  else
    " 如果 wrap 為 false
    nnoremap <buffer><silent> i k
    nnoremap <buffer><silent> k j
    nnoremap <buffer><silent> I 5k
    nnoremap <buffer><silent> K 5j
    nnoremap <buffer><silent> J 0
    nnoremap <buffer><silent> L $

    " vnoremap <buffer><silent> i k
    " vnoremap <buffer><silent> k j
    " vnoremap <buffer><silent> I 5k
    " vnoremap <buffer><silent> K 5j
    " vnoremap <buffer><silent> J 0
    " vnoremap <buffer><silent> L $
    " nowait (solution for the delay problem when plugin conflict)
    vnoremap <buffer><silent><nowait> i k
    vnoremap <buffer><silent><nowait> k j
    vnoremap <buffer><silent><nowait> I 5k
    vnoremap <buffer><silent><nowait> K 5j
    vnoremap <buffer><silent><nowait> J 0
    vnoremap <buffer><silent><nowait> L $
  endif
endfunction

" 每次切換緩衝區或打開新文件時執行 SetWrapKeymaps 函數
autocmd BufEnter * call SetWrapKeymaps()
autocmd OptionSet wrap call SetWrapKeymaps()

nnoremap <a-q> :copen<cr>
nnoremap <leader>[ :cprevious<cr>
nnoremap <leader>] :cnext<cr>

" NOTE: Ensure cursor style matches Normal mode on the welcome screen by briefly entering Command-line mode
autocmd VimEnter * silent normal :<ESC>

if exists('$TMUX')
  " let &t_SI = "\<Esc>Ptmux;\<Esc>\e[5 q\<Esc>\\"
  " let &t_EI = "\<Esc>Ptmux;\<Esc>\e[2 q\<Esc>\\"
  let &t_SI = "\e[5 q"
  let &t_EI = "\e[2 q"
else
  let &t_SI = "\e[5 q"
  let &t_EI = "\e[2 q"
endif

let UserVimrcDir=$HOME
if IsFindOwnerVimrcDir
 let UserVimrcDir = OwnerVimrcDir
 let &rtp = OwnerVimrcDir . '/.vim' . ',' . &rtp
endif

if has('nvim')
else
  execute 'noremap <leader>rc :e '.UserVimrcDir.'/.vimrc<CR>'
  noremap <leader>rb :e $HOME/.bashrc<CR>
  execute 'source '.UserVimrcDir.'/'.'.vim/vim/explorer.vim'
  execute 'source '.UserVimrcDir.'/'.'.vim/vim/buffer.vim'

  if empty(glob(UserVimrcDir.'/'.'.vim/plugged/vim-airline/plugin/airline.vim')) || use_custom_statusline
    execute 'source '.UserVimrcDir.'/'.'.vim/vim/statusline.vim'
  endif

  if !empty(glob(UserVimrcDir.'/'.'.vim/autoload/plug.vim')) && use_plugins
    execute 'source '.UserVimrcDir.'/'.'.vim/vim/plugins.vim'
  
    execute 'source '.UserVimrcDir.'/'.'.vim/vim/opt.vim'
    execute 'source '.UserVimrcDir.'/'.'.vim/vim/keymap.vim'
  
    execute 'source '.UserVimrcDir.'/'.'.vim/vim/user/interestingWords.vim'
    execute 'source '.UserVimrcDir.'/'.'.vim/vim/user/fold-cycling.vim'
    execute 'source '.UserVimrcDir.'/'.'.vim/vim/user/fzf.vim'
  endif
endif
