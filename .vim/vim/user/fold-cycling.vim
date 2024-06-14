let g:fold_cycle_default_mapping = 0 "disable default mappings
nmap <silent> ]f <Plug>(fold-cycle-open)
nmap <silent> [f <Plug>(fold-cycle-close)
nnoremap <silent> [g zM
nnoremap <silent> ]g zR

" Won't close when max fold is opened
let g:fold_cycle_toggle_max_open  = 1
" Won't open when max fold is closed
let g:fold_cycle_toggle_max_close = 1
