#!/bin/bash
##########################################################################################
#       Installer by G-flame @ https://github.com/g-flame                                #
#       Panel and Daemon by Airlinklabs @ https://github.com/airlinklabs                 #
#                                                                                        #
#       MIT License                                                                      #
#                                                                                        #
#       Copyright (c) 2025 G-flame-OSS                                                   #
#                                                                                        #
#       Permission is hereby granted, free of charge, to any person obtaining a copy     #
#       of this software and associated documentation files (the "Software"), to deal    #
#       in the Software without restriction, including without limitation the rights     #
#       to use, copy, modify, merge, publish, distribute, sublicense, and/or sell        #
#       copies of the Software, and to permit persons to whom the Software is            #
#       furnished to do so, subject to the following conditions:                         #
#                                                                                        #
#       The above copyright notice and this permission notice shall be included in all   #
#       copies or substantial portions of the Software.                                  #
#                                                                                        #
#       THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR       #
#       IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,         #
#       FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE      #
#       AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER           #
#       LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,    #
#       OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE    #
#       SOFTWARE.                                                                        #
##########################################################################################
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
    asciiart
    echo -e "Choose"
    echo -e "1)install arch(archinstall)?"
    echo -e "2)install GfDE dots and dependencies?"
    echo -e "3)install only the dependencies?"
    echo -e "4)install only selective stuff?"
    echo -e "5)exit script?"
    
    read -p "What do you want to do? [1-5]: " choice
    
    case $choice in
        1)

            ;;
        2)

            ;;
        3)

            ;;
        4)

            ;;
        5)
            echo -e "Thank you for using the installer. Goodbye!"
            restore_screen
            exit 0
            ;;
        *)
            echo -e "\n${RED}That's not a valid option! Please try again.${NC}"
            ;;
    esac
    echo -e "Operation completed!"
    echo -e "\nPress Enter to return to the menu..."
    read
    clear
    main
}
#
#Reused this from my other project! tehe!
#close trap and code exec
#
restore_screen() {
    echo -e "${YELLOW}Restoring screen before Script!${NC}"
    tput rmcup
    exit 0
}
trap restore_screen SIGINT
tput smcup
clear
#
#
#
# The Actual script start !!!!
main
# The Actual Script is above !!!!
#
#
#
for i in {1..30}; do
    echo -ne "Processing... $i/30\r"
    sleep 1
    if [ $? -ne 0 ]; then
        break
    fi
done
restore_screen


