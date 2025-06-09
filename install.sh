#!/usr/bin/env bash
#==============================================================================
# GfDE Installer
# Version: 0.1
# Author: g-flame (https://github.com/g-flame)
# Based on HyDE! with custom modifications
# License: MIT
# Yeah, this is basically HyDE but with my own twist on it
# Don't judge me, I like pretty desktops and smooth boot animations
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
# COLORS (because life's too short for boring terminals)
#==============================================================================
readonly RED='\033[00;31m'
readonly GREEN='\033[00;32m'
readonly YELLOW='\033[00;33m'
readonly BLUE='\033[00;34m'
readonly PURPLE='\033[00;35m'
readonly CYAN='\033[00;36m'
readonly WHITE='\033[01;37m'
readonly RESET='\033[00;37m'
readonly BOLD='\033[1m'
readonly UNDERLINE='\033[4m'
#==============================================================================
# LOGGING (with personality!)
#==============================================================================
say_info() {
    echo -e "${CYAN}[INFO]${RESET} $1"
}

celebrate() {
    echo -e "${GREEN}[SUCCESS]${RESET} $1"
}

warn_user() {
    echo -e "${YELLOW}[HEADS UP!]${RESET} $1"
}

oh_no() {
    echo -e "${RED}[OOPS]${RESET} $1"
}

next_step() {
    echo -e "${BLUE}[DOING]${RESET} $1"
}

#==============================================================================
# UTILITY FUNCTIONS (the helpful stuff)
#==============================================================================
show_progress() {
    local current=$1
    local total=$2
    local message=$3
    local percent=$((current * 100 / total))
    local bar_length=30
    local filled_length=$((percent * bar_length / 100))
    
    printf "\r${CYAN}[$message]${RESET} ["
    printf "%*s" $filled_length | tr ' ' '█'
    printf "%*s" $((bar_length - filled_length)) | tr ' ' '░'
    printf "] %d%% (%d/%d)" $percent $current $total
}

wait_for_user() {
    echo -e "\n${YELLOW}Hit any key when you're ready...${RESET}"
    read -n 1 -s
}

ask_user() {
    local message=$1
    echo -e "${YELLOW}$message (y/N): ${RESET}"
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

#==============================================================================
# BANNER (gotta look cool, right?)
#==============================================================================
show_banner() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "  ╔════════════════════════════════════════════════════════════════╗"
    echo "  ║                                                                ║"
    echo "  ║     ___  ____  ____   ____                                     ║"
    echo "  ║    / __)(  __)(    \ (  __)                                    ║"
    echo "  ║   ( (__\\ ) _)  ) D ( ) _)                                      ║"
    echo -e "  ║    \\___/(__)  (____/(____) ${GREEN}Desktop Environment${PURPLE}                 ║"
    echo "  ║                                                                ║"
    echo "  ╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e "${CYAN}${BOLD}Made by g-flame with some caffeine and determination${RESET}"
    echo -e "${WHITE}Based on HyDE but with my own flavor${RESET}"
    echo -e "${GREEN}License: MIT (because sharing is caring)${RESET}"
    echo ""
}

#==============================================================================
# MAIN MENU (where the magic begins)
#==============================================================================
show_welcome() {
    show_banner
    
    dialog --title " Welcome to GfDE! 🚀" \
           --backtitle "Let's make your desktop beautiful" \
           --yesno "Hey there! Welcome to my little desktop environment project.\n\nThis is going to set up a pretty sweet Hyprland-based desktop with some custom touches I've been working on.\n\n⚠️  Fair warning: This will mess with your system config.\nMake sure you've got backups of anything important!\n\nReady to dive in?" 14 70
    
    local response=$?
    if [ $response -eq 0 ]; then
        clear
        show_banner
        show_installer_options
    else
        say_info "No worries! Maybe next time. 👋"
        exit 0
    fi
}

#==============================================================================
# INSTALLER OPTIONS (pick your poison)
#==============================================================================
show_installer_options() {
    local tmp_file=$(mktemp)
    
    dialog --title "  What do you want to install?" \
           --backtitle "Pick what sounds good to you" \
           --checklist "Alright, here's what I've got for you:\n\n(Don't worry, I'll handle the dependencies)" 16 80 3 \
           1 " The Core Stuff (Hyprland + essentials) - You need this!" on \
           2 " Full GfDE Experience (Desktop + Boot animation)" off \
           3 " Extra Apps (Because who doesn't like more software?)" off 2>"$tmp_file"
    
    if [ $? -ne 0 ]; then
        say_info "Changed your mind? That's cool. See ya! 👋"
        rm -f "$tmp_file"
        exit 1
    fi
    
    local choices=$(cat "$tmp_file")
    rm -f "$tmp_file"
    
    if [[ -z "$choices" ]]; then
        warn_user "You didn't pick anything. Can't install nothing! 🤷‍♂️"
        exit 1
    fi
    
    # Show what they picked
    echo -e "\n${BOLD}${CYAN}Alright, here's what we're doing:${RESET}"
    for choice in $choices; do
        case $choice in
            1) echo -e "  ${GREEN}✓${RESET} Core Hyprland setup" ;;
            2) echo -e "  ${GREEN}✓${RESET} Full GfDE experience with boot animation" ;;
            3) echo -e "  ${GREEN}✓${RESET} Extra applications" ;;
        esac
    done
    
    echo ""
    if ! ask_user "Look good? Let's do this thing!"; then
        say_info "Alright, maybe later then!"
        exit 1
    fi
    
    # Do the installations
    for choice in $choices; do
        case $choice in
            1) install_the_basics ;;
            2) install_full_gfde ;;
            3) pick_extra_apps ;;
        esac
    done
    
    wrap_it_up
}

#==============================================================================
# BASIC INSTALLATION (the foundation)
#==============================================================================
install_the_basics() {
    clear
    show_banner
    next_step "Setting up the basic Hyprland stuff..."
    
    # Get HyDE
    say_info "Grabbing the HyDE project..."
    if [[ -d "HyDE" ]]; then
        warn_user "Found an old HyDE folder, cleaning it up..."
        rm -rf HyDE
    fi
    
    if ! git clone https://github.com/HyDE-Project/HyDE.git; then
        oh_no "Couldn't clone HyDE. Check your internet?"
        return 1
    fi
    
    # Apply my custom package list if it exists
    say_info "Checking for my custom package tweaks..."
    if [[ -f "assets/pkg_core.lst" ]]; then
        sudo chmod +x HyDE/Scripts/install.sh
        [[ -f "HyDE/Scripts/pkg_core.lst" ]] && rm HyDE/Scripts/pkg_core.lst
        cp assets/pkg_core.lst HyDE/Scripts/
        celebrate "Applied my custom package list!"
    else
        warn_user "No custom packages found, using HyDE defaults"
    fi
    
    # Run the HyDE installer
    say_info "Running the HyDE installer... (grab some coffee, this takes a while)"
    warn_user "Seriously, go make coffee. This isn't quick."
    
    if bash HyDE/Scripts/install.sh; then
        celebrate "HyDE is installed! We're getting somewhere! 🎉"
    else
        oh_no "HyDE installation failed. That's unfortunate."
        return 1
    fi
    
    sleep 2
}

#==============================================================================
# FULL GFDE INSTALLATION (the whole shebang)
#==============================================================================
install_full_gfde() {
    clear
    show_banner
    next_step "Installing the full GfDE experience..."
    
    # Boot animation first
    setup_boot_animation
    
    # Then desktop environment
    setup_desktop_environment
}

#==============================================================================
# BOOT ANIMATION SETUP (because booting should be pretty)
#==============================================================================
setup_boot_animation() {
    next_step "Setting up that sweet boot animation..."
    
    # Check for Plymouth
    if ! pacman -Qi plymouth &> /dev/null; then
        say_info "Installing Plymouth (for the boot animation)..."
        if ! sudo pacman -S --needed --noconfirm plymouth; then
            oh_no "Plymouth installation failed"
            return 1
        fi
        celebrate "Plymouth is ready to go!"
    else
        say_info "Plymouth is already here, nice!"
    fi
    
    # Theme setup
    local theme_source="assets/gfde-boot-theme"
    local theme_dest="/usr/share/plymouth/themes/gfde"
    local theme_name="gfde"
    
    # Check if we have the theme files
    if [[ ! -d "$theme_source" ]]; then
        oh_no "Can't find the GfDE theme files at: $theme_source"
        warn_user "Make sure the theme files are in the right place!"
        return 1
    fi
    
    # Backup current config
    say_info "Backing up your current config (just in case)..."
    sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.backup 2>/dev/null || true
    celebrate "Config backed up safely"
    
    # Install the theme
    say_info "Installing the GfDE boot theme..."
    sudo mkdir -p "$(dirname "$theme_dest")"
    sudo cp -r "$theme_source" "$theme_dest"
    sudo chmod -R 755 "$theme_dest"
    sudo chown -R root:root "$theme_dest"
    celebrate "Theme files are in place!"
    
    # Configure mkinitcpio
    say_info "Configuring the initramfs..."
    if ! grep -q "plymouth" /etc/mkinitcpio.conf; then
        sudo sed -i '/^HOOKS=/ s/)/ plymouth)/' /etc/mkinitcpio.conf
        celebrate "Plymouth hook added"
    else
        say_info "Plymouth hook was already there"
    fi
    
    # Set as default theme
    say_info "Making GfDE the default boot theme..."
    if sudo plymouth-set-default-theme "$theme_name"; then
        celebrate "GfDE theme is now active!"
    else
        oh_no "Couldn't set the GfDE theme"
        return 1
    fi
    
    # Configure bootloader
    setup_bootloader
    
    # Enable services
    say_info "Enabling Plymouth services..."
    sudo systemctl enable plymouth-start.service 2>/dev/null || true
    sudo systemctl enable plymouth-quit.service 2>/dev/null || true
    celebrate "Services are enabled"
    
    # Rebuild initramfs
    say_info "Rebuilding initramfs (this might take a moment)..."
    if sudo mkinitcpio -P; then
        celebrate "Initramfs rebuilt successfully!"
    else
        oh_no "Failed to rebuild initramfs"
        return 1
    fi
    
    # Check if everything worked
    check_boot_install "$theme_dest" "$theme_name"
}

#==============================================================================
# DESKTOP ENVIRONMENT SETUP (the main course)
#==============================================================================
setup_desktop_environment() {
    next_step "Setting up the GfDE desktop environment..."
    chmod +x assets/GfDE.sh
    bash GfDE.sh
    celebrate "GfDE desktop environment is ready! 🎨"
}

#==============================================================================
# BOOTLOADER SETUP (making sure everything boots pretty)
#==============================================================================
setup_bootloader() {
    say_info "Finding and configuring your bootloader..."
    local configured=false
    
    # GRUB (most common)
    if [[ -f /etc/default/grub ]] && command -v grub-mkconfig &> /dev/null; then
        say_info "Found GRUB! Let's configure it..."
        
        # Backup first
        sudo cp /etc/default/grub /etc/default/grub.backup 2>/dev/null || true
        
        # Add boot parameters
        if ! grep -q "quiet.*splash\|splash.*quiet" /etc/default/grub; then
            sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\([^"]*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 quiet splash"/' /etc/default/grub
            sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="  */GRUB_CMDLINE_LINUX_DEFAULT="/' /etc/default/grub
            celebrate "Added boot parameters to GRUB"
        else
            say_info "GRUB already has the right parameters"
        fi
        
        # Update GRUB
        say_info "Updating GRUB configuration..."
        if sudo grub-mkconfig -o /boot/grub/grub.cfg; then
            celebrate "GRUB is all set!"
            configured=true
        else
            warn_user "GRUB update didn't work perfectly"
        fi
    fi
    
    # systemd-boot
    if [[ -d /boot/loader ]] && [[ -f /boot/loader/loader.conf ]]; then
        say_info "Found systemd-boot!"
        configure_systemd_boot
        configured=true
    fi
    
    # rEFInd
    if [[ -f /boot/EFI/refind/refind.conf ]] || [[ -f /boot/refind_linux.conf ]]; then
        say_info "Found rEFInd bootloader"
        configure_refind
        configured=true
    fi
    
    # LILO (old school)
    if [[ -f /etc/lilo.conf ]] && command -v lilo &> /dev/null; then
        say_info "Found LILO (retro!)"
        configure_lilo
        configured=true
    fi
    
    # Summary
    if [[ "$configured" == true ]]; then
        celebrate "Bootloader is configured!"
    else
        warn_user "Couldn't find or configure your bootloader automatically"
        show_manual_bootloader_help
    fi
}

configure_systemd_boot() {
    local entries_dir="/boot/loader/entries"
    local found_entries=false
    
    if [[ -d "$entries_dir" ]]; then
        for entry_file in "$entries_dir"/*.conf; do
            if [[ -f "$entry_file" ]]; then
                found_entries=true
                say_info "Updating systemd-boot entry: $(basename "$entry_file")"
                
                # Backup
                sudo cp "$entry_file" "$entry_file.backup" 2>/dev/null || true
                
                # Add parameters
                if grep -q "^options" "$entry_file"; then
                    if ! grep -q "quiet.*splash\|splash.*quiet" "$entry_file"; then
                        sudo sed -i '/^options/ s/$/ quiet splash/' "$entry_file"
                        celebrate "Updated $(basename "$entry_file")"
                    else
                        say_info "$(basename "$entry_file") already had the right parameters"
                    fi
                else
                    warn_user "No options line found in $(basename "$entry_file")"
                fi
            fi
        done
        
        if [[ "$found_entries" == true ]]; then
            celebrate "systemd-boot entries updated!"
        fi
    fi
}

configure_refind() {
    local refind_linux_conf="/boot/refind_linux.conf"
    if [[ -f "$refind_linux_conf" ]]; then
        sudo cp "$refind_linux_conf" "$refind_linux_conf.backup" 2>/dev/null || true
        
        if ! grep -q "quiet.*splash\|splash.*quiet" "$refind_linux_conf"; then
            sudo sed -i 's/"$/ quiet splash"/' "$refind_linux_conf"
            celebrate "rEFInd parameters added!"
        else
            say_info "rEFInd already configured"
        fi
    else
        warn_user "Found rEFInd but couldn't find refind_linux.conf"
    fi
}

configure_lilo() {
    sudo cp /etc/lilo.conf /etc/lilo.conf.backup 2>/dev/null || true
    
    if grep -q "append=" /etc/lilo.conf; then
        if ! grep -q "quiet.*splash\|splash.*quiet" /etc/lilo.conf; then
            sudo sed -i '/append=/ s/"$/ quiet splash"/' /etc/lilo.conf
            celebrate "LILO parameters added!"
        else
            say_info "LILO already configured"
        fi
    else
        sudo sed -i '/^[[:space:]]*linux/ a\    append="quiet splash"' /etc/lilo.conf
        celebrate "Added append line to LILO"
    fi
    
    if sudo lilo; then
        celebrate "LILO configuration updated!"
    else
        warn_user "LILO update didn't work perfectly"
    fi
}

show_manual_bootloader_help() {
    warn_user "You'll need to manually add boot parameters!"
    echo -e "\n${BOLD}${YELLOW}Here's what you need to do:${RESET}"
    echo -e "Add 'quiet splash' to your boot parameters in:"
    echo -e "  ${CYAN}•${RESET} GRUB: /etc/default/grub (GRUB_CMDLINE_LINUX_DEFAULT line)"
    echo -e "  ${CYAN}•${RESET} systemd-boot: /boot/loader/entries/*.conf (options line)"
    echo -e "  ${CYAN}•${RESET} rEFInd: /boot/refind_linux.conf"
    echo -e "  ${CYAN}•${RESET} EFISTUB: Add to your EFI boot entry"
    echo -e "\nDon't worry, it's not too scary! 😊"
}

check_boot_install() {
    local theme_dest=$1
    local theme_name=$2
    
    say_info "Checking if everything worked..."
    
    if [[ -d "$theme_dest" ]] && plymouth-set-default-theme -l | grep -q "$theme_name"; then
        celebrate "GfDE boot theme is installed and ready!"
        celebrate "You'll see the boot animation after you reboot! 🚀"
        
        local current_theme=$(plymouth-set-default-theme)
        say_info "Current theme: $current_theme"
        
        echo -e "\n${BOLD}${GREEN}Boot Animation Setup Complete! 🎉${RESET}"
        echo -e "${YELLOW}Just reboot to see it in action!${RESET}"
        return 0
    else
        oh_no "Something went wrong with the installation"
        return 1
    fi
}

#==============================================================================
# EXTRA APPS (because we all love software)
#==============================================================================
pick_extra_apps() {
    clear
    show_banner
    next_step "Time to pick some extra apps..."
    
    local tmp_file=$(mktemp)
    
    dialog --title " What apps do you want? 📱" \
           --backtitle "Pick whatever sounds good" \
           --checklist "Here's what I've got available:\n\n(Use SPACE to select, ENTER when done)" 20 80 12 \
           1 " Firefox (because browsing)" off \
           2 " Zen Browser (fancy Firefox alternative)" off \
           3 " VS Code (for all the coding)" off \
           4 " Discord (gotta stay connected)" off \
           5 " Spotify (music = productivity)" off \
           6 " GIMP (photo editing)" off \
           7 " LibreOffice (office stuff)" off \
           8 " VLC (plays everything)" off \
           9 " Blender (3D magic)" off \
           10 " Steam (gaming time!)" off \
           11 " OBS Studio (streaming/recording)" off \
           12 " Docker (containers everywhere)" off 2>"$tmp_file"
    
    if [ $? -ne 0 ]; then
        say_info "No extra apps? That's fine too!"
        rm -f "$tmp_file"
        return
    fi
    
    local choices=$(cat "$tmp_file")
    rm -f "$tmp_file"
    
    if [[ -z "$choices" ]]; then
        warn_user "No apps selected. Moving on..."
        return
    fi
    
    # Show what they picked
    echo -e "\n${BOLD}${CYAN}Cool, installing these apps:${RESET}"
    for choice in $choices; do
        case $choice in
            1) echo -e "  ${GREEN}✓${RESET} Firefox" ;;
            2) echo -e "  ${GREEN}✓${RESET} Zen Browser" ;;
            3) echo -e "  ${GREEN}✓${RESET} VS Code" ;;
            4) echo -e "  ${GREEN}✓${RESET} Discord" ;;
            5) echo -e "  ${GREEN}✓${RESET} Spotify" ;;
            6) echo -e "  ${GREEN}✓${RESET} GIMP" ;;
            7) echo -e "  ${GREEN}✓${RESET} LibreOffice" ;;
            8) echo -e "  ${GREEN}✓${RESET} VLC" ;;
            9) echo -e "  ${GREEN}✓${RESET} Blender" ;;
            10) echo -e "  ${GREEN}✓${RESET} Steam" ;;
            11) echo -e "  ${GREEN}✓${RESET} OBS Studio" ;;
            12) echo -e "  ${GREEN}✓${RESET} Docker" ;;
        esac
    done
    clear
    echo ""
    if ! ask_user "Look good? Let's install these!"; then
        say_info "Changed your mind? No problem!"
        return
    fi
    
    # Install everything
    install_chosen_apps "$choices"
}

#==============================================================================
# APP INSTALLATION (the actual installing)
#==============================================================================
install_chosen_apps() {
    local choices=$1
    
    clear
    show_banner
    next_step "Installing your chosen apps..."
    
    # Make sure we have yay
    if ! command -v yay &> /dev/null; then
        say_info "Installing yay (AUR helper)..."
        install_yay_helper
    fi
    
    # Make sure we have flatpak
    if ! command -v flatpak &> /dev/null; then
        say_info "Installing Flatpak..."
        sudo pacman -S --needed --noconfirm flatpak
        sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    fi
    
    # Install each app
    for choice in $choices; do
        case $choice in
            1) install_firefox ;;
            2) install_zen_browser ;;
            3) install_vscode ;;
            4) install_discord ;;
            5) install_spotify ;;
            6) install_gimp ;;
            7) install_libreoffice ;;
            8) install_vlc ;;
            9) install_blender ;;
            10) install_steam ;;
            11) install_obs ;;
            12) install_docker ;;
        esac
    done
    
    celebrate "All apps installed! 🎉"
    sleep 2
}

install_yay_helper() {
    if ! command -v git &> /dev/null; then
        sudo pacman -S --needed --noconfirm git
    fi
    
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
}

install_firefox() {
    say_info "Installing Firefox..."
    if sudo pacman -S --needed --noconfirm firefox; then
        celebrate "Firefox is ready!"
    else
        oh_no "Firefox installation failed"
    fi
}

install_zen_browser() {
    say_info "Installing Zen Browser..."
    if flatpak install -y flathub io.github.zen_browser.zen; then
        celebrate "Zen Browser installed!"
    else
        oh_no "Zen Browser installation failed"
    fi
}

install_vscode() {
    say_info "Installing VS Code..."
    if yay -S --noconfirm visual-studio-code-bin; then
        celebrate "VS Code is ready for coding!"
    else
        oh_no "VS Code installation failed"
    fi
}

install_discord() {
    say_info "Installing Discord..."
    if sudo pacman -S --needed --noconfirm discord; then
        celebrate "Discord is ready for chatting!"
    else
        oh_no "Discord installation failed"
    fi
}

install_spotify() {
    say_info "Installing Spotify..."
    if yay -S --noconfirm spotify; then
        celebrate "Spotify is ready for tunes!"
    else
        oh_no "Spotify installation failed"
    fi
}

install_gimp() {
    say_info "Installing GIMP..."
    if sudo pacman -S --needed --noconfirm gimp; then
        celebrate "GIMP is ready for photo editing!"
    else
        oh_no "GIMP installation failed"
    fi
}

install_libreoffice() {
    say_info "Installing LibreOffice..."
    if sudo pacman -S --needed --noconfirm libreoffice-fresh; then
        celebrate "LibreOffice is ready for documents!"
    else
        oh_no "LibreOffice installation failed"
    fi
}

install_vlc() {
    say_info "Installing VLC..."
    if sudo pacman -S --needed --noconfirm vlc; then
        celebrate "VLC is ready to play anything!"
    else
        oh_no "VLC installation failed"
    fi
}

install_blender() {
    say_info "Installing Blender..."
    if sudo pacman -S --needed --noconfirm blender; then
        celebrate "Blender is ready for 3D magic!"
    else
        oh_no "Blender installation failed"
    fi
}

install_steam() {
    say_info "Installing Steam..."
    if sudo pacman -S --needed --noconfirm steam; then
        celebrate "Steam is ready for gaming!"
    else
        oh_no "Steam installation failed"
    fi
}

install_obs() {
    say_info "Installing OBS Studio..."
    if sudo pacman -S --needed --noconfirm obs-studio; then
        celebrate "OBS is ready for streaming!"
    else
        oh_no "OBS installation failed"
    fi
}

install_docker() {
    say_info "Installing Docker..."
    if sudo pacman -S --needed --noconfirm docker docker-compose; then
        sudo systemctl enable docker
        sudo usermod -aG docker $USER
        celebrate "Docker is ready for containers!"
        say_info "You might need to log out and back in for Docker permissions"
    else
        oh_no "Docker installation failed"
    fi
}

#==============================================================================
# FINALE (wrapping it all up)
#==============================================================================
wrap_it_up() {
    clear
    show_banner
    
    echo -e "${BOLD}${GREEN}🎉 We're all done! 🎉${RESET}\n"
    
    echo -e "${BOLD}${CYAN}What's next:${RESET}"
    echo -e "  ${GREEN}•${RESET} Reboot your system (seriously, do it)"
    echo -e "  ${GREEN}•${RESET} Log in and pick Hyprland from your login screen"
    echo -e "  ${GREEN}•${RESET} Enjoy your beautiful new desktop!"
    
    echo -e "\n${BOLD}${YELLOW}Just so you know:${RESET}"
    echo -e "  ${YELLOW}•${RESET} I backed up your configs (they have .backup extensions)"
    echo -e "  ${YELLOW}•${RESET} If something broke, check the error messages above"
    echo -e "  ${YELLOW}•${RESET} Hit me up on GitHub if you need help"
    
    echo -e "\n${BOLD}${PURPLE}Links and stuff:${RESET}"
    echo -e "  ${CYAN}•${RESET} My GitHub: https://github.com/g-flame"
    echo -e "  ${CYAN}•${RESET} HyDE Project: https://github.com/HyDE-Project/HyDE"
    echo -e "  ${CYAN}•${RESET} Issues? Open a GitHub issue, I'll try to help!"
    
    echo ""
    if ask_user "Want to reboot now? (Recommended!)"; then
        say_info "Rebooting in 5 seconds... see you on the other side! 🚀"
        sleep 5
        sudo reboot
    else
        say_info "Don't forget to reboot when you're ready! 😊"
        echo -e "${YELLOW}Seriously though, reboot to see the boot animation!${RESET}"
    fi
}
#==============================================================================
# CLEANUP AND ERROR HANDLING
#==============================================================================
cleanup_on_exit() {
    say_info "Cleaning up temporary files..."
    
    # Restore terminal state
    tput rmcup 2>/dev/null || true
    tput cnorm 2>/dev/null || true
    
    # Clean up any temporary files
    if [[ -n "${TEMP_FILES:-}" ]]; then
        for temp_file in $TEMP_FILES; do
            [[ -f "$temp_file" ]] && rm -f "$temp_file" 2>/dev/null || true
        done
    fi
    
    say_info "Thanks for trying GfDE! 👋"
    exit 0
}

handle_error() {
    local exit_code=$?
    local line_number=${1:-"unknown"}
    
    # Restore terminal
    tput rmcup 2>/dev/null || true
    tput cnorm 2>/dev/null || true
    
    oh_no "An unexpected error occurred! (Exit code: $exit_code)"
    warn_user "Check the error messages above for details"
    
    echo -e "\n${YELLOW}If this keeps happening:${RESET}"
    echo -e "  ${CYAN}•${RESET} Make sure you have a stable internet connection"
    echo -e "  ${CYAN}•${RESET} Try running the script again"
    echo -e "  ${CYAN}•${RESET} Open an issue on GitHub if the problem persists"
    
    cleanup_on_exit
}

#==============================================================================
# SIGNAL HANDLERS
#==============================================================================
trap cleanup_on_exit SIGINT SIGTERM
trap 'handle_error $LINENO' ERR

#==============================================================================
# MAIN EXECUTION
#==============================================================================
main() { 
    #Initialize screen
    tput smcup 2>/dev/null || true
    clear
    
    # Initial system setup
    say_info "Updating package database..."
    if ! sudo pacman -Sy; then
        warn_user "Package database update failed, but continuing anyway..."
    fi
    
    say_info "Installing required dependencies..."
    if ! sudo pacman -S --needed --noconfirm dialog; then
        oh_no "Failed to install dialog - this is required for the installer"
        exit 1
    fi
    
    # Start main flow
    show_welcome 

    # Simulate final processing (if needed)
    echo -e "\n${CYAN}Finalizing installation...${RESET}"
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
