#!/usr/bin/env bash
#colors
RD='\033[00;31m'
GN='\033[00;32m'
YW='\033[00;33m'
BE='\033[00;34m'
WE='\033[01;37m'
NC='\033[00;37m'
#
#ascii art as it says for the menu
#
asciiart() {
echo -e "  ___  ____  ____  ____ "
echo -e " / __)(  __)(    \(  __)"
echo -e "( (_ \ ) _)  ) D ( ) _) "
echo -e " \___/(__)  (____/(____)"
echo -e "GfDE Script by g-flame(https://github.com/g-flame)"
echo -e "Based on HyDE! and my own stuff and dots too.. [MIT license!]"
}
#
#main menu
#
main() {
    dialog --title "GfDE" --yesno "Let us start the install, shall we?" 10 40
    response=$?
    if [ $response -eq 0 ]; then
        clear
        asciiart
        startinstaller
    else
        exit 0
    fi
}

# Installer function
startinstaller() {
    TMP_FILE=$(mktemp)

    dialog --title "Installer v1.0" \
        --checklist "Select the stuff you want to include:" 15 60 6 \
        1 "Install Hyprland and dependencies" on \
        2 "Install dotfiles" off \
        3 "Install GTK + Cursor themes" off \
        4 "Add boot animation" off \
        5 "Install additional software" off 2>"$TMP_FILE"

    if [ $? -ne 0 ]; then
        echo "Operation cancelled."
        rm -f "$TMP_FILE"
        exit 1
    fi

    CHOICES=$(cat "$TMP_FILE")
    rm -f "$TMP_FILE"

    for choice in $CHOICES; do
        case $choice in
            "\"1\"")
                baseinstall
                ;;
            "\"2\"")
                dots
                ;;
            "\"3\"")
                install_themes
                ;;
            "\"4\"")
                boot_animation
                ;;
            "\"5\"")
                additional_software
                ;;
        esac
    done
}

# Stub functions (replace with real logic)
baseinstall() {
    clear
    echo -e "${GN}Installing Hyprland and dependencies...${NC}"
    pacman -S git
    sudo chmod +x HyDE/Scripts/install.sh 
    rm HyDE/Scripts/pkg_core.lst
    mv assets/pkg_core.lst HyDE/Scripts/
    git clone https://github.com/HyDE-Project/HyDE.git
    echo -e "Using HyDE script to install the packages"
    sleep 2
    clear 
    bash HyDE/Scripts/install.sh
    echo -e "base HyDE Install should be complete!"
    sleep 2
}

dots() {
    echo -e "${GN}coming soon!!1${NC}"
    sleep 2
}

install_themes() {
    echo -e "${GN}coming soon!!1${NC}"
    sleep 2
}

boot_animation() {
    echo -e "${GN}Setting up boot animation...${NC}"
    sleep 2
    
    # Check if Plymouth is installed
    if ! pacman -Qi plymouth &> /dev/null; then
        echo -e "${YW}Installing Plymouth...${NC}"
        if ! sudo pacman -S --needed --noconfirm plymouth; then
            echo -e "${RD}Failed to install Plymouth${NC}"
            return 1
        fi
    else
        echo -e "${GN}Plymouth already installed${NC}"
    fi
    
    # Define theme paths
    local THEME_SOURCE="assets/maclikeboot"
    local THEME_DEST="/usr/share/plymouth/themes/maclikeboot"
    local THEME_NAME="maclikeboot"
    
    # Check if source theme exists
    if [ ! -d "$THEME_SOURCE" ]; then
        echo -e "${RD}Theme source directory not found: $THEME_SOURCE${NC}"
        return 1
    fi
    
    # Create backup of current Plymouth configuration
    echo -e "${YW}Backing up current configuration...${NC}"
    sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.backup 2>/dev/null || true
    
    # Copy theme to Plymouth themes directory
    echo -e "${YW}Installing maclikeboot theme...${NC}"
    sudo mkdir -p "$(dirname "$THEME_DEST")"
    sudo cp -r "$THEME_SOURCE" "$THEME_DEST"
    
    # Set proper permissions
    sudo chmod -R 755 "$THEME_DEST"
    sudo chown -R root:root "$THEME_DEST"
    
    # Configure mkinitcpio.conf to include Plymouth
    echo -e "${YW}Configuring mkinitcpio...${NC}"
    if ! grep -q "plymouth" /etc/mkinitcpio.conf; then
        # Add plymouth after base and udev hooks
        sudo sed -i '/^HOOKS=/ s/)/ plymouth)/' /etc/mkinitcpio.conf
        echo -e "${GN}Added Plymouth to mkinitcpio hooks${NC}"
    else
        echo -e "${GN}Plymouth already in mkinitcpio hooks${NC}"
    fi
    
    # Set the theme as default
    echo -e "${YW}Setting maclikeboot as default theme...${NC}"
    if sudo plymouth-set-default-theme "$THEME_NAME"; then
        echo -e "${GN}Theme set successfully${NC}"
    else
        echo -e "${RD}Failed to set theme${NC}"
        return 1
    fi
    
    # Detect and configure bootloader
    echo -e "${YW}Detecting bootloader...${NC}"
    local bootloader_configured=false
    
    # Check for GRUB
    if [ -f /etc/default/grub ] && command -v grub-mkconfig &> /dev/null; then
        echo -e "${GN}GRUB detected${NC}"
        echo -e "${YW}Configuring GRUB...${NC}"
        
        # Backup GRUB config
        sudo cp /etc/default/grub /etc/default/grub.backup 2>/dev/null || true
        
        # Add quiet and splash parameters if not present
        if ! grep -q "quiet.*splash\|splash.*quiet" /etc/default/grub; then
            sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\([^"]*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 quiet splash"/' /etc/default/grub
            # Clean up any double spaces
            sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="  */GRUB_CMDLINE_LINUX_DEFAULT="/' /etc/default/grub
            echo -e "${GN}Added boot parameters to GRUB${NC}"
        else
            echo -e "${GN}Boot parameters already configured in GRUB${NC}"
        fi
        
        # Update GRUB configuration
        echo -e "${YW}Updating GRUB configuration...${NC}"
        if sudo grub-mkconfig -o /boot/grub/grub.cfg; then
            echo -e "${GN}GRUB updated successfully${NC}"
            bootloader_configured=true
        else
            echo -e "${YW}Warning: Failed to update GRUB config${NC}"
        fi
    fi
    
    # Check for systemd-boot
    if [ -d /boot/loader ] && [ -f /boot/loader/loader.conf ]; then
        echo -e "${GN}systemd-boot detected${NC}"
        echo -e "${YW}Configuring systemd-boot...${NC}"
        
        local entries_dir="/boot/loader/entries"
        local entries_found=false
        
        if [ -d "$entries_dir" ]; then
            # Process all .conf files in entries directory
            for entry_file in "$entries_dir"/*.conf; do
                if [ -f "$entry_file" ]; then
                    entries_found=true
                    echo -e "${YW}Updating entry: $(basename "$entry_file")${NC}"
                    
                    # Backup entry file
                    sudo cp "$entry_file" "$entry_file.backup" 2>/dev/null || true
                    
                    # Check if options line exists and add quiet splash if not present
                    if grep -q "^options" "$entry_file"; then
                        if ! grep -q "quiet.*splash\|splash.*quiet" "$entry_file"; then
                            sudo sed -i '/^options/ s/$/ quiet splash/' "$entry_file"
                            echo -e "${GN}Added boot parameters to $(basename "$entry_file")${NC}"
                        else
                            echo -e "${GN}Boot parameters already present in $(basename "$entry_file")${NC}"
                        fi
                    else
                        # If no options line exists, we can't easily add one without knowing root partition
                        echo -e "${YW}Warning: No options line found in $(basename "$entry_file")${NC}"
                        echo -e "${YW}Please manually add 'quiet splash' to your boot options${NC}"
                    fi
                fi
            done
            
            if [ "$entries_found" = true ]; then
                echo -e "${GN}systemd-boot entries updated successfully${NC}"
                bootloader_configured=true
            fi
        else
            echo -e "${YW}systemd-boot entries directory not found${NC}"
        fi
    fi
    
    # Check for rEFInd
    if [ -f /boot/EFI/refind/refind.conf ] || [ -f /boot/refind_linux.conf ]; then
        echo -e "${GN}rEFInd detected${NC}"
        echo -e "${YW}Configuring rEFInd...${NC}"
        
        local refind_linux_conf="/boot/refind_linux.conf"
        if [ -f "$refind_linux_conf" ]; then
            # Backup refind_linux.conf
            sudo cp "$refind_linux_conf" "$refind_linux_conf.backup" 2>/dev/null || true
            
            # Add quiet splash to boot options if not present
            if ! grep -q "quiet.*splash\|splash.*quiet" "$refind_linux_conf"; then
                sudo sed -i 's/"$/ quiet splash"/' "$refind_linux_conf"
                echo -e "${GN}Added boot parameters to rEFInd${NC}"
            else
                echo -e "${GN}Boot parameters already configured in rEFInd${NC}"
            fi
            bootloader_configured=true
        else
            echo -e "${YW}rEFInd detected but refind_linux.conf not found${NC}"
            echo -e "${YW}Please manually add 'quiet splash' to your rEFInd boot options${NC}"
        fi
    fi
    
    # Check for EFISTUB (direct EFI boot)
    if [ -d /sys/firmware/efi ] && ! [ "$bootloader_configured" = true ]; then
        echo -e "${YW}EFI system detected without recognized bootloader${NC}"
        echo -e "${YW}If using EFISTUB, manually add 'quiet splash' to your EFI boot entry${NC}"
        echo -e "${YW}Example: efibootmgr --create --disk /dev/sdX --part Y --loader /vmlinuz-linux --unicode 'root=PARTUUID=... rw quiet splash initrd=\\initramfs-linux.img'${NC}"
    fi
    
    # Check for LILO (legacy)
    if [ -f /etc/lilo.conf ] && command -v lilo &> /dev/null; then
        echo -e "${GN}LILO detected${NC}"
        echo -e "${YW}Configuring LILO...${NC}"
        
        # Backup LILO config
        sudo cp /etc/lilo.conf /etc/lilo.conf.backup 2>/dev/null || true
        
        # Add quiet splash to append line if not present
        if grep -q "append=" /etc/lilo.conf; then
            if ! grep -q "quiet.*splash\|splash.*quiet" /etc/lilo.conf; then
                sudo sed -i '/append=/ s/"$/ quiet splash"/' /etc/lilo.conf
                echo -e "${GN}Added boot parameters to LILO${NC}"
            else
                echo -e "${GN}Boot parameters already configured in LILO${NC}"
            fi
        else
            # Add append line if it doesn't exist
            sudo sed -i '/^[[:space:]]*linux/ a\    append="quiet splash"' /etc/lilo.conf
            echo -e "${GN}Added append line with boot parameters to LILO${NC}"
        fi
        
        # Update LILO
        if sudo lilo; then
            echo -e "${GN}LILO updated successfully${NC}"
            bootloader_configured=true
        else
            echo -e "${YW}Warning: Failed to update LILO${NC}"
        fi
    fi
    
    # Summary
    if [ "$bootloader_configured" = true ]; then
        echo -e "${GN}Bootloader configuration completed${NC}"
    else
        echo -e "${YW}No recognized bootloader found or configuration failed${NC}"
        echo -e "${YW}Please manually add 'quiet splash' to your boot parameters${NC}"
        echo -e "${YW}Common locations:${NC}"
        echo -e "${YW}  - GRUB: /etc/default/grub (GRUB_CMDLINE_LINUX_DEFAULT)${NC}"
        echo -e "${YW}  - systemd-boot: /boot/loader/entries/*.conf (options line)${NC}"
        echo -e "${YW}  - rEFInd: /boot/refind_linux.conf${NC}"
    fi
    
    # Enable Plymouth services
    echo -e "${YW}Enabling Plymouth services...${NC}"
    sudo systemctl enable plymouth-start.service 2>/dev/null || true
    sudo systemctl enable plymouth-quit.service 2>/dev/null || true
    
    # Regenerate initramfs
    echo -e "${YW}Regenerating initramfs...${NC}"
    if sudo mkinitcpio -P; then
        echo -e "${GN}Initramfs regenerated successfully${NC}"
    else
        echo -e "${RD}Failed to regenerate initramfs${NC}"
        return 1
    fi
    
    # Verify installation
    echo -e "${YW}Verifying installation...${NC}"
    if [ -d "$THEME_DEST" ] && plymouth-set-default-theme -l | grep -q "$THEME_NAME"; then
        echo -e "${GN}✓ Theme installed and configured successfully${NC}"
        echo -e "${GN}✓ Boot animation will be active after reboot${NC}"
        
        # Show current theme
        local current_theme=$(plymouth-set-default-theme)
        echo -e "${GN}Current theme: $current_theme${NC}"
        
        return 0
    else
        echo -e "${RD}Installation verification failed${NC}"
        return 1
    fi
}

additional_software() {
    echo -e "${GN}Installing additional software...${NC}"
    echo -e "Installing zen.."
    flatpak install flathub app.zen_browser.zen
    echo -e "zen install complete"
    echo -e "installing vs code..."
    yay -S visual-studio-code-bin
    echo -e "vs code installed.."

    sleep 2
}

# Cleanup on Ctrl+C
restore_screen() {
    echo -e "${YW}Restoring screen before script exit...${NC}"
    tput rmcup
    exit 0
}

# Initial setup
sudo pacman -Sy
sudo pacman -S --noconfirm dialog

trap restore_screen SIGINT
tput smcup
clear

# Run main flow
main

# Simulated install progress
for i in {1..30}; do
    echo -ne "Processing... $i/30\r"
    sleep 1
done

restore_screen