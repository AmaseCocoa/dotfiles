#!/bin/bash

CORE_PKGS=("base-devel" "git" "neovim" "zsh" "tmux" "fastfetch" "fzf" "ripgrep" "fd" "bat" "htop" "unzip" "curl" "wget")
FONTS=("noto-fonts" "noto-fonts-cjk" "noto-fonts-emoji")

ask_yes_no() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]* ) return 0 ;;
            [Nn]* ) return 1 ;;
            * ) echo "Please answer y or n." ;;
        esac
    done
}

install_interactive() {
    local group_name=$1
    shift
    local pkgs=("$@")
    local targets=()

    echo -e "\n--- Group: $group_name ---"
    if ask_yes_no "Install ALL packages in $group_name?"; then
        targets=("${pkgs[@]}")
    else
        for pkg in "${pkgs[@]}"; do
            if ask_yes_no "  -> Install $pkg?"; then
                targets+=("$pkg")
            fi
        done
    fi

    if [ ${#targets[@]} -gt 0 ]; then
        echo "Installing: ${targets[*]}"
        sudo pacman -S --needed --noconfirm "${targets[@]}"
    else
        echo "Skipping $group_name."
    fi
}

echo "--- Package Installation Selection ---"
sudo pacman -Syu --noconfirm

install_interactive "Core Tools" "${CORE_PKGS[@]}"
install_interactive "Fonts" "${FONTS[@]}"

echo -e "\n--- Extra ---"
if ask_yes_no "Do you want to install any other specific packages?"; then
    read -p "Enter package names (separated by space): " extra_pkgs
    if [ -n "$extra_pkgs" ]; then
        sudo pacman -S --needed --noconfirm $extra_pkgs
    fi
fi

echo -e "\n--- All processes completed ---"
