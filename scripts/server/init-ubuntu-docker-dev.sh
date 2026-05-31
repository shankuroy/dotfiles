#!/usr/bin/env bash

# Ubuntu server dev init script. Includes:
#   - mise
#   - starship
#
# Copy this script to a fresh Ubuntu server and run it with your sudo user (not root), or curl-bash it:
#   curl -fsSL https://raw.githubusercontent.com/shankuroy/dotfiles/refs/heads/main/scripts/server/init-ubuntu-docker-dev.sh | bash

# ----------------------------------------------------- functions & variables --
GREEN='\033[32m'
DEFAULT='\033[0m'
function log_info {
  printf "${GREEN}[UBUNTU-SETUP-DEV]${DEFAULT} %s\n" "$@"
}

log_info "========== starting ubuntu dev server setup =========="


# ---------------------------------------------------------------------- bash --
log_info "updating ~/.bashrc-dev"

touch ~/.bashrc-dev
tee ~/.bashrc-dev <<'EOF'
# GENERATED FILE - DO NOT EDIT
command -v starship >/dev/null 2>&1 || sudo apt-get install -y starship
eval "$(starship init bash)"

command -v mise >/dev/null 2>&1 || curl https://mise.run | sh
eval "$(~/.local/bin/mise activate bash)"
EOF


# -------------------------------------------------------------------- finish --
log_info "========== ubuntu server dev setup complete =========="
log_info "reload config with: source ~/.bashrc-dev"

