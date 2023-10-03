# doc/neovim-remote-setting-im-select.md
Date: Tuesday, October 03, 2023
Filename: neovim-remote-setting-im-select.md

# setting neovim/vim on remote server for im-select.exe

```vim
" NOTE: Add below scripts in your init.vm/.vimrc or other source file.vim
autocmd InsertEnter * call SendOSC("insert")
autocmd InsertLeave * call SendOSC("normal")

function! SendOSC(mode)
    " 檢查~/.rssh_tunnel文件是否存在
    if filereadable(expand("~/.rssh_tunnel"))
        " 讀取文件內容以獲取端口號
        let port = readfile(expand("~/.rssh_tunnel"))[0]

        " 根據模式構建命令
        if a:mode == "insert"
            let command = "echo im-select.exe com.apple.keylayout.ABC | nc -w 0.01 127.0.0.1 " . port
        else
            let command = "echo im-select.exe 1033 | nc -w 0.01 127.0.0.1 " . port
        endif
        let command = command . " &> /dev/null"
        " 執行命令
        call system(command)
    endif
endfunction
```

