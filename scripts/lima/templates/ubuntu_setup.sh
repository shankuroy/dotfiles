#!/usr/bin/env bash

# curl -fsSL https://raw.githubusercontent.com/shankuroy/dotfiles/refs/heads/main/scripts/lima/templates/ubuntu_setup.sh | bash

set -euo pipefail # Exit on error, unset variables, or pipe failures

# Ensure non-interactive apt installations
export DEBIAN_FRONTEND=noninteractive

echo "==> Preparing repositories and keys..."

# Add Neovim PPA
if ! grep -q "^deb .*neovim-ppa" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
    sudo apt-get update -y
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository ppa:neovim-ppa/unstable -y
fi

# Add Docker's Official GPG Key
sudo install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.asc ]; then
    sudo apt-get install -y ca-certificates curl
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
fi

# Add Docker Repository
if [ ! -f /etc/apt/sources.list.d/docker.sources ]; then
    sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
fi

echo "==> Updating package lists and performing one-time upgrade..."
sudo apt-get update -y
sudo apt-get dist-upgrade -y

echo "==> Installing packages..."
sudo apt-get install -y \
    neovim \
    tmux \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo "==> Configuring user permissions..."
if id -nG $USER | grep -qqv "docker"; then
    sudo usermod -aG docker $USER
fi

echo "==> Setting up bashrc..."
cat <<EOF > ~/.bashrc-$USER
# GENERATED FILE - DO NOT EDIT - EDIT INSTEAD: ~/.bashrc-session
export TERM=xterm-256color
export EDITOR=vim
command -v nvim >/dev/null 2>&1 && alias vim=nvim
alias la='ls -lah'
touch ~/.bashrc-session && source ~/.bashrc-session
EOF

INCLUDE_USER="[[ -f ~/.bashrc-$USER ]] && source ~/.bashrc-$USER"
grep -sqF "${INCLUDE_USER}" ~/.bashrc || echo "${INCLUDE_USER}" >> ~/.bashrc

echo "==> Bootstrap complete!"

