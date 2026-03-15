#!/bin/bash
# Discord Auto-Updater Installer
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
USER_NAME="$(whoami)"

echo "=== Discord Auto-Updater Installer ==="
echo ""

# Check if Discord is installed
if ! dpkg -s discord &>/dev/null; then
    echo "Error: Discord is not installed. Please install Discord first."
    exit 1
fi

# Install wrapper script
echo "[1/3] Installing wrapper script to /usr/local/bin/discord-update-launcher..."
sudo cp "$SCRIPT_DIR/discord-update-launcher" /usr/local/bin/discord-update-launcher
sudo chmod +x /usr/local/bin/discord-update-launcher

# Install sudoers rule
echo "[2/3] Installing sudoers rule for passwordless updates..."
# Use the current user instead of %sudo group for tighter security
echo "$USER_NAME ALL=(root) NOPASSWD: /usr/bin/apt install -y /tmp/discord-update.deb" | sudo tee /etc/sudoers.d/discord-update > /dev/null
sudo chmod 440 /etc/sudoers.d/discord-update

# Validate sudoers
if ! sudo visudo -cf /etc/sudoers.d/discord-update &>/dev/null; then
    echo "Error: Invalid sudoers rule. Removing..."
    sudo rm -f /etc/sudoers.d/discord-update
    exit 1
fi

# Install user-local desktop entry
echo "[3/3] Installing user-local desktop entry..."
mkdir -p "$HOME/.local/share/applications"
cp "$SCRIPT_DIR/discord.desktop" "$HOME/.local/share/applications/discord.desktop"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

echo ""
echo "=== Installation complete! ==="
echo "Discord will now auto-update when launched from your application menu."
