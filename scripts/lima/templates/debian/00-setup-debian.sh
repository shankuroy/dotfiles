#!/usr/bin/env bash
#
# Configures unattended security upgrades and non-interactive service restarts.
# Run this on a fresh Debian server install.

set -Eeuo pipefail

# Print the failing command and line number instead of a bare non-zero exit.
trap 'echo -e "\e[31mError: command failed at line $LINENO: ${BASH_COMMAND}\e[0m" >&2' ERR

# --- Ensure the script is run as root -----------------------------------
if [ "${EUID}" -ne 0 ]; then
  echo -e "\e[31mError: This script must be run as root. Please use sudo.\e[0m" >&2
  exit 1
fi

# --- Sanity check: this script assumes a Debian/apt-based system --------
if ! command -v apt-get >/dev/null 2>&1; then
  echo -e "\e[31mError: apt-get not found. This script targets Debian-based systems.\e[0m" >&2
  exit 1
fi

# --- Helper: write a file only if its content actually changed ----------
# Usage: write_if_changed <target-path> <<'EOF' ... EOF
# Returns 0 (true) if the file was changed, 1 if it was already up to date.
write_if_changed() {
  local target="$1"
  local tmp
  tmp=$(mktemp)
  # Use a trap local to this call so we always clean up tmp, even on error.
  trap 'rm -f "${tmp}"' RETURN

  cat > "${tmp}"

  if [ -f "${target}" ] && cmp -s "${tmp}" "${target}"; then
    return 1
  fi

  install -D -m 0644 "${tmp}" "${target}"
  return 0
}

# --- Update package lists and install required packages -----------------
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -o DPkg::Lock::Timeout=60 upgrade -y
apt-get -o DPkg::Lock::Timeout=60 install -y apt-listchanges unattended-upgrades needrestart

# --- Configure unattended-upgrades to run automatically ------------------
echo "Configuring automatic periodic updates..."
AUTO_UPGRADES_FILE='/etc/apt/apt.conf.d/20auto-upgrades'
if write_if_changed "$AUTO_UPGRADES_FILE" <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
then
  echo "  -> $AUTO_UPGRADES_FILE updated"
else
  echo "  -> $AUTO_UPGRADES_FILE unchanged"
fi

# --- Configure unattended-upgrades rules (security updates only) --------
echo "Configuring unattended-upgrades rules..."
UNATTENDED_UPGRADES_FILE='/etc/apt/apt.conf.d/50unattended-upgrades'
if write_if_changed "$UNATTENDED_UPGRADES_FILE" <<'EOF'
// Automatically upgrade packages from these (origin:archive) pairs
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    // Uncomment the line below to also install regular updates, not just security
    // "${distro_id}:${distro_codename}-updates";
};

// Automatically reboot *WITHOUT CONFIRMATION* if a kernel update requires it
// Set to "false" if you want to manually reboot after kernel updates
Unattended-Upgrade::Automatic-Reboot "false";

// If Automatic-Reboot="true", reboot at this specific time (e.g., 2 AM)
Unattended-Upgrade::Automatic-Reboot-Time "02:00";

// Remove unused kernel packages automatically
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";

// Remove unused dependencies automatically
Unattended-Upgrade::Remove-Unused-Dependencies "true";
EOF
then
  echo "  -> $UNATTENDED_UPGRADES_FILE updated"
else
  echo "  -> $UNATTENDED_UPGRADES_FILE unchanged"
fi

# Validate the apt config is syntactically sound before moving on.
apt-config dump >/dev/null

# --- Configure needrestart for non-interactive service restarts ---------
echo "Configuring needrestart..."
NEED_RESTART_FILE='/etc/needrestart/conf.d/99-auto-restart.conf'
if write_if_changed "$NEED_RESTART_FILE" <<'EOF'
# Automatically restart services (a = auto, r = report only, i = interactive)
$nrconf{restart} = 'a';

# Do not restart these specific services automatically
$nrconf{override_rc} = {
    qr(^k3s) => 0,
    qr(^docker) => 0,
};
EOF
then
  echo "  -> $NEED_RESTART_FILE updated"
else
  echo "  -> $NEED_RESTART_FILE unchanged"
fi

# --- Configure ssh (idempotent, validate-before-apply) -------------------
echo "Configuring ssh..."

SSH_CONF='/etc/ssh/sshd_config.d/01-hardening.conf'
SSH_TMP=$(mktemp)
trap 'rm -f "${SSH_TMP}"' EXIT

cat > "${SSH_TMP}" <<'EOF'
PermitRootLogin no
PasswordAuthentication no
EOF

# Validate the *merged* config as it would look with the new file in place,
# before we touch anything live. sshd -T reads config from disk, so we test
# against the temp file's syntax first as a cheap sanity check...
sshd -t -f <(cat /etc/ssh/sshd_config; echo "Include ${SSH_TMP}") 2>/dev/null || {
  # Fallback for sshd builds that don't like process substitution with Include:
  # just syntax-check the snippet in isolation.
  sshd -t -f "${SSH_TMP}"
}

if [ -f "${SSH_CONF}" ] && cmp -s "${SSH_TMP}" "${SSH_CONF}"; then
  echo "  -> sshd hardening config unchanged, skipping reload"
else
  install -D -m 0644 "${SSH_TMP}" "${SSH_CONF}"
  # Re-validate the real, now-live config before reloading.
  sshd -t

  # Figure out the actual unit name (Debian 12+ can run ssh.socket).
  SSH_UNIT="ssh"
  if systemctl list-units --full --all --plain --no-legend 2>/dev/null | grep -q '^ssh\.service'; then
    SSH_UNIT="ssh"
  elif systemctl list-units --full --all --plain --no-legend 2>/dev/null | grep -q '^sshd\.service'; then
    SSH_UNIT="sshd"
  fi

  systemctl reload "${SSH_UNIT}"
  echo "  -> sshd hardening config updated and reloaded (${SSH_UNIT})"
fi

sshd -T | grep -Ei '^(permitrootlogin|passwordauthentication) '

echo -e "\e[32m✔︎ Configuration complete. Security updates will install automatically.\e[0m"

