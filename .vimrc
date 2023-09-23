let mapleader=" "
noremap ; :set relativenumber!<cr>
map u <Nop>
noremap o o<ESC>
noremap u O<ESC>
noremap O <Nop>
noremap O ddk
noremap U dd

noremap <LEADER><LEADER> <Esc>/<++><CR>:nohlsearch<CR>"_c4l

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


noremap ; :
nnoremap Q :q<CR>
nnoremap S :w<CR>
" Open the vimrc file anytime
nnoremap <LEADER>rc :e $HOME/.config/nvim/init.vim<CR>
nnoremap <LEADER>rv :e .nvimrc<CR>
augroup NVIMRC
    autocmd!
    autocmd BufWritePost *.nvimrc exec ":so %"
augroup END
" Undo operations
" colemak keyboard
" noremap l u
" normal keyboard
noremap z u
" Insert Key
noremap m a
noremap M A
noremap a i
noremap A I
" Copy to system clipboard
vnoremap Y "+y
" Find pair
noremap ,. %
vnoremap ni $%
" Search
noremap <LEADER><CR> :nohlsearch<CR>
" Adjacent duplicate words
noremap <LEADER>dw /\(\<\w\+\>\)\_s*\1
" Space to Tab
nnoremap <LEADER>tt :%s/    /\t/g
vnoremap <LEADER>tt :s/    /\t/g
noremap gj J
vnoremap gj J
noremap <a-a> <c-x>
noremap <a-d> <c-a>

" Folding
noremap <silent> <LEADER>o za
noremap <silent> <LEADER>Oa zM
noremap <silent> <LEADER>Od zR

" insert a pair of {} and go to the next line
inoremap <c-y> <ESC>A {}<ESC>i<CR><ESC>ko

" ==================== Cursor Movement ====================
" New cursor movement (the default arrow keys are used for resizing windows)
"     ^
"     u
" < n   i >
"     e
"     v
" colemak keyborad
" noremap <silent> u k
" noremap <silent> n h
" noremap <silent> e j
" noremap <silent> i l

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
" set h (same as n, cursor left) to 'end of word'
noremap h e
" Ctrl + U or E will move up/down the view port without moving the cursor
" colemak keyborad
" noremap <C-U> 5<C-y>
" noremap <C-E> 5<C-e>
" normal Keyborad
noremap <C-I> 5<C-y>
noremap <C-K> 5<C-e>

" colemak keyborad
" Custom cursor movement
" source $HOME/.config/nvim/cursor.vim
" normal Keyborad
" If you use Qwerty keyboard, uncomment the next line.
source $HOME/.config/nvim/cursor_for_qwerty.vim



" ==================== Insert Mode Cursor Movement ====================
inoremap <C-a> <ESC>A


" ==================== Command Mode Cursor Movement ====================
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <M-b> <S-Left>
cnoremap <M-w> <S-Right>


" ==================== Window management ====================
" Use <space> + new arrow keys for moving the cursor around windows
" colemak keyboard
" noremap <LEADER>w <C-w>w
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
noremap <LEADER>q :q<CR>


" ==================== Tab management ====================
" Create a new tab with tu
" colemak keyboard
" noremap tu :tabe<CR>
" noremap tU :tab split<CR>
" normal keyboard
noremap ti :tabe<CR>
noremap tI :tab split<CR>
" Move around tabs with tn and ti
" colemak keyboard
" noremap tn :-tabnext<CR>
" noremap ti :+tabnext<CR>
" normal keyboard
noremap tj :-tabnext<CR>
noremap tl :+tabnext<CR>
" Move the tabs with tmn and tmi
" colemak keyboard
" noremap tmn :-tabmove<CR>
" noremap tmi :+tabmove<CR>
" normal keyboard
noremap tmj :-tabmove<CR>
noremap tml :+tabmove<CR>

" ==================== Markdown Settings ====================
" Snippets
source $HOME/.config/nvim/md-snippets.vim
" auto spell
autocmd BufRead,BufNewFile *.md setlocal spell


" ==================== Other useful stuff ====================
" Open a new instance of st with the cwd
nnoremap \t :tabe<CR>:-tabmove<CR>:term sh -c 'st'<CR><C-\><C-N>:q<CR>
" Opening a terminal window
noremap <LEADER>/ :set splitbelow<CR>:split<CR>:res +10<CR>:term<CR>
" Press space twice to jump to the next '<++>' and edit it
noremap <LEADER><LEADER> <Esc>/<++><CR>:nohlsearch<CR>"_c4l
" Spelling Check with <space>sc
noremap <LEADER>sc :set spell!<CR>
" Press ` to change case (instead of ~)
noremap ` ~
noremap <C-c> zz
" Auto change directory to current dir
autocmd BufEnter * silent! lcd %:p:h
" Call figlet
noremap tx :r !figlet 
" find and replace
noremap \s :%s//g<left><left>
" set wrap
noremap <LEADER>sw :set wrap<CR>
" press f10 to show hlgroup
" function! SynGroup()
" 	let l:s = synID(line('.'), col('.'), 1)
" 	echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
" endfun
map <F10> :TSHighlightCapturesUnderCursor<CR>

" Compile function
noremap r :call CompileRunGcc()<CR>
func! CompileRunGcc()
	exec "w"
	if &filetype == 'c'
		set splitbelow
		:sp
		:res -5
		term gcc % -o %< && time ./%<
	elseif &filetype == 'cpp'
		set splitbelow
		exec "!g++ -std=c++11 % -Wall -o %<"
		:sp
		:res -15
		:term ./%<
	elseif &filetype == 'cs'
		set splitbelow
		silent! exec "!mcs %"
		:sp
		:res -5
		:term mono %<.exe
	elseif &filetype == 'java'
		set splitbelow
		:sp
		:res -5
		term javac % && time java %<
	elseif &filetype == 'sh'
		:!time bash %
	elseif &filetype == 'python'
		set splitbelow
		:sp
		:term python3 %
	elseif &filetype == 'html'
		silent! exec "!".g:mkdp_browser." % &"
	elseif &filetype == 'markdown'
		exec "InstantMarkdownPreview"
	elseif &filetype == 'tex'
		silent! exec "VimtexStop"
		silent! exec "VimtexCompile"
	elseif &filetype == 'dart'
		exec "CocCommand flutter.run -d ".g:flutter_default_device." ".g:flutter_run_args
		silent! exec "CocCommand flutter.dev.openDevLog"
	elseif &filetype == 'javascript'
		set splitbelow
		:sp
		:term export DEBUG="INFO,ERROR,WARNING"; node --trace-warnings .
	elseif &filetype == 'racket'
		set splitbelow
		:sp
		:res -5
		term racket %
	elseif &filetype == 'go'
		set splitbelow
		:sp
		:term go run .
	endif
endfunc


call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

Plug 'sillybun/vim-repl'
let g:repl_program = {
            \   'python': 'ipython',
            \   'default': 'zsh',
            \   'r': 'R',
            \   'lua': 'lua',
            \   }
let g:repl_predefine_python = {
            \   'numpy': 'import numpy as np',
            \   'matplotlib': 'from matplotlib import pyplot as plt'
            \   }
let g:repl_cursor_down = 1
let g:repl_python_automerge = 1
let g:repl_ipython_version = '7'
nnoremap <leader>r :REPLToggle<Cr>
autocmd Filetype python nnoremap <F12> <Esc>:REPLDebugStopAtCurrentLine<Cr>
autocmd Filetype python nnoremap <F10> <Esc>:REPLPDBN<Cr>
autocmd Filetype python nnoremap <F11> <Esc>:REPLPDBS<Cr>
let g:repl_position = 3

call plug#end()
nnoremap <C-t> :Files<Cr>
