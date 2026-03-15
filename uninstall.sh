#!/bin/bash
# Discord Auto-Updater Uninstaller
set -e

echo "=== Discord Auto-Updater Uninstaller ==="
echo ""

# Remove wrapper script
if [ -f /usr/local/bin/discord-update-launcher ]; then
    echo "[1/3] Removing wrapper script..."
    sudo rm /usr/local/bin/discord-update-launcher
else
    echo "[1/3] Wrapper script not found, skipping."
fi

# Remove sudoers rule
if [ -f /etc/sudoers.d/discord-update ]; then
    echo "[2/3] Removing sudoers rule..."
    sudo rm /etc/sudoers.d/discord-update
else
    echo "[2/3] Sudoers rule not found, skipping."
fi

# Remove user-local desktop entry
if [ -f "$HOME/.local/share/applications/discord.desktop" ]; then
    echo "[3/3] Removing user-local desktop entry..."
    rm "$HOME/.local/share/applications/discord.desktop"
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
else
    echo "[3/3] User desktop entry not found, skipping."
fi

echo ""
echo "=== Uninstallation complete! ==="
echo "Discord will now use its default launch behavior."
