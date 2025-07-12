#!/usr/bin/env bash

set -e

# package manager dedection
if ! command -v git &> /dev/null; then
    if command -v pacman &> /dev/null; then
        sudo pacman -S --needed git
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y git
    elif command -v yum &> /dev/null; then
        sudo yum install -y git
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y git
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y git
    elif command -v brew &> /dev/null; then
        brew install git
    else
        echo "Package manager not supported. Install git manually."
        exit 1
    fi
fi

# Clone repo
REPO_URL="https://github.com/g-flame-oss/GfDE.git"
REPO_DIR="GfDE"

# Remove existing directory
[ -d "$REPO_DIR" ] && rm -rf "$REPO_DIR"

# Clone and run installer
git clone "$REPO_URL"
cd "$REPO_DIR"
chmod +x assets/install.sh
cd assets
./install.sh
echo "install sccript ended !"
cd ~/
echo "Bye!"