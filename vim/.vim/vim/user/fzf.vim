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
