#!/usr/bin/env bash

# Ubuntu server init script with Docker, some very basic ssh hardening,
# and unattended security upgrades that don't require a reboot.
#
# Make sure you set up your VPS firewall!

GREEN='\033[32m'
DEFAULT='\033[0m'
function log_info {
  printf "${GREEN}[UBUNTU-SETUP]${DEFAULT} %s\n" "$@"
}

CONF=/etc/ssh/sshd_config.d/99-hardening.conf
log_info "saving basic ssh hardening to $CONF"
sudo tee $CONF <<'EOF'
PasswordAuthentication no
PermitRootLogin no
EOF

CONF=/etc/apt/apt.conf.d/50unattended-upgrades
log_info "saving unattended upgrades config to $CONF"
sudo tee $CONF <<'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF

CONF=/etc/apt/apt.conf.d/20auto-upgrades
log_info "saving auto upgrades config to $CONF"
sudo tee $CONF <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

CONF=/etc/apt/keyrings/docker.asc
log_info "saving docker gpg key to $CONF"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o $CONF
sudo chmod a+r $CONF
sudo cat $CONF

CONF=/etc/apt/sources.list.d/docker.sources
log_info "saving docker apt sources to $CONF"
sudo tee $CONF <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

CONF=/etc/docker/daemon.json
log_info "saving docker daemon config to $CONF"
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

log_info "installing packages"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

log_info "server init complete! (check above for any errors)"
log_info "please restart the server with sudo reboot"

