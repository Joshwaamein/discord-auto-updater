# Discord Auto-Updater for Linux

Automatically updates Discord on launch so you never have to manually download and install `.deb` packages again.

## Problem

Discord on Linux doesn't support automatic updates like on Windows/macOS. When a new version is available, it shows a dialog asking you to manually download a `.deb` package and install it yourself. This is tedious.

## Solution

A lightweight wrapper script that intercepts Discord's launch, checks for updates, and silently installs them before Discord opens. If no update is needed, Discord launches instantly with minimal overhead.

## How It Works

1. **Version check**: On every launch, the wrapper queries your installed Discord version (`dpkg -s discord`) and compares it against the latest version available from Discord's download API.
2. **Auto-download & install**: If a newer version exists, the `.deb` is downloaded to `/tmp` and installed via `apt install` using a passwordless sudoers rule.
3. **Launch**: Discord launches normally after any update completes (or immediately if already up to date).

## Files

| File | Purpose |
|------|---------|
| `discord-update-launcher` | The wrapper script that checks for updates and launches Discord |
| `discord.desktop` | User-local desktop entry that points to the wrapper script |
| `discord-update.sudoers` | Sudoers rule for passwordless update installation |
| `install.sh` | Automated installation script |
| `uninstall.sh` | Automated uninstallation script |

## Installation

### Automatic

```bash
chmod +x install.sh
./install.sh
```

### Manual

1. **Copy the wrapper script:**
   ```bash
   sudo cp discord-update-launcher /usr/local/bin/discord-update-launcher
   sudo chmod +x /usr/local/bin/discord-update-launcher
   ```

2. **Install the sudoers rule** (allows passwordless update):
   ```bash
   sudo cp discord-update.sudoers /etc/sudoers.d/discord-update
   sudo chmod 440 /etc/sudoers.d/discord-update
   ```

3. **Install the user-local desktop entry** (overrides system entry without modifying it):
   ```bash
   mkdir -p ~/.local/share/applications
   cp discord.desktop ~/.local/share/applications/discord.desktop
   update-desktop-database ~/.local/share/applications
   ```

## Uninstallation

### Automatic

```bash
chmod +x uninstall.sh
./uninstall.sh
```

### Manual

```bash
sudo rm /usr/local/bin/discord-update-launcher
sudo rm /etc/sudoers.d/discord-update
rm ~/.local/share/applications/discord.desktop
update-desktop-database ~/.local/share/applications
```

## Security

- The sudoers rule is **narrowly scoped** — it only allows running `apt install -y /tmp/discord-update.deb` as root, nothing else.
- No passwords are stored anywhere.
- The download URL is Discord's official API endpoint.
- The user-local desktop entry takes priority over the system one, so the system entry is left untouched for the package manager to manage.

## Requirements

- Debian/Ubuntu-based Linux distribution
- Discord installed via `.deb` package
- `curl`, `apt`, `dpkg` (standard on Debian/Ubuntu)
- `sudo` access (only needed during installation)

## How the Version Check Works

The script follows Discord's download redirect URL (`https://discord.com/api/download?platform=linux&format=deb`) which resolves to a URL containing the version number (e.g., `discord-0.0.128.deb`). It extracts this version and compares it against the locally installed version using `sort -V`.

## License

MIT
