# shellcheck shell=bash
# 共用函式（bash 與 zsh 都會 source）
# ssh 相關函式會讀 alias 取得連線參數，lab 的 alias 放在 ~/.alias.local

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

# sshfs tool
safe_sshfs() {
  # 取得參數
  arg1=$1
  local_dir_path=$2

  # 判斷參數是否為 alias 並檢查是否包含 ":"
  if [[ $# == 2 && $arg1 != *":"* ]]; then
    echo "[WARNING] Please input : sshalias:/path/ local_path"
    echo -n "Do you want to use '~/ (safesshfs sshalias: local_path) as the default path? [y/n]: "
    read -r choice
    if [[ "$choice" =~ ^[yY]([eE][sS])?$ ]]; then
      arg1="${arg1}:"
    else
      echo "[ERROR] Operation cancelled. Please input a valid remote path."
      return 1
    fi
  fi

  # 判斷參數是否為 alias
  if [[ $# == 2 && $arg1 == *":"* ]]; then
    if alias_name=$(alias `echo "$arg1" | awk -F: '{print $1}'` 2>/dev/null); then
      
      # 检查是否存在 -J 选项
      if echo "$alias_name" | grep -q "\-J"; then
        # 提取跳板机地址和最终目标地址
        remote_jump_target_ip=$(echo "$alias_name" | awk '{print $NF}' | sed "s/['\"]//g")
        remote_ip=$(echo "$alias_name" | awk '{print $(NF-1)}' | sed "s/['\"]//g")
      else
        # 仅有最终目标地址
        remote_ip=$(echo "$alias_name" | awk '{print $NF}' | sed "s/['\"]//g")
      fi

      # 取得 path
      remote_path=$(echo "$arg1" | awk -F: '{print $NF}')

      # 檢查是否存在 port 設定
      if echo "$alias_name" | grep -q "\-p"; then
        port_arg=$(echo "$alias_name" | awk -F "-p" '{print $2}' | awk '{print "-p " $1}')
      else
        port_arg=""
      fi

      # 構建完整的 sshfs 命令
      if [[ ! -z "$remote_jump_target_ip" ]]; then
        sshfs_command="sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,ProxyJump=${remote_ip} $port_arg ${remote_jump_target_ip}:${remote_path} $local_dir_path"
      else
        sshfs_command="sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 $port_arg ${remote_ip}:${remote_path} $local_dir_path"
      fi

      # 確保本地掛載點存在
      if [[ ! -e $local_dir_path ]]; then
        mkdir -p $local_dir_path 
        chattr +i $local_dir_path 
      fi

      # 如果掛載點是空的，執行 sshfs 掛載
      if [ -z "$(ls -A $local_dir_path)" ]; then
        eval "$sshfs_command"
      fi

      echo "sshfs link create success ..."
      echo "sshfs (Remote) => $remote_ip:$remote_path $port_arg"
      echo "sshfs (local)  => $local_dir_path"
    else
      echo "[ERROR] not register ssh address to bashrc"
    fi
  else
    echo "[ERROR] Invalid input. Please check your input format."
    echo "Please input : passwordless_ssh sshalias"
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
    command_line=$(echo "$command_line" | sed 's/,ProxyJump=/ -J /')
    command_line=$(echo "$command_line" | sed 's/-o [^ ]* //')

    local jump_command=$(echo "$command_line" | awk '{for(i=1;i<=NF;i++) if($i=="-J") print $(i+1)}' | sed 's/-J //')
    [ -n "$jump_command" ] && jump_command="-J $jump_command"
    
    if echo "$command_line" | grep -q "\-J"; then
      local ssh_address_info=$(echo "$command_line" | awk '{print $8}')
      local local_mount_point=$(echo "$command_line" | awk '{print $9}')
    else
      local ssh_address_info=$(echo "$command_line" | awk '{print $6}')
      local local_mount_point=$(echo "$command_line" | awk '{print $7}')
    fi
    local ssh_address=${ssh_address_info%%:*}
    local work_dir=${ssh_address_info#*:}
    [ -z "$work_dir" ] && work_dir="~"


    if [[ "$current_dir" == "$local_mount_point"* ]]; then
      local sub_dir=${current_dir#$local_mount_point}
      ssh_cmd="ssh -t -Y -C ${port_command} ${jump_command} ${ssh_address} \"cd ${work_dir}${sub_dir} ; bash --login\""
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
      # remote_ip=$(alias `echo "$arg1"` | awk '{print $NF}' | sed "s/['\"]//g")
      if alias `echo "$arg1"` | grep -q "\-J"; then
        remote_jump_target_ip=$(alias `echo "$arg1"` | awk '{print $NF}' | sed "s/['\"]//g")
        remote_ip=$(alias `echo "$arg1"` | awk '{print $(NF-1)}' | sed "s/['\"]//g")
      else
        remote_ip=$(alias `echo "$arg1"` | awk '{sub(/ -p [0-9]+/,"");print}' | awk '{print $NF}' | sed "s/['\"]//g")
      fi
      
      # 驗證 IP 是否合法，避免 command injection (透過 tr 可以用於檢測逗點分隔的跳板機 ip 是否合法)
      if ! echo "$remote_ip" | tr ',' ' ' | xargs -n1 | grep -E '^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-:]+$' >/dev/null; then
        echo $remote_ip
        echo "[ERROR] remote_ip is not valid"
        return
      fi

      if [[ $(alias `echo "$arg1"`) == *"-p"* ]]; then
        # 取出 -p 後的值
        port_arg=$(alias `echo "$arg1"` | awk -F "-p" '{print $2}' | awk '{print "-p " $1}' | sed "s/['\"]//g")
      else
        # 沒有 port 則輸出空字串
        port_arg=""
      fi
      
      # 輸出轉換後的字串
      # echo "$port_arg ${remote_ip}"
      if alias `echo "$arg1"` | grep -q "\-J"; then
        remote_address="$port_arg -J $remote_ip $remote_jump_target_ip"
      else
        remote_address="$port_arg $remote_ip"
      fi
      
      # 檢查公私鑰是否生成
      public_key_check_and_generate || return 1
      # 檢查先前是否已設定好免登
      passwordless_is_not_ok && return 0


      target_remote_authorized_key_command="mkdir -p ~/.ssh ; cat >> ~/.ssh/authorized_keys"
      local_rsa_pub_path=~/.ssh/id_rsa.pub
      passwordless_command="ssh $remote_address \"$target_remote_authorized_key_command\" < $local_rsa_pub_path"
      echo "execute passwordless command : $passwordless_command"
      echo $passwordless_command | sh
      return 0
    else
      echo "[ERROR] not register ssh address to bashrc"
      return 1
    fi
  else
    echo "[ERROR] Please input : passwordless_ssh sshalias"
    return 1
  fi
}

# `apt install wslu`, for wslvar
# References: https://wslu.wedotstud.io/wslu/zh-TW/install.html
ssh_sshconfig_sync_remote_for_nvim_intergration_vscode() {
  arg1=$1
  
  # 检测是否在 WSL 环境中
  if ! grep -qiE "(microsoft|WSL)" /proc/sys/kernel/osrelease &>/dev/null; then
    echo "[ERROR] This script is designed to run within a WSL environment."
    return 1
  fi

  passwordless_ssh $arg1 || return 0
  # 實作在 ~/bin/vscode-remote-host-sync：用 alias 的 ssh 參數（去掉 ssh / -Y / -C）連線，
  # Host 別名由目標 IP 對照 Windows ssh config 決定，寫入 server 的 ~/.ssh/host_names.d/<IP>
  # （每個 IP 一個檔案，共用 NFS 的 server 不會互相覆蓋）
  local ssh_args
  ssh_args=$(alias "$arg1" | sed -E "s/^(alias )?[^=]+='?//; s/'$//" |
    awk '{ for (i = 1; i <= NF; i++) if ($i != "ssh" && $i !~ /^-[YC]+$/) printf "%s ", $i }')
  vscode-remote-host-sync -- $ssh_args
}
# ex : ssh_sshconfig_sync_remote_for_nvim_intergration_vscode sshdp
# 或直接用 Windows ssh config 的 Host 別名（跳板機鏈自動解析）: vscode-remote-host-sync LabServer29
# ex : ssh LabServerDP 'cat > ~/.ssh/host_names' < ~/.ssh/host_names > /dev/null 2>&1

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

fzf_rlgrep() {
  printf "Input your file name (wildcard support) : "
  read -r grep_fn
  grep_search=$(find . -iname $grep_fn -type f -exec cat {} \; \
  | fzf --preview "echo -e \"$fg[green]Search :\n{}\n\n$fg[magenta]FilePath :\"; \
  grep -F -rl --include=\"$grep_fn\" {}")
  printf '%.s─' $(seq 1 $(tput cols))
  echo -e "$fg[green]Search :\n$grep_search\n\n$fg[magenta]FilePath :"
  grep -F -rl --include=$grep_fn "$grep_search"
}

w3mimg () {
	w3m -o imgdisplay=/usr/lib/w3m/w3mimgdisplay $1
}
