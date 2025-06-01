#!/usr/bin/env bash
sudo pacman -Sy && sudo pacman -S git && git clone https://github.com/g-flame-oss/GfDE.git && cd GfDE && sudo chmod +x install.sh && ./install.sh && echo "Bye!"