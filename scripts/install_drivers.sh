#!/bin/bash

install_pkg() {
    sudo pacman -S --needed --noconfirm "$@"
}

if ! command -v paru &> /dev/null; then
    echo "Installing paru..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru && makepkg -si --noconfirm && cd -
fi

VGA_ALL=$(lspci -nn | grep -iE "VGA|3D")
CPU_INFO=$(grep "model name" /proc/cpuinfo | head -n1)
IS_LAPTOP=false
[ -d /sys/class/power_supply/BAT0 ] && IS_LAPTOP=true

echo "Detected Hardware:"
echo "$VGA_ALL"

if echo "$VGA_ALL" | grep -iq "intel"; then
    echo "Configuring Intel iGPU..."
    install_pkg mesa vulkan-intel lib32-vulkan-intel
    
    if echo "$CPU_INFO" | grep -qE "\-[5-9][0-9]{3}|-[1-9][0-9]{4}|Arc|Ultra"; then
        install_pkg intel-media-driver
    else
        install_pkg libva-intel-driver
    fi
fi

if echo "$VGA_ALL" | grep -iq "amd"; then
    echo "Configuring AMD GPU..."
    install_pkg mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon libva-mesa-driver
fi

if echo "$VGA_ALL" | grep -iq "nvidia"; then
    DEV_ID=$(echo "$VGA_ALL" | grep -i "nvidia" | grep -oP '\[10de:\K[0-9a-f]{4}' | head -n1)
    
    echo "Configuring NVIDIA dGPU (ID: $DEV_ID)..."
    
    if [[ "0x$DEV_ID" -ge "0x1b80" ]]; then
        install_pkg nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings
    elif [[ "0x$DEV_ID" -ge "0x1180" ]]; then
        yay -S --noconfirm nvidia-470xx-dkms nvidia-470xx-utils lib32-nvidia-470xx-utils
    else
        install_pkg xf86-video-nouveau
    fi
fi

if [ "$IS_LAPTOP" = true ]; then
    echo "Installing laptop utilities..."
    install_pkg libinput xf86-input-libinput brightnessctl bluez bluez-utils
    sudo systemctl enable bluetooth
fi

VIRT=$(systemd-detect-virt)
if [ "$VIRT" != "none" ]; then
    echo "VM Environment: $VIRT"
    case "$VIRT" in
        vmware) install_pkg open-vm-tools ;;
        oracle) install_pkg virtualbox-guest-utils ;;
        kvm)    install_pkg qemu-guest-agent ;;
    esac
fi

install_pkg pipewire pipewire-pulse pipewire-alsa wireplumber
