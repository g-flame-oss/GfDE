#!/usr/bin/env bash
#==============================================================================
# GfDE Installer
# Version: 1.0
# Author: g-flame (https://github.com/g-flame)
# Based on HyDE! with custom modifications
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

#==============================================================================
# COLOR DEFINITIONS
#==============================================================================
readonly RD='\033[00;31m'    # Red
readonly GN='\033[00;32m'    # Green
readonly YW='\033[00;33m'    # Yellow
readonly BE='\033[00;34m'    # Blue
readonly MG='\033[00;35m'    # Magenta
readonly CY='\033[00;36m'    # Cyan
readonly WE='\033[01;37m'    # White (Bold)
readonly NC='\033[00;37m'    # No Color (Reset)
readonly BD='\033[1m'        # Bold
readonly UL='\033[4m'        # Underline

#==============================================================================
# LOGGING FUNCTIONS
#==============================================================================
log_info() {
    echo -e "${CY}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RD}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BE}[STEP]${NC} $1"
}

#==============================================================================
# UTILITY FUNCTIONS
#==============================================================================
show_progress() {
    local current=$1
    local total=$2
    local message=$3
    local percent=$((current * 100 / total))
    local bar_length=30
    local filled_length=$((percent * bar_length / 100))
    
    printf "\r${CY}[$message]${NC} ["
    printf "%*s" $filled_length | tr ' ' '█'
    printf "%*s" $((bar_length - filled_length)) | tr ' ' '░'
    printf "] %d%% (%d/%d)" $percent $current $total
}

press_any_key() {
    echo -e "\n${YW}Press any key to continue...${NC}"
    read -n 1 -s
}

confirm_action() {
    local message=$1
    echo -e "${YW}$message (y/N): ${NC}"
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

#==============================================================================
# ASCII ART BANNER
#==============================================================================
display_banner() {
    clear
    echo -e "${MG}${BD}"
    echo "  ╔════════════════════════════════════════════════════════════════╗"
    echo "  ║                                                                ║"
    echo "  ║     ___  ____  ____  ____                                     ║"
    echo "  ║    / __)(  __)(    \\(  __)                                    ║"
    echo "  ║   ( (_ \\ ) _)  ) D ( ) _)                                     ║"
    echo "  ║    \\___/(__)  (____/(____) ${GN}Desktop Environment${MG}           ║"
    echo "  ║                                                                ║"
    echo "  ╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${CY}${BD}GfDE Script by g-flame${NC} ${WE}(https://github.com/g-flame)${NC}"
    echo -e "${WE}Based on HyDE! with custom modifications and dotfiles${NC}"
    echo -e "${GN}License: MIT${NC}"
    echo ""
}

#==============================================================================
# MAIN MENU
#==============================================================================
show_main_menu() {
    display_banner
    
    dialog --title " GfDE Installer v1.0" \
           --backtitle "GfDE Desktop Environment Setup" \
           --yesno "Welcome to the GfDE installer!\n\nThis will set up a beautiful desktop environment based on Hyprland.\n\n  WARNING: This will modify your system configuration.\n Please ensure you have backups of important data.\n\n🚀 Ready to start the installation?" 12 70
    
    local response=$?
    if [ $response -eq 0 ]; then
        clear
        display_banner
        show_installer_menu
    else
        log_info "Installation cancelled by user."
        exit 0
    fi
}

#==============================================================================
# INSTALLER MENU
#==============================================================================
show_installer_menu() {
    local tmp_file=$(mktemp)
    
    dialog --title "  GfDE Installer - Component Selection" \
           --backtitle "Choose components to install" \
           --checklist "Select the components you want to install:\n\n  Dependencies will be installed automatically" 20 80 8 \
           1 " Hyprland & Core Dependencies (Required)" on \
           2 " Custom Dotfiles & Configurations" off \
           3 " GTK Themes & Cursor Themes" off \
           4 " Boot Animation (Plymouth)" off \
           5 " Additional Software Bundle" off 2>"$tmp_file"
    
    if [ $? -ne 0 ]; then
        log_info "Installation cancelled by user."
        rm -f "$tmp_file"
        exit 1
    fi
    
    local choices=$(cat "$tmp_file")
    rm -f "$tmp_file"
    
    if [[ -z "$choices" ]]; then
        log_warning "No components selected. Exiting..."
        exit 1
    fi
    
    # Display selected components
    echo -e "\n${BD}${CY}Selected Components:${NC}"
    for choice in $choices; do
        case $choice in
            "\"1\"") echo -e "  ${GN}✓${NC} Hyprland & Core Dependencies" ;;
            "\"2\"") echo -e "  ${GN}✓${NC} Custom Dotfiles & Configurations" ;;
            "\"3\"") echo -e "  ${GN}✓${NC} GTK Themes & Cursor Themes" ;;
            "\"4\"") echo -e "  ${GN}✓${NC} Boot Animation (Plymouth)" ;;
            "\"5\"") echo -e "  ${GN}✓${NC} Additional Software Bundle" ;;
        esac
    done
    
    echo ""
    if ! confirm_action "Proceed with installation?"; then
        log_info "Installation cancelled by user."
        exit 1
    fi
    
    # Execute installations
    for choice in $choices; do
        case $choice in
            "\"1\"") install_base_system ;;
            "\"2\"") install_dotfiles ;;
            "\"3\"") install_themes ;;
            "\"4\"") install_boot_animation ;;
            "\"5\"") install_additional_software ;;
        esac
    done
    
    show_completion_summary
}

#==============================================================================
# BASE SYSTEM INSTALLATION
#==============================================================================
install_base_system() {
    clear
    display_banner
    log_step "Installing Hyprland and core dependencies..."
    
    # Update system first
    log_info "Updating system packages..."
    if ! sudo pacman -Sy; then
        log_error "Failed to update package database!"
        return 1
    fi
    
    # Install git if not present
    log_info "Installing git..."
    if ! sudo pacman -S --needed --noconfirm git; then
        log_error "Failed to install git!"
        return 1
    fi
    
    # Clone HyDE repository
    log_info "Cloning HyDE repository..."
    if [[ -d "HyDE" ]]; then
        log_warning "HyDE directory already exists, removing..."
        rm -rf HyDE
    fi
    
    if ! git clone https://github.com/HyDE-Project/HyDE.git; then
        log_error "Failed to clone HyDE repository!"
        return 1
    fi
    
    # Prepare custom package list
    log_info "Preparing custom package configuration..."
    if [[ -f "assets/pkg_core.lst" ]]; then
        sudo chmod +x HyDE/Scripts/install.sh
        [[ -f "HyDE/Scripts/pkg_core.lst" ]] && rm HyDE/Scripts/pkg_core.lst
        cp assets/pkg_core.lst HyDE/Scripts/
        log_success "Custom package list applied!"
    else
        log_warning "Custom package list not found, using default HyDE packages"
    fi
    
    # Run HyDE installation
    log_info "Running HyDE installation script..."
    log_warning "This may take several minutes depending on your internet connection..."
    
    if bash HyDE/Scripts/install.sh; then
        log_success "Base HyDE installation completed successfully!"
    else
        log_error "HyDE installation failed!"
        return 1
    fi
    
    sleep 2
}

#==============================================================================
# DOTFILES INSTALLATION
#==============================================================================
install_dotfiles() {
    clear
    display_banner
    log_step "Installing custom dotfiles..."
    
    log_warning "Dotfiles installation is coming soon!"
    log_info "This feature will include:"
    echo -e "  ${CY}•${NC} Custom Hyprland configurations"
    echo -e "  ${CY}•${NC} Waybar themes and configs"
    echo -e "  ${CY}•${NC} Terminal configurations"
    echo -e "  ${CY}•${NC} Application-specific settings"
    
    press_any_key
}

#==============================================================================
# THEMES INSTALLATION
#==============================================================================
install_themes() {
    clear
    display_banner
    log_step "Installing GTK and cursor themes..."
    
    log_warning "Theme installation is coming soon!"
    log_info "This feature will include:"
    echo -e "  ${CY}•${NC} Custom GTK themes"
    echo -e "  ${CY}•${NC} Icon packs"
    echo -e "  ${CY}•${NC} Cursor themes"
    echo -e "  ${CY}•${NC} Wallpaper collection"
    
    press_any_key
}

#==============================================================================
# BOOT ANIMATION INSTALLATION
#==============================================================================
install_boot_animation() {
    clear
    display_banner
    log_step "Setting up boot animation (Plymouth)..."
    
    # Check if Plymouth is installed
    if ! pacman -Qi plymouth &> /dev/null; then
        log_info "Installing Plymouth..."
        if ! sudo pacman -S --needed --noconfirm plymouth; then
            log_error "Failed to install Plymouth"
            return 1
        fi
        log_success "Plymouth installed successfully"
    else
        log_info "Plymouth is already installed"
    fi
    
    # Define theme paths
    local theme_source="assets/maclikeboot"
    local theme_dest="/usr/share/plymouth/themes/maclikeboot"
    local theme_name="maclikeboot"
    
    # Check if source theme exists
    if [[ ! -d "$theme_source" ]]; then
        log_error "Theme source directory not found: $theme_source"
        log_warning "Please ensure the theme files are in the correct location"
        return 1
    fi
    
    # Create backup of current configuration
    log_info "Creating backup of current configuration..."
    sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.backup 2>/dev/null || true
    log_success "Configuration backed up"
    
    # Install theme
    log_info "Installing maclikeboot theme..."
    sudo mkdir -p "$(dirname "$theme_dest")"
    sudo cp -r "$theme_source" "$theme_dest"
    sudo chmod -R 755 "$theme_dest"
    sudo chown -R root:root "$theme_dest"
    log_success "Theme files installed"
    
    # Configure mkinitcpio
    log_info "Configuring initramfs..."
    if ! grep -q "plymouth" /etc/mkinitcpio.conf; then
        sudo sed -i '/^HOOKS=/ s/)/ plymouth)/' /etc/mkinitcpio.conf
        log_success "Plymouth hook added to mkinitcpio"
    else
        log_info "Plymouth hook already present in mkinitcpio"
    fi
    
    # Set theme as default
    log_info "Setting maclikeboot as default theme..."
    if sudo plymouth-set-default-theme "$theme_name"; then
        log_success "Theme set successfully"
    else
        log_error "Failed to set theme"
        return 1
    fi
    
    # Configure bootloader
    configure_bootloader
    
    # Enable Plymouth services
    log_info "Enabling Plymouth services..."
    sudo systemctl enable plymouth-start.service 2>/dev/null || true
    sudo systemctl enable plymouth-quit.service 2>/dev/null || true
    log_success "Plymouth services enabled"
    
    # Regenerate initramfs
    log_info "Regenerating initramfs (this may take a moment)..."
    if sudo mkinitcpio -P; then
        log_success "Initramfs regenerated successfully"
    else
        log_error "Failed to regenerate initramfs"
        return 1
    fi
    
    # Verify installation
    verify_boot_animation_install "$theme_dest" "$theme_name"
}

#==============================================================================
# BOOTLOADER CONFIGURATION
#==============================================================================
configure_bootloader() {
    log_info "Detecting and configuring bootloader..."
    local bootloader_configured=false
    
    # GRUB Configuration
    if [[ -f /etc/default/grub ]] && command -v grub-mkconfig &> /dev/null; then
        log_info "GRUB bootloader detected"
        
        # Backup GRUB config
        sudo cp /etc/default/grub /etc/default/grub.backup 2>/dev/null || true
        
        # Configure GRUB parameters
        if ! grep -q "quiet.*splash\|splash.*quiet" /etc/default/grub; then
            sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\([^"]*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 quiet splash"/' /etc/default/grub
            sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="  */GRUB_CMDLINE_LINUX_DEFAULT="/' /etc/default/grub
            log_success "Boot parameters added to GRUB"
        else
            log_info "Boot parameters already configured in GRUB"
        fi
        
        # Update GRUB configuration
        log_info "Updating GRUB configuration..."
        if sudo grub-mkconfig -o /boot/grub/grub.cfg; then
            log_success "GRUB configuration updated"
            bootloader_configured=true
        else
            log_warning "Failed to update GRUB configuration"
        fi
    fi
    
    # systemd-boot Configuration
    if [[ -d /boot/loader ]] && [[ -f /boot/loader/loader.conf ]]; then
        log_info "systemd-boot detected"
        configure_systemd_boot
        bootloader_configured=true
    fi
    
    # rEFInd Configuration
    if [[ -f /boot/EFI/refind/refind.conf ]] || [[ -f /boot/refind_linux.conf ]]; then
        log_info "rEFInd bootloader detected"
        configure_refind
        bootloader_configured=true
    fi
    
    # LILO Configuration (legacy)
    if [[ -f /etc/lilo.conf ]] && command -v lilo &> /dev/null; then
        log_info "LILO bootloader detected"
        configure_lilo
        bootloader_configured=true
    fi
    
    # Summary
    if [[ "$bootloader_configured" == true ]]; then
        log_success "Bootloader configuration completed"
    else
        log_warning "No recognized bootloader found or configuration failed"
        show_manual_bootloader_instructions
    fi
}

configure_systemd_boot() {
    local entries_dir="/boot/loader/entries"
    local entries_found=false
    
    if [[ -d "$entries_dir" ]]; then
        for entry_file in "$entries_dir"/*.conf; do
            if [[ -f "$entry_file" ]]; then
                entries_found=true
                log_info "Updating systemd-boot entry: $(basename "$entry_file")"
                
                # Backup entry file
                sudo cp "$entry_file" "$entry_file.backup" 2>/dev/null || true
                
                # Add boot parameters
                if grep -q "^options" "$entry_file"; then
                    if ! grep -q "quiet.*splash\|splash.*quiet" "$entry_file"; then
                        sudo sed -i '/^options/ s/$/ quiet splash/' "$entry_file"
                        log_success "Boot parameters added to $(basename "$entry_file")"
                    else
                        log_info "Boot parameters already present in $(basename "$entry_file")"
                    fi
                else
                    log_warning "No options line found in $(basename "$entry_file")"
                fi
            fi
        done
        
        if [[ "$entries_found" == true ]]; then
            log_success "systemd-boot entries updated"
        fi
    fi
}

configure_refind() {
    local refind_linux_conf="/boot/refind_linux.conf"
    if [[ -f "$refind_linux_conf" ]]; then
        sudo cp "$refind_linux_conf" "$refind_linux_conf.backup" 2>/dev/null || true
        
        if ! grep -q "quiet.*splash\|splash.*quiet" "$refind_linux_conf"; then
            sudo sed -i 's/"$/ quiet splash"/' "$refind_linux_conf"
            log_success "Boot parameters added to rEFInd"
        else
            log_info "Boot parameters already configured in rEFInd"
        fi
    else
        log_warning "rEFInd detected but refind_linux.conf not found"
    fi
}

configure_lilo() {
    sudo cp /etc/lilo.conf /etc/lilo.conf.backup 2>/dev/null || true
    
    if grep -q "append=" /etc/lilo.conf; then
        if ! grep -q "quiet.*splash\|splash.*quiet" /etc/lilo.conf; then
            sudo sed -i '/append=/ s/"$/ quiet splash"/' /etc/lilo.conf
            log_success "Boot parameters added to LILO"
        else
            log_info "Boot parameters already configured in LILO"
        fi
    else
        sudo sed -i '/^[[:space:]]*linux/ a\    append="quiet splash"' /etc/lilo.conf
        log_success "Append line with boot parameters added to LILO"
    fi
    
    if sudo lilo; then
        log_success "LILO configuration updated"
    else
        log_warning "Failed to update LILO"
    fi
}

show_manual_bootloader_instructions() {
    log_warning "Manual bootloader configuration required!"
    echo -e "\n${BD}${YW}Please manually add 'quiet splash' to your boot parameters:${NC}"
    echo -e "  ${CY}•${NC} GRUB: /etc/default/grub (GRUB_CMDLINE_LINUX_DEFAULT)"
    echo -e "  ${CY}•${NC} systemd-boot: /boot/loader/entries/*.conf (options line)"
    echo -e "  ${CY}•${NC} rEFInd: /boot/refind_linux.conf"
    echo -e "  ${CY}•${NC} EFISTUB: Add to EFI boot entry parameters"
}

verify_boot_animation_install() {
    local theme_dest=$1
    local theme_name=$2
    
    log_info "Verifying installation..."
    
    if [[ -d "$theme_dest" ]] && plymouth-set-default-theme -l | grep -q "$theme_name"; then
        log_success "✓ Theme installed and configured successfully"
        log_success "✓ Boot animation will be active after reboot"
        
        local current_theme=$(plymouth-set-default-theme)
        log_info "Current theme: $current_theme"
        
        echo -e "\n${BD}${GN}Boot Animation Setup Complete!${NC}"
        echo -e "${YW}Note: Reboot required to see the boot animation${NC}"
        return 0
    else
        log_error "Installation verification failed"
        return 1
    fi
}

#==============================================================================
# ADDITIONAL SOFTWARE INSTALLATION
#==============================================================================
install_additional_software() {
    clear
    display_banner
    log_step "Installing additional software bundle..."
    
    # Install Zen Browser via Flatpak
    log_info "Installing Zen Browser..."
    if command -v flatpak &> /dev/null; then
        if flatpak install -y flathub app.zen_browser.zen; then
            log_success "Zen Browser installed successfully"
        else
            log_warning "Failed to install Zen Browser"
        fi
    else
        log_warning "Flatpak not found, skipping Zen Browser installation"
    fi
    
    # Install Visual Studio Code via AUR
    log_info "Installing Visual Studio Code..."
    if command -v yay &> /dev/null; then
        if yay -S --noconfirm visual-studio-code-bin; then
            log_success "Visual Studio Code installed successfully"
        else
            log_warning "Failed to install Visual Studio Code"
        fi
    else
        log_warning "YAY AUR helper not found, skipping VS Code installation"
        log_info "Please install an AUR helper to install AUR packages"
    fi
    
    log_success "Additional software installation completed"
    sleep 2
}

#==============================================================================
# COMPLETION SUMMARY
#==============================================================================
show_completion_summary() {
    clear
    display_banner
    
    echo -e "${BD}${GN} Installation Complete! ${NC}\n"
    
    echo -e "${BD}${CY}What's Next:${NC}"
    echo -e "  ${GN}•${NC} Reboot your system to apply all changes"
    echo -e "  ${GN}•${NC} Log in and select Hyprland from your display manager"
    echo -e "  ${GN}•${NC} Enjoy your new desktop environment!"
    
    echo -e "\n${BD}${YW}Important Notes:${NC}"
    echo -e "  ${YW}•${NC} Configuration files are backed up with .backup extension"
    echo -e "  ${YW}•${NC} Check logs if any component didn't install correctly"
    echo -e "  ${YW}•${NC} Visit the GitHub repository for documentation and support"
    
    echo -e "\n${BD}${MG}Support:${NC}"
    echo -e "  ${CY}•${NC} GitHub: https://github.com/g-flame"
    echo -e "  ${CY}•${NC} HyDE Project: https://github.com/HyDE-Project/HyDE"
    
    echo ""
    if confirm_action "Would you like to reboot now?"; then
        log_info "Rebooting system in 5 seconds..."
        sleep 5
        sudo reboot
    else
        log_info "Remember to reboot when ready!"
    fi
}

#==============================================================================
# CLEANUP AND ERROR HANDLING
#==============================================================================
cleanup_on_exit() {
    log_info "Cleaning up temporary files..."
    tput rmcup 2>/dev/null || true
    exit 0
}

handle_error() {
    log_error "An unexpected error occurred!"
    log_info "Check the error messages above for details"
    cleanup_on_exit
}

#==============================================================================
# SIGNAL HANDLERS
#==============================================================================
trap cleanup_on_exit SIGINT SIGTERM
trap handle_error ERR

#==============================================================================
# MAIN EXECUTION
#==============================================================================
main() {
    # Initial system setup
    log_info "Updating package database..."
    sudo pacman -Sy
    
    log_info "Installing required dependencies..."
    sudo pacman -S --needed --noconfirm dialog
    
    # Initialize screen
    tput smcup
    clear
    
    # Start main flow
    show_main_menu
    
    # Simulate final processing (if needed)
    echo -e "\n${CY}Finalizing installation...${NC}"
    for i in {1..10}; do
        show_progress $i 10 "Completing setup"
        sleep 0.5
    done
    echo ""
    
    cleanup_on_exit
}

#==============================================================================
# SCRIPT ENTRY POINT
#==============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi