#!/usr/bin/env bash

# Ubuntu server init script. Includes:
#   - basic ssh hardening
#   - auto unattended security upgrades that don't require a reboot
#   - Docker
#
# Copy this script to a fresh Ubuntu server and run it with your sudo user (not root), or curl-bash it:
#   curl -fsSL https://raw.githubusercontent.com/shankuroy/dotfiles/refs/heads/main/scripts/server/init-ubuntu-docker.sh | bash
#
# Next steps:
#   - configure firewall at the VPS level, e.g. IP-restricted SSH

# ---------------------------------------------------- functions & variables --
GREEN='\033[32m'
DEFAULT='\033[0m'
function log_info {
  printf "${GREEN}[UBUNTU-SETUP]${DEFAULT} %s\n" "$@"
}

# ---------------------------------------------------------------------- ssh --
FILE=/etc/ssh/sshd_config.d/99-hardening.conf
log_info "saving basic ssh hardening to $FILE"

sudo tee $FILE <<'EOF'
PasswordAuthentication no
PermitRootLogin no
EOF

log_info "importing ssh keys"
curl -fsSL https://raw.githubusercontent.com/shankuroy/dotfiles/refs/heads/main/scripts/server/import-ssh-keys.py | python3 -

# ------------------------------------------------------ unattended upgrades --
FILE=/etc/apt/apt.conf.d/50unattended-upgrades
log_info "saving unattended upgrades config to $FILE"

sudo tee $FILE <<'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF

# ------------------------------------------------------------- auto upgrades --
FILE=/etc/apt/apt.conf.d/20auto-upgrades
log_info "saving auto upgrades config to $FILE"

sudo tee $FILE <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

# -------------------------------------------------------------------- docker --
FILE=/etc/apt/keyrings/docker.asc
log_info "saving docker gpg key to $FILE"

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o $FILE
sudo chmod a+r $FILE
sudo cat $FILE

FILE=/etc/apt/sources.list.d/docker.sources
log_info "saving docker apt sources to $FILE"

sudo tee $FILE <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

FILE=/etc/docker/daemon.json
log_info "saving docker daemon config to $FILE"

sudo install -m 0755 -d /etc/docker
sudo tee /etc/docker/daemon.json <<'EOF'
{
  "no-new-privileges": true,
  "userland-proxy": false,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

# ------------------------------------------------------------------ packages --
log_info "installing packages"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# -------------------------------------------------------------------- finish --
log_info "server init complete! (check above for any errors)"
log_info "please restart the server with sudo reboot"

