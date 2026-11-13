---
title: my dotfiles
author: Andy6
date: Saturday, September 23, 2023
---

# My dotfiles

<!--toc:start-->
- [My dotfiles](#my-dotfiles)
  - [Install](#install)
  - [Packages](#packages)
  - [Shell: rc files, shared files and `*.local`](#shell-rc-files-shared-files-and-local)
  - [Agent configs](#agent-configs)
  - [Rc Files, `.profile` or other dotfiles](#rc-files-profile-or-other-dotfiles)
  - [Tools](#tools)
<!--toc:end-->

## Install

Managed with [GNU Stow](https://www.gnu.org/software/stow/): every top-level directory is a
package whose contents are symlinked into `$HOME` (`stow --no-folding`, so only tracked files are
linked; credentials, history and caches next to them stay untouched).

> [!IMPORTANT]
>
> **GNU Stow is required.** `install.sh` installs it into `~/.local` automatically when missing
> (needs only `perl`, `make` and `curl`; **no root / sudo**). To install it yourself:
> ```bash
> # from source, no root
> curl -fsSL https://ftp.gnu.org/gnu/stow/stow-2.4.1.tar.gz | tar -xz
> cd stow-2.4.1 && ./configure --prefix="$HOME/.local" && make install
> # or: conda install -c conda-forge stow / sudo apt install stow / brew install stow
> ```

```bash
git clone git@github.com:ESSO0428/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
DRY_RUN=1 ./install.sh          # preview
./install.sh                    # link every package
./install.sh shell vim tmux     # or only some packages
```

- An existing real file at a target path is **moved to `~/.dotfiles-backup/<time>/`** before
  linking, so the repo version wins.
- On the main machine, `./install.sh --adopt` does the opposite: it pulls the live files into the
  repo; review with `git diff` and commit (or `git checkout` what you don't want).
- Because files are symlinks, editing `~/.config/shell/*.sh`, `~/.claude/settings.json`, etc. edits the repo
  directly: just `git diff` / `git commit`. No save script needed.
- Some tools save by writing a temp file and renaming it, which replaces the symlink with a regular
  file. After changing settings from inside a tool, check with `ls -l <file>`; if it is no longer a
  symlink, run `./install.sh --adopt <package>`.

## Packages

| package    | links to                                                                       |
|------------|--------------------------------------------------------------------------------|
| `shell`    | `.profile`, `.config/shell/*` (`.bashrc` / `.zshrc` are copied from templates, not linked; `.p10k.zsh` is not tracked) |
| `vim`      | `.vimrc`, `.vim/vim/`                                                          |
| `tmux`     | `.tmux/.tmux.conf`, `.tmux.conf.local` ([oh-my-tmux](https://github.com/gpakosz/.tmux) is cloned first if `~/.tmux` is missing) |
| `bin`      | `~/bin/*` tools (see [Tools](#tools))                                          |
| `ranger`   | `.config/ranger/`                                                              |
| `claude`   | `.claude/{CLAUDE.md,RTK.md,settings.json,keybindings.json,agents/}`, `.config/ccstatusline/settings.json` |
| `opencode` | `.config/opencode/{opencode.jsonc,tui.json,dcp.jsonc,package.json,opencode-quota/}` |
| `pi`       | `.pi/agent/{settings.json,keybindings.json,sidebar-ui.json,pi-cc-extensions.json,pi-command-palette.json,agent-switcher.json,pi-goal.json,agents/,extensions/*.json}` |
| `agents`   | `.agents/skills.list`, `.agents/scripts/{sync-skills,link-claude-skills.sh}`   |

`examples/ssh_config` is a reference ssh config only; it is **not** linked (it would overwrite
`~/.ssh/config`).

## Shell: rc files, shared files and `*.local`

**`~/.bashrc` and `~/.zshrc` are per machine and are not synced.** Installers such as
`conda init`, nvm and fzf edit them, and those edits should stay on that machine.
`install.sh` copies `~/.config/shell/{bash,zsh}rc.template` only when the rc file does not exist
yet, and warns if an existing rc file does not load `~/.config/shell/`.

The rc files keep the conda block between `# >>> conda initialize >>>` and
`# <<< conda initialize <<<`. `conda init` looks for these markers, so it updates the block in
place instead of adding a second one. The templates ship the block commented out as a reference;
run `~/anaconda3/bin/conda init zsh` (or `bash`) after installing conda to fill it in.

Load order (`omz.zsh` is zsh only):

```
~/.config/shell/env.sh        synced     PATH, EDITOR, DISPLAY (WSL only)
~/.config/shell/omz.zsh       synced     oh-my-zsh theme and plugins (only the installed ones)
~/.config/shell/tools.sh      synced     fzf / nvm / cargo / autojump (skipped when not installed)
~/.config/shell/functions.sh  synced     safe_sshfs, j2ssh, passwordless_ssh, code_cli, ...
~/.config/shell/aliases.sh    synced     shared aliases
~/.p10k.zsh                   not synced p10k prompt, differs per server so each one is easy to recognise
conda initialize block        per rc     managed by conda init
~/.tool.local                 not synced this machine only: WSL programs, R, nvm version, p10k options
~/.alias.local                not synced this machine only: lab ssh aliases with real IPs
```

`.local` always means "this machine only, never committed". `install.sh` creates `~/.tool.local`
and `~/.alias.local` from `~/.config/shell/{tool,alias}.local.example` on first run (all lines
commented out). The examples also keep the reference ssh aliases and `.profile` notes.

`~/.p10k.zsh` is per machine on purpose: on a new machine p10k starts its `p10k configure` wizard
the first time zsh runs.

After installing a tool, check `git -C ~/.dotfiles status` as well: if it changed a synced file,
review the diff before committing.

## Agent configs

Only hand-written settings are tracked. Credentials and runtime state are **not**:
`~/.claude/.credentials.json`, `~/.claude.json`, history, sessions, `projects/`,
`~/.pi/agent/{auth.json,models-store.json,*-cache.json,sessions,state,npm,install}`,
`~/.config/opencode/node_modules`.

- Claude plugins are restored from `enabledPlugins` / `extraKnownMarketplaces` in `settings.json`.
- pi extensions are restored from `packages` in `~/.pi/agent/settings.json`.
- opencode plugins are listed in `opencode.jsonc` / `package.json`.

**Skills are not synced as files.** `~/.agents/skills.list` lists what should be installed and
`sync-skills` installs the missing ones with `npx skills add -g` (it never removes anything), then
runs `link-claude-skills.sh` to link them into `~/.claude/skills`:

```bash
sync-skills --diff     # what is missing / extra on this machine
sync-skills            # install the missing ones (DRY_RUN=1 to preview)
sync-skills --export   # main machine only: rewrite skills.list from what is installed
```

Generate the list on the main machine, not on a secondary one.

## Rc Files, `.profile` or other dotfiles

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
