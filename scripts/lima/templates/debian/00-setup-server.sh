#!/usr/bin/env bash

# Configures unattended security upgrades and non-interactive service restarts.
# Run this on a fresh Debian server install.

set -e

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\e[31mError: This script must be run as root. Please use sudo.\e[0m" >&2
  exit 1
fi

echo "Starting unattended-upgrades and needrestart configuration..."

# Update package lists and install required packages non-interactively
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y
apt-get install -y apt-listchanges unattended-upgrades needrestart

# Configure unattended-upgrades to run automatically
echo "Configuring automatic periodic updates..."
cat <<EOF > /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

# Configure unattended-upgrades rules (security snly)
echo "Configuring unattended-upgrades rules..."
cat <<EOF > /etc/apt/apt.conf.d/50unattended-upgrades
// Automatically upgrade packages from these (origin:archive) pairs
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}-security";
    // Uncomment the line below to also install regular updates, not just security
    // "\${distro_id}:\${distro_codename}-updates";
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

# Configure needrestart for non-interactive service restarts.
# This ensures that when unattended-upgrades runs in the background,
# needrestart will automatically restart services using updated libraries
# instead of popping up a prompt and hanging the upgrade process.
echo "Configuring needrestart..."
mkdir -p /etc/needrestart/conf.d/
cat <<EOF > /etc/needrestart/conf.d/99-auto-restart.conf
# Automatically restart services (a = auto, r = report only, i = interactive)
\$nrconf{restart} = 'a';

# Do not restart these specific services automatically
\$nrconf{override_rc} = {
    qr(^k3s) => 0,
};
EOF

echo "✅ Configuration complete. Security updates will install automatically."

