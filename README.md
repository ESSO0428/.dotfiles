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
  - [Windows](#windows)
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
git clone git@github.com:ESSO0428/.dotfiles.git ~/.dotfiles   # or: git -C ~/.dotfiles pull
cd ~/.dotfiles
./install.sh                    # interactive: pick packages, decide each conflict
```

Interactive mode (run in a terminal without package arguments) walks you through it, so you do
not have to remember which files belong to which package:

1. **Pick packages** (fzf, `Tab` to multi-select, `Ctrl-A` for all; a numbered menu without fzf).
   Each row shows how many files are `已連結` (linked), `新增` (new), `相同` (same content) and
   `不同` (differ); the preview lists every file with a diff for the ones that differ.
2. **For each package with differing files**, choose: `r` keep the repo version (this machine's
   file is backed up), `a` keep this machine's version (adopted into the repo), `d` view the diff,
   `s` skip.
3. **Confirm** the summary, then it links, creates missing rc / `.local` files from templates and
   finally shows `sync-skills --diff` and asks before installing missing skills.

Non-interactive forms, for scripts:

```bash
./install.sh --status [pkg..]   # only list each file's state, change nothing
DRY_RUN=1 ./install.sh --all    # preview
./install.sh --all              # link every package, repo version wins
./install.sh shell vim tmux     # only some packages
./install.sh --adopt pi         # this machine's version wins for pi
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
| `herdr`    | `.config/herdr/config.toml` (sessions and release notes are not tracked)       |
| `claude`   | `.claude/{CLAUDE.md,RTK.md,settings.json,keybindings.json,agents/,commands/}`, `.config/ccstatusline/settings.json` |
| `opencode` | `.config/opencode/{opencode.jsonc,tui.json,dcp.jsonc,package.json,opencode-quota/}` |
| `pi`       | `.pi/agent/{settings.json,keybindings.json,sidebar-ui.json,pi-cc-extensions.json,pi-command-palette.json,agent-switcher.json,pi-goal.json,agents/,extensions/*.json}` |
| `agents`   | `.agents/{skills,skills-env}.list`, `.agents/scripts/{sync-skills,link-claude-skills.sh}` |

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

**Skills are not synced as files.** `~/.agents/skills.list` lists what should be installed;
`sync-skills` (in `~/.agents/scripts/`, which `env.sh` puts on `PATH`) manages it. Run it without
arguments in a terminal for an fzf menu (the preview shows each skill's `SKILL.md`):

| action    | what it does                                                                 |
|-----------|------------------------------------------------------------------------------|
| `add`     | pick skills installed on this machine and append them to the list            |
| `install` | pick skills from the list that this machine is missing and install them      |
| `remove`  | pick skills to drop from the list (they stay installed on this machine)      |

Nothing is ever uninstalled. After installing, `link-claude-skills.sh` links the skills into
`~/.claude/skills`. Edit the list, then commit it from `~/.dotfiles` as usual.

`npx skills add` silently skips a skill the source no longer has (deleted or renamed upstream);
`sync-skills` warns about any skill still missing after the install, so fix the list entry.

**Skills with Python tools** (e.g. `ppt-master`, `hung-yi-lee-ai-mentor-skills`) are listed in
`~/.agents/skills-env.list` as `<skill>  [uv sync args...]`. Every install run then builds a
`.venv` inside each listed skill with `uv` (incremental when it already exists, so rerun
`sync-skills --install` after `npx skills update`). A skill with only `requirements.txt` first gets
a `pyproject.toml` via `uv init` + `uv add -r`, and must give `--python` (its minimum version).
Run the tools with `uv run --project <skill dir> python <script>`. An installed skill that ships
`pyproject.toml` / `requirements.txt` but is missing from the env list triggers a warning.

```bash
sync-skills            # interactive (falls back to --install without fzf or a terminal)
sync-skills --diff     # what is missing / extra on this machine
sync-skills --install  # install the missing ones (DRY_RUN=1 to preview)
sync-skills --export   # overwrite the whole list with what is installed here
```

Build the list from the main machine (`add`, or `--export`), not from a secondary one.

On Windows the same list is managed by `sync-skills.ps1` (same `add` / `install` / `remove` fzf
menu, `-Diff`, `-Install`, `-Export`, `-WhatIf`), and `link-claude-skills.ps1` links skills into
`~\.claude\skills` with junctions. `install.ps1 agents` adds `~\.agents\scripts` to the user
`PATH`, so `sync-skills` works there too.

## Windows

`install.ps1` is the Windows counterpart of `install.sh`. It needs **PowerShell 7** (`pwsh`).
Creating symlinks needs Windows **Developer Mode** (Settings → System → For developers) or admin
rights; without either (or when copying `im-select.exe` into `C:\Windows`) it offers to continue in
an elevated window via UAC, still as your account and with the target paths decided beforehand.
Run it from a Windows clone, not through `\\wsl.localhost`:

```powershell
git clone git@github.com:ESSO0428/.dotfiles.git $HOME\.dotfiles
cd $HOME\.dotfiles
.\install.ps1 -WhatIf      # preview
.\install.ps1              # interactive, same flow as install.sh (-Interactive to force it)
.\install.ps1 -Status      # each target's state
```

| package     | target                                                    | how       |
|-------------|-----------------------------------------------------------|-----------|
| `claude`    | `~\.claude`, `~\.config\ccstatusline` (same files as Linux) | symlink   |
| `opencode`  | `~\.config\opencode`                                      | symlink   |
| `pi`        | `~\.pi\agent`                                             | symlink   |
| `agents`    | `~\.agents\skills.list`, `scripts\*.ps1` (bash scripts skipped); adds `~\.agents\scripts` to `PATH`, runs `sync-skills.ps1` | symlink |
| `vimrc`     | `~\.ideavimrc`, `~\keymap.vim`                            | symlink   |
| `nvim`      | `%LOCALAPPDATA%\nvim` (Windows-only config)               | junction  |
| `documents` | `Documents\config.xlaunch`; PowerShell profile only if missing | symlink / copy once |
| `obsidian`  | `OneDrive\應用程式\remotely-save\Obsidian Vault\.obsidian.vimrc` | copy |
| `im-select` | `~\im-select.exe`, `C:\Windows\im-select.exe` (admin)    | copy      |

`windows/overrides/<package>/<path>` replaces a shared file on Windows only (currently unused).
Claude's `settings.json` is shared, including its `rtk hook`: without `rtk` on Windows, Bash
still runs but every call shows a hook error, so install `rtk` there too. Everything else under
`windows/` (from the former [`.win-dotfiles`](https://github.com/ESSO0428/.win-dotfiles) repo,
merged with its history) is Windows-only and never touched by `install.sh`. See
[`windows/README.md`](windows/README.md).

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
