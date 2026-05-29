#!/usr/bin/env bash

# curl -fsSL https://raw.githubusercontent.com/shankuroy/dotfiles/refs/heads/main/scripts/lima/templates/ubuntu_setup.sh | bash

set -euo pipefail # Exit on error, unset variables, or pipe failures

function log_info {
  echo "[INFO][SETUP]: $@"
}

log_info "Starting Ubuntu setup"

export DEBIAN_FRONTEND=noninteractive

if command -v docker >/dev/null 2>&1; then
  log_info "Docker is installed"
  docker info
else
  # https://docs.docker.com/engine/install/ubuntu
  log_info "Adding Docker's official GPG key"
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  log_info "GPG key added"

  log_info "Adding Docker repository to Apt sources"
  sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
  log_info "Docker Apt repository added"

  log_info "Installing Docker"
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl start docker || true
  sudo systemctl status docker || true
  log_info "Docker installation complete"

  log_info "Adding Docker user permissions"
  getent group docker || sudo groupadd docker
  sudo usermod -aG docker "$USER"
  log_info "Docker user permissions added"
fi

log_info "Setting up bashrc"
cat <<EOF > ~/.bashrc-$USER
# GENERATED FILE - DO NOT EDIT - EDIT INSTEAD: ~/.bashrc-session
export TERM=xterm-256color
export EDITOR=vim
alias la='ls -lah'
touch ~/.bashrc-session && source ~/.bashrc-session
EOF

grep -sqF "source ~/.bashrc-$USER" ~/.bashrc \
  || echo "source ~/.bashrc-$USER" >> ~/.bashrc

log_info "bashrc setup complete"

# echo "==> Basic server hardening..."
# TODO

log_info "Ubuntu server setup complete!"

