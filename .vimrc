" ==================== Auto load for first time uses ====================
if empty(glob($HOME.'/.vim/autoload/plug.vim'))
	silent !curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs
	\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

set hidden
set mouse=a
set foldmethod=indent
set foldlevel=99
set hlsearch
set clipboard=unnamedplus
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

  function CleanUselessBuffers()                                                   
      for buf in getbufinfo()                                                                                               
          if buf.name == "" && buf.changed == 0 && buf.loaded == 1                   
              :execute ':bdelete ' . buf.bufnr                                       
          endif                                                                      
      endfor                                                                         
  endfunction                                                                 
                                                                                     
  function ToggleLex()                                                             
      call CleanUselessBuffers()                                                   
                                                                                     
      " we iterate through the buffers again because some netrw buffers are          
      " skipped after we browsed to a different location and hence the name          
      " of the window changed (no longer '')                                         
      let flag = 0                                                                   
      for buf in getbufinfo()                                                        
          if (get(buf.variables, "current_syntax", "") == "netrwlist") && buf.changed == 0 && buf.loaded == 1
              :execute  ':bdelete ' . buf.bufnr                                      
              let flag = 1                                                           
          endif                                                                      
      endfor                                                                         
                                                                                     
      if !flag                                                                    
          :Lexplore                                                               
      endif                                                                       
  endfunction
  if version >= 801
    " noremap <leader>e :Lexplore<cr>
    noremap <silent><leader>e :call ToggleLex()<CR>
  else
    noremap <silent><leader>e :Explore<CR>
  endif
  augroup netrw_mapping
     autocmd!
     autocmd filetype netrw call NetrwMapping()
  augroup END

  function! NetrwMapping()
     noremap <buffer> i k
     noremap <buffer> I 5k
     " noremap <buffer> l <Plug>NetrwLocalBrowseCheck
     nmap <buffer> l <cr>
  endfunction
  " ====== Deleting a buffer without closing the window ======
  "here is a more exotic version of my original Kwbd script
  "delete the buffer; keep windows; create a scratch buffer if no buffers left
  " Create a mapping (e.g. in your .vimrc) like this:
  function s:Kwbd(kwbdStage)
    if(a:kwbdStage == 1)
      if(&modified)
        let answer = confirm("This buffer has been modified.  Are you sure you want to delete it?", "&Yes\n&No", 2)
        if(answer != 1)
          return
        endif
      endif
      if(len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1)
        bd!
        return
      endif
      if(!buflisted(winbufnr(0)))
        bd!
        return
      endif
      let s:kwbdBufNum = bufnr("%")
      let s:kwbdWinNum = winnr()
      windo call s:Kwbd(2)
      execute s:kwbdWinNum . 'wincmd w'
      let s:buflistedLeft = 0
      let s:bufFinalJump = 0
      let l:nBufs = bufnr("$")
      let l:i = 1
      while(l:i <= l:nBufs)
        if(l:i != s:kwbdBufNum)
          if(buflisted(l:i))
            let s:buflistedLeft = s:buflistedLeft + 1
          else
            if(bufexists(l:i) && !strlen(bufname(l:i)) && !s:bufFinalJump)
              let s:bufFinalJump = l:i
            endif
          endif
        endif
        let l:i = l:i + 1
      endwhile
      if(!s:buflistedLeft)
        if(s:bufFinalJump)
          windo if(buflisted(winbufnr(0))) | execute "b! " . s:bufFinalJump | endif
        else
          enew
          let l:newBuf = bufnr("%")
          windo if(buflisted(winbufnr(0))) | execute "b! " . l:newBuf | endif
        endif
        execute s:kwbdWinNum . 'wincmd w'
      endif
      if(buflisted(s:kwbdBufNum) || s:kwbdBufNum == bufnr("%"))
        execute "bd! " . s:kwbdBufNum
      endif
      if(!s:buflistedLeft)
        set buflisted
        set bufhidden=delete
        set buftype=
        setlocal noswapfile
      endif
    else
      if(bufnr("%") == s:kwbdBufNum)
        let prevbufvar = bufnr("#")
        if(prevbufvar > 0 && buflisted(prevbufvar) && prevbufvar != s:kwbdBufNum)
          b #
        else
          bn
        endif
      endif
    endif
  endfunction

  command! Kwbd call s:Kwbd(1)
  nnoremap <silent> <Plug>Kwbd :<C-u>Kwbd<CR>
  nnoremap <silent> <c-w> :Kwbd<CR>

  " set statusline         "显示状态栏命令                                                                                                                                                         
  set laststatus=2                                                                
  function! ModeName()
    let mode = mode()
    if mode == 'n'
      return '[Normal]'
    elseif mode == 'i'
      return '[Insert]'
    elseif mode == 'v'
      return '[Visual]'
    " Add more cases as needed...
    else
      return mode
    endif
  endfunction
     
  " hi User1 cterm=none ctermfg=gray ctermbg=darkgreen
  hi User1 cterm=none ctermfg=gray ctermbg=darkgray
  hi User2 cterm=none ctermfg=darkgrey ctermbg=gray
  hi User3 cterm=bold ctermfg=darkgrey ctermbg=gray
  hi User4 cterm=bold ctermfg=green ctermbg=gray
  hi User5 cterm=none ctermfg=darkgrey ctermbg=gray
  hi User6 cterm=none ctermfg=darkgrey ctermbg=gray

  if empty(glob($HOME.'/.vim/plugged/vim-airline/plugin/airline.vim'))
	  set statusline=%1*%{ModeName()}\ %m%r%h%w%=\ %2*\ %{getcwd()}\ %3*\ %{&fileencoding}\ %4*\ %{&fileformat}\ %=\ %5*%{\"\".(\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\"+\":\"\").\"\"}\ %6*[%l,%v]\ %7*%p%%\ \|\ %8*%LL\
	  " set statusline=%1*%{ModeName()}\ %m%r%h%w%=\ %2*\ %{getcwd()}\ %=\ %3*%{\"\".(\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\"+\":\"\").\"\"}\ %4*[%l,%v]\ %5*%p%%\ \|\ %6*%LL\
	  set tabline=%!MyTabLine()  " custom tab pages line
	  set showtabline=2
  endif 
  function! SpawnBufferLine()
    let s = ' hello r/vim | '

    " Get the list of buffers. Use bufexists() to include hidden buffers
    let bufferNums = filter(range(1, bufnr('$')), 'buflisted(v:val)')
    " Making a buffer list on the left side
    for i in bufferNums
      " Highlight with yellow if it's the current buffer
      let s .= (i == bufnr('%')) ? ('%#TabLineSel#') : ('%#TabLine#')
      let s .= i . ' '  " Append the buffer number
      if bufname(i) == ''
        let s .= '[NEW]'  " Give a name to a new buffer
      endif
      if getbufvar(i, "&modifiable")
        let s .= fnamemodify(bufname(i), ':t')  " Append the file name
        " let s .= pathshorten(bufname(i))  " Use this if you want a trimmed path
        " If the buffer is modified, add + and separator. Else, add separator
        let s .= (getbufvar(i, "&modified")) ? (' [+] | ') : (' | ')
      else
        let s .= fnamemodify(bufname(i), ':t') . ' [RO] | '  " Add read only flag
      endif
    endfor
    let s .= '%#TabLineFill#%T'  " Reset highlight

    let s .= '%=' " Spacer

    " Making a tab list on the right side
    for i in range(1, tabpagenr('$'))  " Loop through the number of tabs
      " Highlight with yellow if it's the current tab
      let s .= (i == tabpagenr()) ? ('%#TabLineSel#') : ('%#TabLine#')
      let s .= '%' . i . 'T '  " set the tab page number (for mouse clicks)
      let s .= i . ''          " set page number string
    endfor
    let s .= '%#TabLineFill#%T'  " Reset highlight

    " Close button on the right if there are multiple tabs
    if tabpagenr('$') > 1
      let s .= '%999X X'
    endif
    return s 
  endfunction

  set tabline=%!SpawnBufferLine()  " Assign the tabline
endif

if !empty(glob($HOME.'/.vim/autoload/plug.vim'))
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
	Plug 'frazrepo/vim-rainbow'
call plug#end()

noremap gr :EasyCompleteReference<CR>
noremap gd :EasyCompleteGotoDefinition<CR>
" noremap rn :EasyCompleteRename<CR>

set sessionoptions+=tabpages,globals
" let g:taboo_close_tab_label="%x"
" let g:taboo_tab_format='%n'
" let g:airline#extensions#tabline#enabled = 1
set laststatus=2   " Always show the statusline
let g:airline#extensions#tabline#show_tab_type = 1
let g:airline#extensions#tabline#show_tabs = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#enabled = 1
let g:airline_section_c = '%{getcwd()}'

" Taboo
" Disable Taboo's re-write of the tabline, because airline is doing that.
" We just want it for renaming tabs (only visible when there are multiple tabs)
" let g:taboo_tabline = 1
let g:airline#extensions#taboo#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 1 " tab number
let g:taboo_renamed_tab_format = "[%l]"
nnoremap <leader>tn :TabooRename 

let g:interestingWordsGUIColors = ['#aeee00', '#fa3e2d', '#2d93fa', '#b970e0', '#ffa724', '#fc7cc5']
let g:interestingWordsDefaultMappings = 0
nnoremap <silent> <leader>m :call InterestingWords('n')<cr>
vnoremap <silent> <leader>m :call InterestingWords('v')<cr>
nnoremap <silent> <leader>M :call UncolorAllWords()<cr>
nnoremap <silent> n :call WordNavigation(1)<cr>
nnoremap <silent> N :call WordNavigation(0)<cr>

nnoremap <silent> <c-f> :BLines<cr>

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

nnoremap <silent> <leader>sg :Rg<cr>
nnoremap <silent> <leader>sf :Files<cr>
nnoremap <silent> <leader>ss :Buffers<cr>
nnoremap <silent> <leader>so :History<cr>
nnoremap <silent> <leader>sc :Colors<cr>

" Jump to tab: <Leader>su
nnoremap <silent> <leader>su :Windows<cr>

" Requires Vim built with clipboard support, typically
" needs to be self-compiled with clipboard option enabled.
" You can check for clipboard support in Vim by running
" 'vim --version' and looking for options like 'xterm_clipboard'.
if has('clipboard') && version >= 801
	autocmd TextYankPost *
		\ if v:event.operator is 'y' || v:event.operator is 'd' |
		\ execute 'OSCYankRegister +' |
		\ endif

endif

endif
