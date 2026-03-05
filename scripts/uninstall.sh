#!/bin/bash

DOT_CONFIG_DIR="$(pwd)/.config"
TARGET_CONFIG_DIR="$HOME/.config"
MARKER_FILE="$TARGET_CONFIG_DIR/.amsc-dot-installed"

echo "--- Dotfiles Uninstaller ---"

# 1. Remove patches from existing files
remove_patch() {
    local file=$1
    local id=$2
    local mark_begin="# >>> dotfiles: $id"
    local mark_end="# <<< dotfiles: $id"

    if [ -f "$file" ] && grep -q "$mark_begin" "$file"; then
        echo "[Uninstall] Removing patch from $file"
        # Use sed to delete the block between marks
        sed -i "/$mark_begin/,/$mark_end/d" "$file"
    fi
}

# Remove Hyprland patch
remove_patch "$HOME/.config/hypr/hyprland.conf" "keyboard.conf"

# Remove patches in .config/
find "$DOT_CONFIG_DIR" -type f | while read -r src; do
    rel_path="${src#$DOT_CONFIG_DIR/}"
    dest="$TARGET_CONFIG_DIR/$rel_path"

    if [ -L "$dest" ]; then
        echo "[Uninstall] Removing symlink: $rel_path"
        rm "$dest"
    elif [ -f "$dest" ]; then
        remove_patch "$dest" "$rel_path"
        # If the file was copied (not patched) by post-install, it might still exist.
        # However, we only remove it if it matches the source exactly or if it was purely a dotfiles addition.
        # For safety, we only remove the MARKED sections. 
        # If it's a file from our repo and NOT present in a 'virgin' install, users might want it gone.
        # But here we stick to removing our markers.
    fi
done

# 2. Clean up generated configs
COCOA_DIR="$HOME/.config/hypr/cocoa"
if [ -d "$COCOA_DIR" ]; then
    echo "[Uninstall] Removing $COCOA_DIR"
    rm -rf "$COCOA_DIR"
fi

# 3. Remove marker file
if [ -f "$MARKER_FILE" ]; then
    echo "[Uninstall] Removing installation marker"
    rm "$MARKER_FILE"
fi

echo "--- Uninstallation completed (Packages remain installed) ---"
