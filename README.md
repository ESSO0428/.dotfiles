---
title: my dotfiles
author: Andy6
date: 230923
---

# My dotfiles

## tools

### base

`.bashrc`, `.zshrc` for reference shell env setting files
`./.ssh/config` is reference ssh config file

###  important

`fzf_rg` for fuzzy search content of files to find files

`reverse-ssh-tunnel-manager` for `remote neovim` to start `im-select.exe`
- plataform : `wsl`
- require   : openssh, `ncat`, `im-select.exe (in windows local machine)`
- when use `neovim` on `new ssh server (and server not have reverse-ssh-tunnel)`
    + about neovim remote config : [doc/neovim-remote-setting-im-select.md](./doc/neovim-remote-setting-im-select.md)
- for example (This tool only catch `ssh -Y server`) :
```bash (terminal)
reverse-ssh-tunnel-manager
# NOTE: or use silent mode (suggest)
reverse-ssh-tunnel-manager --silent

# NOTE: if use close mode, can close all reverse ssh-tunnel and ncat
reverse-ssh-tunnel-manager --close
```
can re open this tools for `every server` to use this tool
- reuqire `im-select.exe` on `local machine`
    + can download from [here](https://github.com/daipeihust/im-select/raw/master/win/out/x86/im-select.exe)
    + and download on 
        * [C:\Windows](C:\Windows)
        * [C:\Users\Andy6](C:\Users\Andy6)

`ssh-tunnel-manager` for ssh -L to remote server  
for `remote neovim` (to use `jupyter notebook`)
```bash (terminal)
# NOTE: use alias and --max-port
# can use `sshname` to use `settings port` for ssh  -L
ssh-tunnel-manager sshname --max-port 3
```

