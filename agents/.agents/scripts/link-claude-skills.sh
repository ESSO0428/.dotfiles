#!/usr/bin/env bash
# 把 ~/.agents/skills（唯一來源）以 symlink 發佈到 ~/.claude/skills。
#
# 規則：
#   - 來源 <name>/SKILL.md 存在          → 連到 <name>
#   - 否則 <name>/skills/<name>/SKILL.md → 連到該子目錄（整個 repo 型，如 ppt-master）
#   - 目的地已是 symlink                 → 改指向正確位置
#   - 目的地是實體目錄，且與來源（skill 目錄或 repo 根目錄）相同（忽略 .venv）→ 刪除後改成 symlink
#   - 目的地是實體目錄但內容不同          → 搬到 ~/.claude/skills-backup/ 再建 symlink
#   - 目的地指向來源、但來源已不存在的 symlink → 移除（skill 已解除安裝）
#   - 其他目的地項目（如 synced/）不碰
#
# 用法：DRY_RUN=1 link-claude-skills.sh   # 只顯示會做什麼
#       link-claude-skills.sh
set -euo pipefail

SRC="${SRC:-$HOME/.agents/skills}"
DST="${DST:-$HOME/.claude/skills}"
BACKUP="${BACKUP:-$HOME/.claude/skills-backup/$(date +%Y%m%d-%H%M%S)}"
DRY_RUN="${DRY_RUN:-0}"

run() { echo "+ $*"; [ "$DRY_RUN" = 1 ] || "$@"; }

mkdir -p "$DST"

for src_dir in "$SRC"/*/; do
  name=$(basename "$src_dir")
  if [ -f "$SRC/$name/SKILL.md" ]; then
    target="$SRC/$name"
  elif [ -f "$SRC/$name/skills/$name/SKILL.md" ]; then
    target="$SRC/$name/skills/$name"
  else
    echo "skip $name: 找不到 SKILL.md"
    continue
  fi

  dst="$DST/$name"
  if [ -L "$dst" ]; then
    [ "$(readlink "$dst")" = "$target" ] && continue
    run ln -sfn "$target" "$dst"
  elif [ -d "$dst" ]; then
    # 也和來源 repo 根目錄比對：目的地可能是整個 repo 的副本（如遷移前的 ppt-master）
    if diff -rq --no-dereference --exclude=.venv "$target" "$dst" >/dev/null 2>&1 \
      || diff -rq --no-dereference --exclude=.venv "$SRC/$name" "$dst" >/dev/null 2>&1; then
      run rm -rf "$dst"
    else
      echo "warn $name: 內容與來源不同，備份到 $BACKUP/$name"
      run mkdir -p "$BACKUP"
      run mv "$dst" "$BACKUP/$name"
    fi
    run ln -s "$target" "$dst"
  elif [ -e "$dst" ]; then
    echo "skip $name: $dst 不是目錄也不是 symlink"
  else
    run ln -s "$target" "$dst"
  fi
done

# 清掉指向來源、但來源已被移除的 symlink
for dst in "$DST"/*; do
  [ -L "$dst" ] || continue
  case "$(readlink "$dst")" in
    "$SRC"/*) [ -e "$dst" ] || run rm "$dst" ;;
  esac
done
