# export LIBGL_ALWAYS_INDIRECT=1
export DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0.0
export DISPLAY=:0
# LIBGL_ALWAYS_INDIRECT=0

# [ -f ~/.fzf.bash ] && source ~/.fzf.bash

# bat (酷炫版的 cat 具有語法高量的功能)
# wget https://github.com/sharkdp/bat/releases/download/v0.21.0/bat-v0.21.0-x86_64-unknown-linux-musl.tar.gz
# tar -zxvf bat-v0.21.0-x86_64-unknown-linux-musl.tar.gz
# cd ~/bat-v0.21.0-x86_64-unknown-linux-musl
# cp ./bat ~/bin
# cp ./bat.1 ~/share/man/man1/
# 安裝 bat 的主題 (也可不裝，它有很多預設的主題)
# mkdir -p "$(bat --config-dir)/themes"
# cd "$(bat --config-dir)/themes"
# git clone https://github.com/greggb/sublime-snazzy

export FZF_DEFAULT_COMMAND="fd --type file"
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --preview '(highlight -O ansi {} || cat {}) 2> /dev/null | head -500' --bind 'alt-d:toggle-preview'"
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --preview '(highlight -O ansi {} || bat --color=\"always\" {}) 2> /dev/null | head -500' --bind 'alt-d:toggle-preview'"
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --preview '(highlight -O ansi {} || bat --color=\"always\" --theme=\"Sublime Snazzy\" {}) 2> /dev/null | head -500' --bind 'alt-d:toggle-preview'"
# server
# export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --preview '([[ -f {} ]] && (bat --color=\"always\" --theme=\"Visual Studio Dark+\" {} || cat {})) || ([[ -d {} ]] && (tree -C {} | head -200)) || echo {} 2> /dev/null | head -200' --bind 'alt-d:toggle-preview,f1:execute(vim -c \"execute \\\"edit\\\" expand({})\" >/dev/tty),f2:execute(code {})'"

# wsl
# export FZF_DEFAULT_OPTS="--no-mouse --bind 'alt-j:preview-down,alt-k:preview-up' --height 40% --layout=reverse --preview '([[ -f {} ]] && (bat --color=\"always\" --theme=\"Visual Studio Dark+\" {} || cat {})) || ([[ -d {} ]] && (tree -C {} | head -200)) || echo {} 2> /dev/null | head -200' --bind 'alt-d:toggle-preview,f1:execute(notepad++.exe {}),f2:execute(code {})'"
export FZF_DEFAULT_OPTS="--no-mouse --bind 'alt-k:preview-down,alt-i:preview-up'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'ctrl-k:down,ctrl-i:up'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'tab:toggle-out,shift-tab:toggle-in'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'alt-d:toggle-preview'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'ctrl-j:change-preview-window(99%,right),ctrl-l:change-preview-window(50%,right)'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'alt-j:change-preview-window(99%,right),alt-l:change-preview-window(50%,right)'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --height 40% --layout=reverse --preview '([[ -f {} ]] && (bat --color=\"always\" --theme=\"Visual Studio Dark+\" {} || cat {})) || ([[ -d {} ]] && ( tree -C {} | head -200)) || echo {} 2> /dev/null | head -200'"
# FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'f1:execute(vim -c \"execute \\\"edit\\\" expand({})\" >/dev/tty),f2:execute(code {})'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'f1:execute(~/nvim.appimage {}),f2:execute(code {})'"



# kitty image preview (requeir openGL3.3 above in Lab PC [we don't have])
# export FZF_DEFAULT_OPTS="--no-mouse --height 40% --layout=reverse --preview '([[ -f {} ]] && (kitty icat --clear --place 200x40@0x0 --transfer-mode file {} || bat --color=\"always\" --theme=\"Visual Studio Dark+\" {} || cat {})) || ([[ -d {} ]] && (tree -C {} | head -200)) || echo {} 2> /dev/null | head -200' --bind 'alt-d:toggle-preview,f1:execute(notepad++.exe {}),f2:execute(code {})'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    export|unset) fzf "$@" --preview "eval 'echo \$'{}" ;;
    ssh)          fzf "$@" --preview 'dig {}' ;;
    *)            fzf "$@" ;;
  esac
}

# export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200' --bind 'alt-j:preview-down,alt-k:preview-up'"
# export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window hidden:wrap"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200' --bind 'alt-k:preview-down,alt-i:preview-up'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window hidden:wrap"

export PATH=$PATH:/mnt/c/Program\ Files/Notepad++
alias npp="notepad++.exe"
# alias j2dp="cd /mnt/y"
alias open="/mnt/c/AP/Anaconda3/Scripts/open.exe"

. "$HOME/.cargo/env"


# mkdir -p /mnt/y
# sudo mount -t drvfs Y: /mnt/y

# ranger
alias ra="ranger"
export RANGER_LOAD_DEFAULT_RC FALSE

# user bin
PATH=$HOME/bin/:$PATH

alias nvim="~/nvim.appimage"
PATH=/root/.local/bin:$PATH
# golang (go)
# wget https://go.dev/dl/go1.19.10.linux-amd64.tar.gz
PATH=$HOME/bin/go/bin/:$PATH


# ssh and docker container jump terminal tool
j2remote() {
  local current_dir=$(pwd)
  local sshfs_mounts=$(ps -ax | grep 'sshfs' | grep -v 'grep')
  local ssh_cmd=""

  while read -r line; do
    if [[ "$line" == "" ]]; then
      continue
    fi
    # 提取端口号（如果存在）
    local port_command=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if($i=="-p") print $(i+1)}' | sed 's/-p //')
    # 如果存在端口号，添加 -p 参数到 SSH 命令中
    [ -n "$port_command" ] && port_command="-p $port_command"

    local command_line=$(echo "$line" | sed 's/-p [0-9]*//')
    local ssh_address_info=$(echo "$command_line" | awk '{print $6}')
    local ssh_address=${ssh_address_info%%:*}
    local work_dir=${ssh_address_info#*:}
    local local_mount_point=$(echo "$command_line" | awk '{print $7}')

    if [[ "$current_dir" == "$local_mount_point"* ]]; then
      local sub_dir=${current_dir#$local_mount_point}
      ssh_cmd="ssh -t -Y ${port_command} ${ssh_address} \"cd ${work_dir}${sub_dir} ; bash --login\""
      break
    fi
  done <<< "$sshfs_mounts"

  if [ -n "$ssh_cmd" ]; then
    echo "run command: $ssh_cmd"
    eval $ssh_cmd
  else
    echo "Current directory is not part of any SSHFS mount."
  fi
}
j2c() {
  local current_dir=$(pwd)
  local container_info=$(docker ps --format "{{.Names}} {{.ID}}" | xargs -I {} sh -c 'echo {} $(docker inspect {} | grep -A1 Binds | tail -1 | grep -oP "(?<=\")[^\"]+(?=\")")')
  local docker_cmd=""

  while IFS= read -r line; do
    if [[ "$line" == "" ]]; then
      continue
    fi

    local container_name=${line%% *}
    local rest=${line#* }
    local container_id=${rest%% *}
    local binds_info=${rest#* }
    local volume_path=${binds_info%%:*}
    local work_dir=${binds_info#*:}

    if [[ "$current_dir" == "$volume_path"* ]]; then
      local sub_dir=${current_dir#$volume_path}
      local target_container=${container_name:-$container_id}
      docker_cmd="docker exec -w $work_dir$sub_dir -it $target_container /bin/bash"
      break
    fi
  done <<< "$container_info"

  if [ -n "$docker_cmd" ]; then
    echo "run command: $docker_cmd"
    eval $docker_cmd
  else
    echo "Current directory is not a Docker volume."
  fi
}
j2ssh(){
  j2remote
  j2c
}
