#!/usr/bin/env bash
#
# setup-server-mode.sh
#
# Turns a ThinkPad X1 Carbon Gen 5 into an always-on AC-powered server:
#   - Ignores lid switch for suspend (server keeps running)
#   - Turns the screen off (not sleep) on lid close
#   - Sets battery charge thresholds for longevity (40-60%)
#   - Gracefully shuts down if AC power is lost (since battery is kept low)
#
# Run as: sudo bash setup-server-mode.sh
# Then reboot when finished.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (use sudo)." >&2
    exit 1
fi

echo "=== 1/6: Updating and upgrading system packages ==="
apt update
apt upgrade -y

echo "=== 2/6: Installing required packages ==="
apt install -y acpid tlp tlp-rdw

echo "=== 3/6: Configuring logind to ignore lid switch and suspend keys ==="
LOGIND_CONF="/etc/systemd/logind.conf"
cp "$LOGIND_CONF" "${LOGIND_CONF}.bak.$(date +%s)"

# Remove any prior settings we may have added, then append fresh block
sed -i '/^HandleLidSwitch/d; /^HandleSuspendKey/d; /^HandleHibernateKey/d; /^IdleAction/d' "$LOGIND_CONF"

cat >> "$LOGIND_CONF" << 'EOF'

# --- added by setup-server-mode.sh ---
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
HandleSuspendKey=ignore
HandleHibernateKey=ignore
IdleAction=ignore
EOF

echo "=== 4/6: Masking sleep/suspend targets (safety net) ==="
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

echo "=== 5/6: Setting up lid-close screen-off handler (acpid) ==="
mkdir -p /etc/acpi/events

cat > /etc/acpi/lid_handler.sh << 'EOF'
#!/bin/bash
# Turns the display panel off/on on lid close/open.
# Does NOT suspend or sleep the machine - server keeps running.

BACKLIGHT=$(ls /sys/class/backlight | head -n1)
BL_PATH="/sys/class/backlight/${BACKLIGHT}/bl_power"
LID_STATE=$(cat /proc/acpi/button/lid/*/state 2>/dev/null | awk '{print $2}')

if [ -e "$BL_PATH" ]; then
    if [ "$LID_STATE" = "closed" ]; then
        echo 4 > "$BL_PATH"   # power off panel
    else
        echo 0 > "$BL_PATH"   # power on panel
    fi
fi
EOF
chmod +x /etc/acpi/lid_handler.sh

cat > /etc/acpi/events/lidclose << 'EOF'
event=button/lid.*
action=/etc/acpi/lid_handler.sh
EOF

echo "=== 6/6: Setting battery charge thresholds + graceful shutdown on AC loss ==="

# --- Battery charge thresholds (40-60%) for a battery kept in permanent storage state ---
TLP_CONF="/etc/tlp.conf"
if [ -f "$TLP_CONF" ]; then
    cp "$TLP_CONF" "${TLP_CONF}.bak.$(date +%s)"
    sed -i '/^START_CHARGE_THRESH_BAT0=/d; /^STOP_CHARGE_THRESH_BAT0=/d' "$TLP_CONF"
    cat >> "$TLP_CONF" << 'EOF'

# --- added by setup-server-mode.sh ---
START_CHARGE_THRESH_BAT0=40
STOP_CHARGE_THRESH_BAT0=60
EOF
fi

# --- Graceful shutdown handler on AC power loss ---
# Waits a few seconds and re-checks (debounce against flaky ACPI events),
# then shuts down cleanly if still running on battery.
cat > /etc/acpi/ac_handler.sh << 'EOF'
#!/bin/bash
LOGFILE="/var/log/ac-shutdown.log"
AC_ONLINE_PATH=$(ls -d /sys/class/power_supply/A{C,DP}* 2>/dev/null | head -n1)

if [ -z "$AC_ONLINE_PATH" ]; then
    exit 0
fi

STATUS=$(cat "${AC_ONLINE_PATH}/online" 2>/dev/null)

if [ "$STATUS" = "0" ]; then
    echo "$(date): AC power lost, waiting 10s to confirm..." >> "$LOGFILE"
    sleep 10
    STATUS_RECHECK=$(cat "${AC_ONLINE_PATH}/online" 2>/dev/null)
    if [ "$STATUS_RECHECK" = "0" ]; then
        echo "$(date): AC still absent, shutting down gracefully." >> "$LOGFILE"
        /sbin/shutdown -h now "AC power lost - shutting down to protect data"
    else
        echo "$(date): AC power restored, aborting shutdown." >> "$LOGFILE"
    fi
fi
EOF
chmod +x /etc/acpi/ac_handler.sh

cat > /etc/acpi/events/ac_power << 'EOF'
event=ac_adapter.*
action=/etc/acpi/ac_handler.sh
EOF

echo "=== Enabling services ==="
systemctl enable --now acpid
systemctl enable --now tlp

echo ""
echo "=================================================="
echo "Setup complete."
echo "Please reboot now for all settings to take effect:"
echo "    sudo reboot"
echo "=================================================="
