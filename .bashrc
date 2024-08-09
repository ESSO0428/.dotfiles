# export LIBGL_ALWAYS_INDIRECT=1
export DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0.0
export DISPLAY=:0
# LIBGL_ALWAYS_INDIRECT=0

SHELL=$0
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
export FZF_DEFAULT_OPTS="--no-mouse --bind 'ctrl-o:preview-down,ctrl-u:preview-up'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'ctrl-s:down,ctrl-w:up'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'alt-k:down,alt-i:up'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'tab:toggle-out,shift-tab:toggle-in'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'alt-d:toggle-preview'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind 'alt-j:change-preview-window(99%,right),alt-l:change-preview-window(50%,right)'"
FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --height 40% --layout=reverse --preview '([[ -f {} ]] && (bat --color=\"always\" --theme=\"Visual Studio Dark+\" {} || cat {})) || ([[ -d {} ]] && (tree -C {} | head -200)) || echo {} 2> /dev/null | head -200'"
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

# code_cli : vscode remote tunnel (code tunnel)
code_cli() {
  # Check if code_cli exists in the $HOME directory
  if [ ! -e "$HOME/code_cli" ]; then
    # Switch to the $HOME directory
    cd $HOME
    # Remove existing vscode_cli.tar.gz file
    rm -rf vscode_cli.tar.gz
    # Download Visual Studio Code CLI
    curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output vscode_cli.tar.gz
    # Extract vscode_cli.tar.gz
    tar -xf vscode_cli.tar.gz
    # Rename extracted code to code_cli
    mv code code_cli
    # Delete the vscode_cli.tar.gz file
    rm -rf vscode_cli.tar.gz
    echo "Installation of code_cli completed."
  else
    # If code_cli already exists, execute it as $HOME/code_cli with all passed parameters
    "$HOME/code_cli" "$@"
  fi
}


# command for wsl for every source bashrc
# update_ssh_hostnames() {
#   awk '/^Host / { hostname=$2 } /^\tHostName / { print hostname " " $2 }' ~/.ssh/config > ~/.ssh/host_names
# }
# update_ssh_hostnames

# sshfs tool
safe_sshfs() {
  # 取得參數
  arg1=$1
  local_dir_path=$2

  # 判斷參數是否為 alias
  if [[ $# == 2 && $arg1 == *":"* ]]; then
    if [[ $(alias `echo "$arg1" | awk -F: '{print $1}'`) ]]; then
      # 取得 IP
      remote_ip=$(which `echo "$arg1" | awk -F: '{print $1}'` | awk '{print $NF}')
      # 取得 path
      remote_path=$(echo "$arg1" | awk -F: '{print $NF}')

      if [[ $(alias `echo "$arg1" | awk -F: '{print $1}'`) == *"-p"* ]]; then
        # 取出 -p 後的值
        port_arg=$(alias `echo "$arg1" | awk -F: '{print $1}'` | awk -F "-p" '{print $2}' | awk '{print "-p " $1}')
      else
        # 沒有 port 則輸出空字串
        port_arg=""
      fi
      # 輸出轉換後的字串
      # echo "$port_arg ${remote_ip}:${remote_path}"
      remote_address="$remote_ip:$remote_path"
      if [[ ! -e $local_dir_path ]]; then
        mkdir -p $local_dir_path 
        chattr +i $local_dir_path 
      fi
      if [ -z "$(ls -A $local_dir_path)" ]; then
        sshfs $port_arg $remote_address $local_dir_path 
      fi
      echo "sshfs link create sucess ..."
      echo "sshfs (Remote) => $remote_address $port_arg"
      echo "sshfs (local)  => $local_dir_path"
    else
      echo "[ERROR] not register ssh address to bashrc"
    fi
  else
    echo "[ERROR] Please input : sshalias:/path/ local_path"
  fi
}
unlink_sshfs(){
  for arg in "$@"
  do
    (fusermount -zu $arg || echo "[faile] You can try : umount -l $arg && chattr -i $arg && rm -rf $arg") && \
    chattr -i $arg && \
    rm -rf $arg
  done
}


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

passwordless_ssh () {
  # 取得參數
  arg1=$1

  public_key_check_and_generate () {
    if [ ! -f ~/.ssh/id_rsa.pub ]; then
      echo "Public key does not exist, generate a new one? (y/n)"
      read answer
      if [ "$answer" = "y" ]; then
        ssh-keygen
        if [ $? -ne 0 ]; then
          echo "Failed to generate public key."
          return 1
        fi
        
        # 设置权限
        chmod 700 ~/.ssh
        chmod 600 ~/.ssh/id_rsa
        chmod 644 ~/.ssh/id_rsa.pub
        echo "SSH public key has been generated and permissions set."
      else
        echo "Skipping public key generation."
      fi
    fi
  }
  passwordless_is_not_ok () {
    passwordless_check_command="ssh -o BatchMode=yes $remote_address"
    if echo $passwordless_check_command | sh >/dev/null; then
      echo "$remote_address is already passwordless."
      return 0
    fi
    return 1
  }
  # 判斷參數是否為 alias
  if [[ $# == 1 ]]; then
    if [[ $(alias `echo "$arg1"`) ]]; then
      # 取得 IP
      remote_ip=$(alias `echo "$arg1"` | awk '{print $NF}' | sed "s/['\"]//g")
      # 驗證 IP 是否合法，避免 command injection
      if ! echo "$remote_ip" | grep -E '^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+$' >/dev/null; then
        echo "[ERROR] remote_ip is not valid"
        return
      fi

      if [[ $(alias `echo "$arg1"`) == *"-p"* ]]; then
        # 取出 -p 後的值
        port_arg=$(alias `echo "$arg1"` | awk -F "-p" '{print $2}' | awk '{print "-p " $1}')
      else
        # 沒有 port 則輸出空字串
        port_arg=""
      fi
      # 輸出轉換後的字串
      # echo "$port_arg ${remote_ip}"
      remote_address="$port_arg $remote_ip"
      
      # 檢查公私鑰是否生成
      public_key_check_and_generate || return 1
      # 檢查先前是否已設定好免登
      passwordless_is_not_ok && return 0


      target_remote_authorized_key_command="mkdir -p ~/.ssh ; cat >> ~/.ssh/authorized_keys"
      local_rsa_pub_path=~/.ssh/id_rsa.pub
      passwordless_command="ssh $remote_address \"$target_remote_authorized_key_command\" < $local_rsa_pub_path"
      echo "execute passwordless command : $passwordless_command"
      echo $passwordless_command | sh
    else
      echo "[ERROR] not register ssh address to bashrc"
    fi
  else
    echo "[ERROR] Please input : passwordless_ssh sshalias"
  fi
}

ls_ssh_tools() {
  # 定义忽略清单
  ignoreList=(
    "mount.sshfs" "start-ssh-pageant.cmd"
    "ssh-add.exe" "dask-ssh.exe" "sshd"
    "ssh-keygen.exe" "mount.fuse.sshfs"
    "ssh-agent.exe" "ssh-add" "ssh-argv0"
    "dask-ssh-script.py" "dask-ssh" "ssh-agent"
    "ssh-shellhost.exe" "libssh2.dll"
    "ssh-import-id-gh" "ssh.exe"
    "ssh-import-id-lp" "start-ssh-agent.cmd"
    "sshd.exe" "sshd_config_default" "ssh-copy-id"
    "ssh-import-id" "ssh-keyscan.exe" "prompt_ssh"
    "instant_prompt_ssh"
  )

  # 将忽略清单用 | 合并成一个正则表达式
  ignorePattern=$(IFS="|"; echo "${ignoreList[*]}")
  # 获取所有命令并过滤掉忽略清单中的条目，且排除以 _ 开头的条目，然后筛选出包含 ssh 或 sshfs 的命令
  compgen -c | grep -Ev "^($ignorePattern)$" | grep -Ev '^_' | grep -E 'ssh|sshfs'
}


# if [[ "$0" == "bash" ]]; then
#   [[ -z $TMUX ]] || conda deactivate; conda activate base
#   export NVM_DIR="$HOME/.nvm"
#   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#   [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#   [ -f ~/.fzf.bash ] && source ~/.fzf.bash
# fi
