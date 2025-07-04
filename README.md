---
title: my dotfiles
author: Andy6
date: Saturday, September 23, 2023
---

# My dotfiles

<!--toc:start-->
- [My dotfiles](#my-dotfiles)
  - [Rc Files, `.profile` or other dotfiles](#rc-files-profile-or-other-dotfiles)
  - [Tools](#tools)
<!--toc:end-->

## Rc Files, `.profile` or other dotfiles

`.bashrc`, `.zshrc` for reference shell environment setting files
`./.ssh/config` is a reference ssh config file

> [!IMPORTANT]
> 
> Reference `.profile` config and **special attention** below config to `.profile`
> ```bash
> if [[ $- != *i* ]]; then
>   return
> fi
> # ...
> exec zsh # # only exec zsh or zsh related code in interactive shell to avoid breaking other tools
> ```
> The above code prevents zsh or zsh-related code from affecting other IDEs (ex: VSCode, JetBrains IDEs) when using remote ssh connections

## Tools

`fzf_rg` for fuzzy search content of files to find files

`reverse-ssh-tunnel-manager` for `remote neovim` to start `im-select.exe`
- Platform: `wsl`
- Require: openssh, `ncat`, `im-select.exe (in windows local machine)`
- When use `neovim` on `new ssh server (and server not have reverse-ssh-tunnel)`
  + About neovim remote config : [doc/neovim-remote-setting-im-select.md](./doc/neovim-remote-setting-im-select.md)
- For example (This tool only catch `ssh -Y server`) :
  + ```bash (terminal)
    reverse-ssh-tunnel-manager
    # NOTE: or use silent mode (suggest)
    reverse-ssh-tunnel-manager --silent
    
    # NOTE: if use close mode, can close all reverse ssh-tunnel and ncat
    reverse-ssh-tunnel-manager --close
    ```
  + The above command can reopen this tool for `every server` to use this tool
- Require `im-select.exe` on `local machine`
  + Can download from [here](https://github.com/daipeihust/im-select/raw/master/win/out/x86/im-select.exe)
  + And download on 
    * [C:\Windows](C:\Windows)
    * [C:\Users\Andy6](C:\Users\Andy6)

`ssh-tunnel-manager` for ssh -L to remote server  
for `remote neovim` (to use `jupyter notebook`)
```bash (terminal)
# NOTE: use alias and --max-port
# can use `sshname` to use `settings port` for ssh  -L
ssh-tunnel-manager sshname --max-port 3
```
