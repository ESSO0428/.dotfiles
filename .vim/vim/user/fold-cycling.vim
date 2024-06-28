let g:fold_cycle_default_mapping = 0 "disable default mappings
nmap <silent> ]f <Plug>(fold-cycle-open)
nmap <silent> [f <Plug>(fold-cycle-close)
nmap <silent> [g <Plug>(fold-cycle-close-all)
nmap <silent> ]g <Plug>(fold-cycle-open-all)
" nnoremap <silent> [g zM
" nnoremap <silent> ]g zR

" Won't close when max fold is opened
let g:fold_cycle_toggle_max_open  = 1
" Won't open when max fold is closed
let g:fold_cycle_toggle_max_close = 1

function! Vscode_like_foldLevel_enhance(n)
  " 关闭所有折叠
  normal [g
  let l:folds_to_open = a:n - 1
  if l:folds_to_open >= 1
    for i in range(1, l:folds_to_open)
 	  " 使用 <Plug>(fold-cycle-open) 打开折叠
 	  normal ]f
    endfor
  endif
endfunction

nmap <silent> ]1 :call Vscode_like_foldLevel_enhance(1)<cr>
nmap <silent> ]2 :call Vscode_like_foldLevel_enhance(2)<cr>
nmap <silent> ]3 :call Vscode_like_foldLevel_enhance(3)<cr>
nmap <silent> ]4 :call Vscode_like_foldLevel_enhance(4)<cr>
nmap <silent> ]5 :call Vscode_like_foldLevel_enhance(5)<cr>
nmap <silent> ]6 :call Vscode_like_foldLevel_enhance(6)<cr>
nmap <silent> ]7 :call Vscode_like_foldLevel_enhance(7)<cr>
nmap <silent> ]8 :call Vscode_like_foldLevel_enhance(8)<cr>
nmap <silent> ]9 :call Vscode_like_foldLevel_enhance(9)<cr>
