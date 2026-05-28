#!/usr/bin/env bash
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

echo "==> Setting up system-wide environment variables and aliases..."
sudo tee /etc/profile.d/bashrc-global.sh <<'EOF'
export TERM=xterm-256color
export EDITOR=nvim

# Map vim to nvim if available
if command -v nvim >/dev/null 2>&1; then
  alias vim=nvim
fi

alias la='ls -lah'
EOF

echo "==> Bootstrap complete!"

