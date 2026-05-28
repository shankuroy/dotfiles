#!/usr/bin/env bash

# curl -fsSL https://raw.githubusercontent.com/shankuroy/dotfiles/refs/heads/main/scripts/lima/templates/ubuntu_setup.sh | bash

set -euo pipefail # Exit on error, unset variables, or pipe failures

# Ensure non-interactive apt installations
export DEBIAN_FRONTEND=noninteractive

echo "==> Preparing repositories and keys..."

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "==> Installing packages..."
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt-get install -y \
    ca-certificates \
    neovim \
    tmux \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

sudo apt-get update -y

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

echo "==> Basic server hardening..."
# TODO

echo "==> Bootstrap complete!"

