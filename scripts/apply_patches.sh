#!/bin/bash

DOT_CONFIG_DIR="$(pwd)/.config"
TARGET_CONFIG_DIR="$HOME/.config"

FORCE=false
[[ "$*" == *"--force"* ]] && FORCE=true

find "$DOT_CONFIG_DIR" -type f | while read -r src; do
    rel_path="${src#$DOT_CONFIG_DIR/}"
    dest="$TARGET_CONFIG_DIR/$rel_path"
    dest_dir=$(dirname "$dest")

    mkdir -p "$dest_dir"

    if [ -f "$dest" ] && [ ! -L "$dest" ]; then
        MARK_BEGIN="# >>> dotfiles: $rel_path"
        MARK_END="# <<< dotfiles: $rel_path"
        
        # Remove existing block to ensure updates are applied
        if grep -q "$MARK_BEGIN" "$dest"; then
            echo "[Patch-Update] $rel_path"
            sed -i "/$MARK_BEGIN/,/$MARK_END/d" "$dest"
        else
            echo "[Patch-New] $rel_path (Backing up to .bak)"
            cp "$dest" "${dest}.bak"
        fi

        echo -e "\n$MARK_BEGIN" >> "$dest"
        cat "$src" >> "$dest"
        echo "$MARK_END" >> "$dest"
    elif [ -L "$dest" ]; then
        echo "[Skip] Already a symlink: $rel_path"
    else
        echo "[Link] $rel_path"
        ln -s "$src" "$dest"
    fi
done
