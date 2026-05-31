#!/usr/bin/env bash

# Ubuntu server init script. Includes:
#   - basic ssh hardening
#   - auto unattended security upgrades that don't require a reboot
#   - k3s
#   - interactive ssh drops you into tmux
#
# Copy this script to a fresh Ubuntu server and run it with your sudo user (not root), or curl-bash it:
#   curl -fsSL https://raw.githubusercontent.com/shankuroy/dotfiles/refs/heads/main/scripts/server/init-ubuntu-k3s.sh | bash
#
# Next steps:
#   - configure firewall at the VPS level, e.g. IP-restricted SSH

# ----------------------------------------------------- functions & variables --
GREEN='\033[32m'
DEFAULT='\033[0m'
function log_info {
  printf "${GREEN}[UBUNTU-SETUP]${DEFAULT} %s\n" "$@"
}

log_info "========== starting ubuntu server setup =========="

# ---------------------------------------------------------------------- bash --
log_info "enabling support for ~/.bashrc-{admin,dev,custom} and ensuring interactive sessions start in tmux"

INCLUDE_LINE='[[ -f ~/.bashrc-admin ]] && source ~/.bashrc-admin'
grep -qxF "$INCLUDE_LINE" ~/.bashrc || echo "$INCLUDE_LINE" >> ~/.bashrc

touch ~/.bashrc-{admin,dev,custom}
tee ~/.bashrc-admin <<'EOF'
# GENERATED FILE - DO NOT EDIT
export EDITOR=vim
alias la='ls -lah'
[[ -f ~/.bashrc-dev ]]    && source ~/.bashrc-dev
[[ -f ~/.bashrc-custom ]] && source ~/.bashrc-custom

# ensure interactive ssh sessions start in tmux
[[ -z "$TMUX" && -n "$SSH_TTY" ]] && exec tmux new-session -A -s "$(hostname)"
EOF

# ----------------------------------------------------------------------- ssh --
FILE=/etc/ssh/sshd_config.d/99-hardening.conf
log_info "saving basic ssh hardening to $FILE"

sudo tee $FILE <<'EOF'
PasswordAuthentication no
PermitRootLogin no
EOF

log_info "verifying ssh config"
sudo sshd -t

# ------------------------------------------------------- unattended upgrades --
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

# ----------------------------------------------------------------------- k3s --
log_info "installing k3s"
curl -sfL https://get.k3s.io | sh -

# -------------------------------------------------------------------- finish --
log_info "========== ubuntu server setup complete =========="
log_info "please check the output above for errors, then restart the server with sudo reboot"

