#!/bin/bash

DOT_CONFIG_DIR="$(pwd)/.config"
TARGET_CONFIG_DIR="$HOME/.config"
MARKER_FILE="$TARGET_CONFIG_DIR/.amsc-dot-installed"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
CURRENT_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "unknown")

FORCE=false
[[ "$*" == *"--force"* ]] && FORCE=true

if [ "$FORCE" = false ] && [ -f "$MARKER_FILE" ] && grep -q "$CURRENT_COMMIT" "$MARKER_FILE"; then
    echo "[Skip] Commit $CURRENT_COMMIT is already applied."
    exit 0
fi

echo "[Start] Applying patches from Branch: $CURRENT_BRANCH, Commit: $CURRENT_COMMIT"

find "$DOT_CONFIG_DIR" -type f | while read -r src; do
    [[ "$src" == *".amsc-dot-installed" ]] && continue

    rel_path="${src#$DOT_CONFIG_DIR/}"
    dest="$TARGET_CONFIG_DIR/$rel_path"
    dest_dir=$(dirname "$dest")

    mkdir -p "$dest_dir"

    if [ -f "$dest" ]; then
        MARK_BEGIN="# >>> dotfiles: $rel_path"
        MARK_END="# <<< dotfiles: $rel_path"

        # Always remove existing block if it exists
        if grep -q "$MARK_BEGIN" "$dest"; then
            echo "[Patch-Update] $rel_path"
            sed -i "/$MARK_BEGIN/,/$MARK_END/d" "$dest"
        else
            echo "[Patch-New] $rel_path (Backup: .bak)"
            cp -p "$dest" "${dest}.bak"
        fi

        echo -e "\n$MARK_BEGIN" >> "$dest"
        cat "$src" >> "$dest"
        echo "$MARK_END" >> "$dest"
    else
        echo "[Copy] $rel_path"
        cp -p "$src" "$dest"
    fi
done

{
    echo "Applied on: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Branch: $CURRENT_BRANCH"
    echo "Commit: $CURRENT_COMMIT"
    echo "--------------------------------"
} >> "$MARKER_FILE"

echo "[Done] Installation complete."
