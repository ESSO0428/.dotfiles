" ==================== Auto load for first time uses ====================
let use_custom_statusline = 0
let use_plugins = 1

if empty(glob($HOME.'/.vim/autoload/plug.vim')) && use_plugins
  silent !curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

set hidden
set noswapfile
set mouse=a
set foldmethod=indent
set foldlevel=99
set hlsearch
set clipboard=unnamedplus
autocmd VimLeave * silent !echo -ne "\e[6 q"
syntax enable
for i in range(97,122)
  let c = nr2char(i)
  exec "map \e".c." <M-".c.">"
  exec "map! \e".c." <M-".c.">"
  exec "map \e".c." <a-".c.">"
  exec "map! \e".c." <a-".c.">"
endfor

inoremap <a-j> <esc>

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

noremap <LEADER><LEADER> <Esc>/<++><CR>:nohlsearch<CR>"_c4l
"
" inoremap ,, <++>
"" inoremap ,b `` <++><Left><Left><Left><Left><Left><Left>
" inoremap ,b `` <++><esc>F`a
"" inoremap ,c ```<++>```<cr><cr><++><Up><Up><Left><cr><Right><Right><Right><Right><cr><Up><Up><Right><Right><Right>
" inoremap ,c ```<++>```<cr><cr><++><esc>2ki<cr><esc>f>a<cr><esc>2k$a
" inoremap ,f <Esc>/<++><CR>:nohlsearch<CR>"_c4l
inoremap ,a <C-D>

autocmd BufRead,BufNewFile *.md inoremap <buffer> ,, <++>
            \| inoremap <buffer> ,c ```<++>```<CR><CR><++><Esc>2ki<CR><Esc>f>a<CR><Esc>2k$a
            \| inoremap <buffer> ,f <Esc>/<++><CR>:nohlsearch<CR>"_c4l
            \| inoremap <buffer> ,b `<++>`<Esc>F`a


hi NonText ctermfg=gray guifg=#414348


set guifont=Courier\ New:h30
let mapleader=" "
nnoremap Q :qa<CR>
nnoremap S :w<CR>
" Open the vimrc file anytime

" Undo operations
" colemak keyboard
" noremap l u
" normal keyboard
nmap u <Nop>
noremap z u
" Insert Key
noremap h i
noremap H I
" Copy to system clipboard
vnoremap Y "+y
" Find pair
noremap ,. %
vnoremap ni $%
" Search
noremap <LEADER><CR> :nohlsearch<CR>

" Folding
noremap <silent> <LEADER>o za
noremap <silent> <LEADER>Oa zM
noremap <silent> <LEADER>Od zR

noremap o o<ESC>
noremap u O<ESC>
noremap O <Nop>
noremap O dd

noremap u O<ESC>
noremap U ddk
" noremap <c-y> yyp
noremap <c-d> yyp
" nmap < <<CR>
" nmap > ><CR>

nnoremap <c-n> <tab>
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
noremap <a-a> <c-x>
noremap <a-d> <c-a>

nnoremap <a-v> <c-v>
" ==================== Cursor Movement ====================
" New cursor movement (the default arrow keys are used for resizing windows)
"     ^
"     i
" < j   l >
"     k
"     v

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
noremap <c-w> :bd<CR>
noremap <LEADER><c-w> :bd!<CR>


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
noremap <F1> :tab split<CR>


" Move around tabs with tn and ti
" colemak keyboard
" noremap tn :-tabnext<CR>
" noremap ti :+tabnext<CR>
" normal keyboard

" noremap tj :-tabnext<CR>
" noremap tl :+tabnext<CR>
noremap <F2> :-tabnext<CR>
noremap <F3> :+tabnext<CR>


" Move the tabs with tmn and tmi
" colemak keyboard
" noremap tmn :-tabmove<CR>
" noremap tmi :+tabmove<CR>
" normal keyboard
" noremap tmj :-tabmove<CR>
" noremap tml :+tabmove<CR>

noremap <a-'> :tab split<CR>
noremap <a-,> :tabprevious<CR>
noremap <a-.> :tabnext<CR>
noremap <F6> :-tabmove<CR>
noremap <F7> :+tabmove<CR>
noremap <a-\> :tabclose<CR>
" noremap tc :tabclose<CR>
noremap <F4> :tabclose<CR>


" ==================== Other useful stuff ====================
" Open a new instance of st with the cwd
nnoremap \t :tabe<CR>:-tabmove<CR>:term sh -c 'st'<CR><C-\><C-N>:q<CR>
" Opening a terminal window
noremap <LEADER>/ :set splitbelow<CR>:split<CR>:res +10<CR>:term<CR>
noremap <LEADER>b- :b#<CR>


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

function! FindAndSelectFile(window_command)
  let cfile = expand('<cfile>')
  let newcfile = substitute(cfile, '^\(\.\./\|\./\)\{1,}', '', '')
  let newcfile = substitute(newcfile, '/$', '', '')
  let dir = '**/' . newcfile
  let dirlist = split(glob(dir), '\n')
  
  " 再次檢查 dirlist，保留目錄，移除非目錄項目
  let new_dirlist = []
  for item in dirlist
    if isdirectory(item)
      call add(new_dirlist, item . '/')
    endif
  endfor

  if len(new_dirlist) > 0
    let file = '**/' . newcfile . '/**'
    let filelist = split(glob(file), '\n')

    " 將 dirlist 加到 filelist 前面
    call extend(new_dirlist, filelist)
    let filelist = new_dirlist
  else
    let file = '**/*' . newcfile . '*'
    let filelist = split(glob(file), '\n')
  endif
  
  " Sort the filelist
  call sort(filelist)

  if len(filelist) == 0
    echo "No matching files found."
    return
  elseif len(filelist) == 1
    if a:window_command == 'sp'
      execute 'set splitbelow'
      execute 'split'
    elseif a:window_command == 'vsp'
      execute 'set splitright'
      execute 'vsplit'
    endif
    if a:window_command == 'tab'
        execute 'tabe ' . filelist[0]
    else
        execute 'e ' . filelist[0]
    endif
  else
    echomsg "Multiple files found:"
    echomsg "---------------------"
    for i in range(len(filelist))
      echomsg printf("%2d: %s", i + 1, filelist[i])
    endfor
    echomsg "Press a number to open the corresponding file:"
    let choice = nr2char(getchar())
    let file_index = str2nr(choice) - 1
    if file_index >= 0 && file_index < len(filelist)
      if a:window_command == 'sp'
        execute 'set splitbelow'
        execute 'split'
      elseif a:window_command == 'vsp'
        execute 'set splitright'
        execute 'vsplit'
      endif
      if a:window_command == 'tab'
        execute 'tabe ' . filelist[file_index]
      else
        execute 'e ' . filelist[file_index]
      endif
    endif
  endif
endfunction

nnoremap <silent> gm :call FindAndSelectFile('')<CR>
nnoremap <silent> sgmk :call FindAndSelectFile('sp')<CR>
nnoremap <silent> sgml :call FindAndSelectFile('vsp')<CR>
nnoremap <silent> sm :call FindAndSelectFile('tab')<CR>


if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\e[5 q\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\e[2 q\<Esc>\\"
else
  let &t_SI = "\e[5 q"
  let &t_EI = "\e[2 q"
endif

if has('nvim')
else

  noremap <leader>rc :e $HOME/.vimrc<CR>
  noremap <leader>rb :e $HOME/.bashrc<CR>

  source ~/.vim/vim/explorer.vim
  source ~/.vim/vim/buffer.vim

  if empty(glob($HOME.'/.vim/plugged/vim-airline/plugin/airline.vim')) || use_custom_statusline
	source ~/.vim/vim/statusline.vim
  endif

endif

if !empty(glob($HOME.'/.vim/autoload/plug.vim')) && use_plugins
  source ~/.vim/vim/plugins.vim

  source ~/.vim/vim/opt.vim
  source ~/.vim/vim/keymap.vim

  source ~/.vim/vim/user/interestingWords.vim
  source ~/.vim/vim/user/fzf.vim
endif
