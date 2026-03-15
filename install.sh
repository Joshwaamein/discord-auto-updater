#!/bin/bash
# Discord Auto-Updater Installer
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Detect the real user (works with both `./install.sh` and `sudo ./install.sh`)
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
elif [ "$(id -u)" -eq 0 ]; then
    REAL_USER="$USER"
    REAL_HOME="$HOME"
else
    REAL_USER="$(whoami)"
    REAL_HOME="$HOME"
fi

echo "=== Discord Auto-Updater Installer ==="
echo "Installing for user: $REAL_USER"
echo ""

# Check if Discord is installed
if ! dpkg -s discord &>/dev/null; then
    echo "Error: Discord is not installed. Please install Discord first."
    exit 1
fi

# Ensure we have sudo access
if [ "$(id -u)" -ne 0 ]; then
    echo "This installer requires sudo privileges."
    exec sudo "$0" "$@"
fi

# Install wrapper script
echo "[1/3] Installing wrapper script to /usr/local/bin/discord-update-launcher..."
cp "$SCRIPT_DIR/discord-update-launcher" /usr/local/bin/discord-update-launcher
chmod +x /usr/local/bin/discord-update-launcher

# Install sudoers rule
echo "[2/3] Installing sudoers rule for passwordless updates..."
echo "$REAL_USER ALL=(root) NOPASSWD: /usr/bin/apt install -y /tmp/discord-update.deb" > /etc/sudoers.d/discord-update
chmod 440 /etc/sudoers.d/discord-update

# Validate sudoers
if ! visudo -cf /etc/sudoers.d/discord-update &>/dev/null; then
    echo "Error: Invalid sudoers rule. Removing..."
    rm -f /etc/sudoers.d/discord-update
    exit 1
fi

# Install user-local desktop entry (as the real user, not root)
echo "[3/3] Installing user-local desktop entry..."
LOCAL_APPS="$REAL_HOME/.local/share/applications"
su - "$REAL_USER" -c "mkdir -p '$LOCAL_APPS'"
cp "$SCRIPT_DIR/discord.desktop" "$LOCAL_APPS/discord.desktop"
chown "$REAL_USER":"$REAL_USER" "$LOCAL_APPS/discord.desktop"
su - "$REAL_USER" -c "update-desktop-database '$LOCAL_APPS' 2>/dev/null || true"

echo ""
echo "=== Installation complete! ==="
echo "Discord will now auto-update when launched from your application menu."
echo "Logs are written to: $REAL_HOME/.local/share/discord-updater/update.log"
