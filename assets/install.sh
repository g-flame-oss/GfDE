#!/usr/bin/env bash
#==============================================================================
# GfDE Installer
# Version: 0.8(alpha)
# Author: g-flame (https://github.com/g-flame)
# License: MIT
#==============================================================================
##########################################################################################
#       Installer by G-flame @ https://github.com/g-flame                                
#       Panel and Daemon by Airlinklabs @ https://github.com/airlinklabs                 
#                                                                                        
#       MIT License                                                                      
#                                                                                        
#       Copyright (c) 2025 G-flame-OSS                                                   
#                                                                                        
#       Permission is hereby granted, free of charge, to any person obtaining a copy     
#       of this software and associated documentation files (the "Software"), to deal    
#       in the Software without restriction, including without limitation the rights     
#       to use, copy, modify, merge, publish, distribute, sublicense, and/or sell        
#       copies of the Software, and to permit persons to whom the Software is            
#       furnished to do so, subject to the following conditions:                         
#                                                                                        
#       The above copyright notice and this permission notice shall be included in all  
#       copies or substantial portions of the Software.                                  
#                                                                                        
#       THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR       
#       IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,         
#       FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE      
#       AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER           
#       LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,    
#       OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   
#       SOFTWARE.                                                                        
##########################################################################################
# Colors
PURPLE='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'
CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

set -e
show_banner() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "  ╔════════════════════════════════════════════════════════════════╗"
    echo "  ║                                                                ║"
    echo "  ║     ___  ____  ____   ____                                     ║"
    echo "  ║    / __)(  __)(    \ (  __)                                    ║"
    echo "  ║   ( (__\\ ) _)  ) D ( ) _)                                      ║"
    echo "  ║    \\___/(__)  (____/(____)                                      ║"
    echo "  ║                                                                ║"
    echo "  ╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e "${CYAN}${BOLD}Made by g-flame ${RESET}"
    echo -e "${GREEN}License: MIT${RESET}"
    echo ""
}

# Detect OS and set package manager
detect_os() {
    if command -v pacman &> /dev/null; then
        OS="arch"
        PKG_MANAGER="pacman"
        INSTALL_CMD="sudo pacman -S --needed --noconfirm"
        UPDATE_CMD="sudo pacman -Syu --noconfirm"
        SYNC_CMD="sudo pacman -Sy"
    elif command -v apt &> /dev/null; then
        OS="debian"
        PKG_MANAGER="apt"
        INSTALL_CMD="sudo apt install -y"
        UPDATE_CMD="sudo apt update && sudo apt upgrade -y"
        SYNC_CMD="sudo apt update"
    elif command -v dnf &> /dev/null; then
        OS="fedora"
        PKG_MANAGER="dnf"
        INSTALL_CMD="sudo dnf install -y"
        UPDATE_CMD="sudo dnf upgrade -y"
        SYNC_CMD="sudo dnf check-update"
    elif command -v zypper &> /dev/null; then
        OS="opensuse"
        PKG_MANAGER="zypper"
        INSTALL_CMD="sudo zypper install -y"
        UPDATE_CMD="sudo zypper update -y"
        SYNC_CMD="sudo zypper refresh"
    else
        echo -e "${RED}Unsupported OS - no compatible package manager found${NC}"
        echo -e "${RED}Visit the manual install guide!${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Detected OS: $OS using $PKG_MANAGER${NC}"
}


# Install core packages
install_core() {
    echo -e "${BLUE}Installing GNOME desktop environment...${NC}"
    
    case $OS in
        arch)
            $INSTALL_CMD gnome gnome-extra gdm noto-fonts
            sudo systemctl enable gdm
            ;;
        debian)
            $INSTALL_CMD gnome-core gnome-shell-extensions gdm3 noto-fonts
            sudo systemctl enable gdm3
            ;;
        fedora)
            $INSTALL_CMD @gnome-desktop gdm noto-fonts
            sudo systemctl enable gdm
            ;;
        opensuse)
            $INSTALL_CMD gnome-desktop gdm noto-fonts
            sudo systemctl enable gdm
            ;;
    esac
    
    echo -e "${GREEN}GNOME desktop installed${NC}"
}

# Install boot animation
install_boot_animation() {
    echo -e "${BLUE}Installing boot animation...${NC}"
    
    # Install Plymouth
    case $OS in
        arch)
            $INSTALL_CMD plymouth
            ;;
        debian)
            $INSTALL_CMD plymouth plymouth-themes
            ;;
        fedora)
            $INSTALL_CMD plymouth plymouth-system-theme
            ;;
        opensuse)
            $INSTALL_CMD plymouth
            ;;
    esac
    
    # Update initramfs based on OS
    case $OS in
        arch)
            sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.backup
            sudo sed -i '/^HOOKS=/ s/)/ plymouth)/' /etc/mkinitcpio.conf
            sudo mkinitcpio -P
            ;;
        debian)
            sudo update-initramfs -u
            ;;
        fedora)
            sudo dracut --force
            ;;
        opensuse)
            sudo mkinitrd
            ;;
    esac
    
    # Update bootloader
    if [[ -f /etc/default/grub ]]; then
        sudo cp /etc/default/grub /etc/default/grub.backup
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\([^"]*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 quiet splash"/' /etc/default/grub
        
        case $OS in
            arch|debian)
                sudo grub-mkconfig -o /boot/grub/grub.cfg
                ;;
            fedora)
                sudo grub2-mkconfig -o /boot/grub2/grub.cfg
                ;;
            opensuse)
                sudo grub2-mkconfig -o /boot/grub2/grub.cfg
                ;;
        esac
    fi
    
    echo -e "${GREEN}Boot animation installed${NC}"
}

# Install GNOME extensions and customizations
install_gnome_customizations() {
    echo -e "${BLUE}Installing GNOME customizations...${NC}"
    
    # Install GNOME extensions and tweaks
    case $OS in
        arch)
            $INSTALL_CMD gnome-shell-extensions gnome-tweaks
            ;;
        debian)
            $INSTALL_CMD gnome-shell-extensions gnome-tweaks
            ;;
        fedora)
            $INSTALL_CMD gnome-extensions-app gnome-tweaks
            ;;
        opensuse)
            $INSTALL_CMD gnome-shell-extensions gnome-tweaks
            ;;
    esac
    
    # Install AUR helper and extensions for Arch
    if [[ $OS == "arch" ]]; then
        if ! command -v yay &> /dev/null; then
            install_aur_helper
        fi
        
        if command -v yay &> /dev/null; then
            yay -S --noconfirm gnome-shell-extension-dash-to-dock
            yay -S --noconfirm gnome-shell-extension-arc-menu
            yay -S --noconfirm gnome-shell-extension-blur-my-shell
        fi
    fi

    # lauching GfDE.sh 
    chmod +x GfDE.sh
    bash GfDE.sh
    
    echo -e "${GREEN}GNOME customizations installed${NC}"
}

# Install AUR helper (Arch only)
install_aur_helper() {
    if [[ $OS == "arch" ]] && ! command -v yay &> /dev/null; then
        echo -e "${BLUE}Installing AUR helper...${NC}"
        $INSTALL_CMD git base-devel
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ~
        rm -rf /tmp/yay
    fi
}

# Main menu
show_menu() {

    show_banner
    echo "=============================="
    echo "1. GfDE installation"
    echo "2. Base GNOME installation"
    echo "3. Exit"
    echo
    read -p "Choose option (1-3): " choice
    
    case $choice in
        1)  install_core
            install_boot_animation
            install_gnome_customizations
            ;;
        2) install_core
           install_boot_animation ;;
        3) exit 0;;
        *) echo -e "${RED}Invalid option${NC}" && show_menu ;;
    esac
}

# Main function
main() {
    # Detect OS first
    detect_os
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}Don't run this as root${NC}"
        exit 1
    fi
    
    # Update system
    echo -e "${BLUE}Updating system...${NC}"
    $UPDATE_CMD
    
    # Show menu
    show_menu
    
    # Done
    echo -e "${GREEN}Installation complete!${NC}"
    echo
    echo -e "${YELLOW}To use GNOME, select 'GNOME' from the login screen${NC}"
    echo
    read -p "Reboot now? (y/n): " reboot_choice
    if [[ $reboot_choice =~ ^[Yy]$ ]]; then
        sudo reboot
    fi
}

# Run main function
main "$@"