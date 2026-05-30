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

log_info "downloading docker gpg key"

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

log_info "docker gpg key downloaded to /etc/apt/keyrings/docker.asc"
log_info "adding docker apt sources"

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

log_info "apt sources saved to /etc/apt/sources.list.d/docker.sources"
log_info "adding docker daemon config"

sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
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

log_info "docker daemon config saved to /etc/docker/daemon.json"
log_info "adding basic ssh hardening"

sudo tee /etc/ssh/sshd_config.d/99-hardening.conf <<EOF
PasswordAuthentication no
PermitRootLogin no
EOF

log_info "basic ssh hardening saved to /etc/ssh/sshd_config.d/99-hardening.conf"
log_info "configuring unattended upgrades"

sudo tee /etc/apt/apt.conf.d/50unattended-upgrades <<'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF

log_info "unattended upgrades config saved to /etc/apt/apt.conf.d/50unattended-upgrades"
log_info "configuring auto upgrades"

sudo tee /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

log_info "auto upgrades config saved to /etc/apt/apt.conf.d/20auto-upgrades"
log_info "installing docker"

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

log_info "docker installation complete (check above for any errors)"
log_info "server init complete!"
log_info "please restart the server with sudo reboot"

