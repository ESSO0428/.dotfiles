" =========================================
" Core: internal representation
" =========================================
set encoding=utf-8

" =========================================
" Read detection order (Neovim-style, Taiwan-friendly)
" - ucs-bom: handle BOM safely
" - utf-8 first: avoid UTF-8 being misread as latin1
" - cp950/big5 for Taiwan legacy files
" - latin1 last resort
" =========================================
set fileencodings=ucs-bom,utf-8,cp950,big5,gbk,gb2312,latin1

" (Optional) show fileencoding in statusline quickly
" set statusline+=\ [%{&fileencoding==''?'none':&fileencoding}]

" =========================================
" Keep original fileencoding when writing
" =========================================
augroup KeepOriginalFencOnWrite
  autocmd!
  " After reading a file, record detected encoding/bom in buffer-local vars.
  autocmd BufReadPost *
        \ let b:_orig_fenc = (&l:fileencoding ==# '' ? 'latin1' : &l:fileencoding) |
        \ let b:_orig_bomb = &l:bomb

  " Before writing, force writing with original encoding/bom.
  autocmd BufWritePre *
        \ if exists('b:_orig_fenc') |
        \   execute 'setlocal fileencoding=' . b:_orig_fenc |
        \ endif |
        \ if exists('b:_orig_bomb') |
        \   if b:_orig_bomb | setlocal bomb | else | setlocal nobomb | endif |
        \ endif
augroup END

" =========================================
" Optional helper commands (explicit, no magic)
" =========================================
" Reopen current file as UTF-8 (fix mojibake explicitly when needed)
command! ReopenUtf8  edit ++enc=utf-8
command! ReopenBig5  edit ++enc=big5
command! ReopenCp950 edit ++enc=cp950

" After you confirm display is correct, you may choose to set buffer write encoding:
"   :setlocal fileencoding=utf-8
" (Only do this if you really want to convert file on disk when saving.)
