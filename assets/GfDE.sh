#!/bin/bash
#==============================================================================
# GfDE Theme Setup Script
# Version: 0.8(alpha)
# Author: g-flame (https://github.com/g-flame)
# License: MIT
#==============================================================================
##########################################################################################
#       Theme Setup by G-flame @ https://github.com/g-flame                              
#       Graphite Theme by vinceliuice @ https://github.com/vinceliuice                   
#       Tela Circle Icons by vinceliuice @ https://github.com/vinceliuice                
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
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'
RESET='\033[0m'

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
    echo "  ║                Theme Setup                                     ║"
    echo "  ║                                                                ║"
    echo "  ╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e "${CYAN}${BOLD}Made by g-flame ${RESET}"
    echo -e "${GREEN}License: MIT${RESET}"
    echo ""
}

# Check if git is installed
check_dependencies() {
    echo -e "${BLUE}Checking dependencies...${NC}"
    
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Git is not installed. Please install git first.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Dependencies check passed${NC}"
}

# Setup directory structure
setup_directories() {
    echo -e "${BLUE}Setting up directories...${NC}"
    
    cd ~/
    mkdir -p Downloads
    cd Downloads
    
    # Clean up any existing directories
    if [[ -d "Graphite-gtk-theme" ]]; then
        echo -e "${YELLOW}Removing existing Graphite theme directory...${NC}"
        rm -rf Graphite-gtk-theme
    fi
    
    if [[ -d "Tela-circle-icon-theme" ]]; then
        echo -e "${YELLOW}Removing existing Tela icon theme directory...${NC}"
        rm -rf Tela-circle-icon-theme
    fi
    
    echo -e "${GREEN}Directory setup complete${NC}"
}

# Install Graphite GTK theme
install_graphite_theme() {
    echo -e "${BLUE}Installing Graphite GTK theme...${NC}"
    
    cd ~/Downloads
    
    echo -e "${YELLOW}Cloning Graphite GTK theme repository...${NC}"
    git clone https://github.com/vinceliuice/Graphite-gtk-theme.git
    
    cd Graphite-gtk-theme
    
    echo -e "${YELLOW}Making install script executable...${NC}"
    chmod +x install.sh
    
    echo -e "${YELLOW}Installing Graphite theme with dark tweaks...${NC}"
    ./install.sh --tweaks dark
    
    echo -e "${YELLOW}Installing Graphite theme with green variant...${NC}"
    ./install.sh -t green
    
    echo -e "${YELLOW}Installing Graphite theme with GNOME Shell theme...${NC}"
    ./install.sh -g
    
    echo -e "${GREEN}Graphite GTK theme installation complete${NC}"
}

# Install Tela Circle icon theme
install_tela_icons() {
    echo -e "${BLUE}Installing Tela Circle icon theme...${NC}"
    
    cd ~/Downloads
    
    echo -e "${YELLOW}Cloning Tela Circle icon theme repository...${NC}"
    git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git
    
    cd Tela-circle-icon-theme
    
    echo -e "${YELLOW}Making install script executable...${NC}"
    chmod +x install.sh
    
    echo -e "${YELLOW}Installing Tela Circle icons with green variant...${NC}"
    ./install.sh -c green
    
    echo -e "${GREEN}Tela Circle icon theme installation complete${NC}"
}


# Cleanup temporary files
cleanup() {
    echo -e "${BLUE}Cleaning up...${NC}"
    
    cd ~/
    
    # Optional: Remove downloaded repositories to save space
    read -p "Remove downloaded theme repositories to save space? (y/n): " cleanup_choice
    if [[ $cleanup_choice =~ ^[Yy]$ ]]; then
        rm -rf ~/Downloads/Graphite-gtk-theme
        rm -rf ~/Downloads/Tela-circle-icon-theme
        echo -e "${GREEN}Cleanup complete${NC}"
    else
        echo -e "${YELLOW}Keeping downloaded repositories${NC}"
    fi
}

# Main installation function
install_themes() {
    show_banner
    
    echo -e "${CYAN}Starting GfDE theme installation...${NC}"
    echo
    
    check_dependencies
    setup_directories
    install_graphite_theme
    install_tela_icons
    cleanup
    
    echo
    echo -e "${GREEN}${BOLD}Base setup is complete!${NC}"
    echo -e "${YELLOW}Follow the complete guide at: ${CYAN}https://github.com/g-flame-oss/GfDE/blob/main/README.md${NC}"
}

# Main function
main() {
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Please run this script as root${NC}"
        exit 1
    fi

    install_themes
}

# Run main function
main "$@"

