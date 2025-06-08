#!/usr/bin/env bash
#==============================================================================
# GfDE Installer cloner 
# Version: 0.1
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
set -e
echo -e "${CYAN}${BOLD}==>${RESET} Starting Install..."  
sleep 1
echo -e "${CYAN}${BOLD}==>${RESET} Installing git (if not already installed)..."
sudo pacman -S --needed git
REPO_URL="https://github.com/g-flame-oss/GfDE.git"
REPO_DIR="GfDE"
if [ -d "$REPO_DIR" ]; then
    echo -e "${YELLOW}${BOLD}==>${RESET} Directory '${REPO_DIR}' already exists. Removing it to avoid conflicts."
    rm -rf "$REPO_DIR"
fi
echo -e "${CYAN}${BOLD}==>${RESET} Cloning GfDE repository..."
git clone "$REPO_URL"
cd "$REPO_DIR"
if [ ! -f install.sh ]; then
    echo -e "${RED}${BOLD}!!${RESET} install.sh not found in the repository. Exiting."
    exit 1
fi
chmod +x install.sh
./install.sh
sleep 3
echo -e "${GREEN}${BOLD}==>${RESET} Bye Bye!!!!"
