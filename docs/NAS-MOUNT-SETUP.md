# NAS Mount Setup

This guide covers setting up automatic mounting of your Samba NAS share.

## Overview

The NAS mount configuration automatically mounts your NAS share at `~/shared/` using different methods optimized for each platform:

- **macOS**: launchd + periodic mount script (runs every 5 minutes)
- **Linux**: autofs with on-demand mounting

**Supported Platforms:**
- macOS (Sequoia tested, should work on older versions)
- Linux (Ubuntu/Debian, Fedora/RHEL/CentOS, Arch)

**Configuration:**
- NAS hostname and share name are configured during setup (not hardcoded in the repository)
- Mount Point: `~/shared/`
- Configuration stored in: `~/.autofs_config` (not committed to repository)

## Quick Start

### 1. Complete Setup (Recommended)

Run the all-in-one setup command:

```bash
make nas-mount
```

This interactive wizard will:
1. **Prompt for NAS details** (if not already configured):
   - NAS hostname (e.g., `nas.example.com`)
   - Share name (default: `shared`)
   - Username (default: your current username)
   - Password (stored securely in Keychain on macOS, or `~/.smbcredentials` on Linux)

2. **Configure mounting system**:
   - **macOS**: Install mount script, create LaunchAgent, run every 5 minutes
   - **Linux**: Install autofs package, configure autofs maps
   - Create mount point at `~/shared/`
   - Start/enable the mounting service

**Note:** Configuration is stored in `~/.autofs_config` (mode 600) which is NOT committed to the repository.

### 2. Test the Mount

```bash
make nas-test
```

Or simply:
```bash
ls ~/shared/
```

The share should mount automatically when accessed (Linux) or within 5 minutes (macOS).

### 3. Check Status

```bash
make nas-status
```

Shows configuration, mount status, and service health with clear OK/ERROR indicators.

### 4. View Logs (macOS only)

```bash
make nas-logs
```

Shows recent mount attempts and any errors.

## Available Make Targets

| Target | Description |
|--------|-------------|
| `make nas-mount` | Complete setup (credentials + configuration) |
| `make nas-status` | Show configuration and mount status |
| `make nas-test` | Test the NAS mount connection |
| `make nas-logs` | View recent mount logs (macOS only) |
| `make nas-fix` | Fix common issues (menu-driven) |
| `make nas-remove` | Remove NAS mount configuration |

**Via `make nas-fix` menu:**
- Refresh credentials (after password change)
- Restart mounting service
- Force remount now (macOS only)

## How It Works

### Configuration Files

**User configuration (not in repository):**
- `~/.autofs_config` - NAS hostname and share name (mode 600)
- `~/.smbcredentials` - Linux only: Samba credentials (mode 600)
- `~/.local/share/logs/nas-mount.log` - macOS only: Mount logs

### Linux (autofs)

Linux uses the standard autofs service with CIFS (Samba) mounting:

**System configuration files:**
- `/etc/auto.master` - Master map pointing to the NAS map
- `/etc/auto.nas` - Map file defining the mount configuration
- `~/.autofs_config` - NAS hostname/share (read by makefile)
- `~/.smbcredentials` - Samba credentials (mode 600)

**Mount options:**
- Filesystem type: `cifs`
- Credentials from `~/.smbcredentials`
- UID/GID set to current user
- File mode: 0644, Directory mode: 0755
- Timeout: 60 seconds

**How it works:**
- Mount triggered on first access to `~/shared/`
- Automatically unmounts after 60 seconds of inactivity
- System service: `autofs`

### macOS (launchd + mount script)

macOS uses a launchd-based periodic mount script instead of autofs to work around reliability issues with macOS autofs (ownership bugs, network reconnection problems).

**System configuration:**
- `~/Library/LaunchAgents/com.user.nas-mount.plist` - LaunchAgent definition
- `~/.dotfiles/scripts/mount-nas.sh` - Mount script
- `~/.autofs_config` - NAS hostname/share
- Keychain - Secure password storage

**Mount options:**
- Filesystem type: `smbfs`
- Soft mount (non-blocking)
- Mount point: `/Volumes/nas-<username>`
- Symlink: `~/shared -> /Volumes/nas-<username>`

**How it works:**
1. LaunchAgent runs `mount-nas.sh` every 5 minutes
2. Script checks if already mounted (no-op if yes)
3. Script checks network connectivity (silent exit if NAS unreachable)
4. Script retrieves password from Keychain
5. Script mounts NAS share to `/Volumes/nas-<username>`
6. Script creates/updates symlink at `~/shared`

**Key benefits over autofs on macOS:**
- No ownership bugs after sleep/wake
- Graceful handling of network changes
- Auto-reconnects after network switch
- Silent operation when away from home network
- Detailed logging for troubleshooting

## Troubleshooting

### Check Configuration Status

```bash
make nas-status
```

This shows:
- NAS configuration details
- System configuration status with OK/MISSING/ERROR indicators
- Mount point status and ownership
- Service status

### macOS: Mount Not Working

**Check logs:**
```bash
make nas-logs
```

**Common issues:**

1. **"NAS host not reachable"** - Normal when not on home network
   - The script will keep trying every 5 minutes
   - When you return to home network, it will mount automatically

2. **"No password in Keychain"** - Credentials missing
   ```bash
   make nas-fix
   # Select option 1: Refresh credentials
   ```

3. **LaunchAgent not running:**
   ```bash
   make nas-fix
   # Select option 2: Restart launchd service
   ```

4. **Force immediate mount attempt:**
   ```bash
   make nas-fix
   # Select option 3: Force remount now
   ```

**Manual debugging:**
```bash
# Run mount script manually
~/.dotfiles/scripts/mount-nas.sh

# Check LaunchAgent status
launchctl list | grep nas-mount

# View system logs
tail -f /tmp/nas-mount-stdout.log
tail -f /tmp/nas-mount-stderr.log
```

### Linux: Mount Not Working

1. **Check autofs service:**
   ```bash
   sudo systemctl status autofs
   ```

2. **Check credentials:**
   - Verify `~/.smbcredentials` has correct username/password

3. **Test NAS connectivity:**
   ```bash
   ping <your-nas-host>
   ```

4. **Manual mount test:**
   ```bash
   sudo mount -t cifs -o credentials=~/.smbcredentials,uid=$(id -u),gid=$(id -g) \
     //<your-nas-host>/<share> /mnt/test
   ```

5. **Restart autofs service:**
   ```bash
   make nas-fix
   # Select option 2: Restart autofs service
   ```

### View Logs

**macOS:**
```bash
# Application logs
make nas-logs

# LaunchAgent stdout/stderr
tail -f /tmp/nas-mount-stdout.log
tail -f /tmp/nas-mount-stderr.log

# System logs
log show --predicate 'process == "mount_smbfs"' --last 1h
```

**Linux:**
```bash
# autofs service logs
sudo journalctl -u autofs -f

# syslog
sudo tail -f /var/log/syslog | grep autofs
```

## Uninstalling

To remove the NAS mount configuration:

```bash
make nas-remove
```

**macOS:** This will:
1. Unload and remove LaunchAgent
2. Unmount NAS share
3. Remove mount point symlink

**Linux:** This will:
1. Remove autofs configuration entries
2. Remove mount point directory/symlink
3. Restart autofs service

**Note:** This does NOT remove your credentials (`~/.autofs_config`, Keychain entries, or `~/.smbcredentials`).

## Security Notes

1. **Configuration Files:**
   - `~/.autofs_config` contains your NAS hostname and is NOT committed to the repository
   - Stored with mode 600 (owner read/write only)
   - Each user/machine maintains their own configuration

2. **Credentials File (Linux):**
   - `~/.smbcredentials` contains username/password with mode 600
   - Never commit this file to version control
   - Consider using encrypted home directory

3. **Keychain (macOS):**
   - Credentials stored in macOS Keychain are encrypted
   - Accessible only to your user account
   - Keychain locked when screen is locked

4. **Network Security:**
   - SMB/CIFS traffic should use SMB3 protocol (enabled by default on modern systems)
   - Consider setting up VPN for remote access to NAS

5. **Logging:**
   - macOS logs at `~/.local/share/logs/nas-mount.log` contain timestamps and actions
   - No passwords are logged
   - Log file automatically rotates at 500 lines

## Advanced Configuration

### Change Mount Point

Edit `.make.d/nas-mount.mk` and change:
```makefile
MOUNT_POINT := $(HOME)/your-custom-path
```

Then run:
```bash
make nas-remove
make nas-mount
```

### Change NAS Host or Share

Simply re-run setup, which will offer to reconfigure:

```bash
make nas-mount
```

If you need to completely reset:
```bash
make nas-remove
make nas-mount
```

### Change Mount Frequency (macOS)

Edit the LaunchAgent plist at `~/Library/LaunchAgents/com.user.nas-mount.plist`:

```xml
<key>StartInterval</key>
<integer>300</integer>  <!-- Change from 300 (5 min) to desired seconds -->
```

Then restart:
```bash
make nas-fix
# Select option 2: Restart launchd service
```

### Network-Aware Mounting (macOS)

The mount script already checks network connectivity via ping. For more advanced network awareness (e.g., SSID detection), you can modify `scripts/mount-nas.sh` to add:

```bash
# Check if on home WiFi (example)
CURRENT_SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}')
if [ "$CURRENT_SSID" != "YourHomeWiFi" ]; then
    silent_exit "Not on home WiFi network"
fi
```

## Migration from autofs (macOS)

If you previously used the autofs-based configuration on macOS, migration is automatic:

1. The new system reuses your existing `~/.autofs_config` file
2. The new system reuses your Keychain credentials
3. You can safely run `make nas-mount` to install the new system
4. The old autofs configuration remains but is unused

To completely remove the old autofs configuration:

```bash
# Remove old autofs entries
sudo sed -i.bak '/auto_nas/d' /etc/auto_master
sudo rm -f /etc/auto_nas
sudo rm -f /System/Volumes/Data/shared-$USER
sudo automount -vc
```

## Differences: macOS vs Linux

| Feature | macOS | Linux |
|---------|-------|-------|
| **Technology** | launchd + mount script | autofs |
| **Mount trigger** | Periodic (every 5 min) | On-demand (on access) |
| **Mount point** | `/Volumes/nas-<user>` | `~/shared` |
| **Symlink** | `~/shared -> /Volumes/nas-<user>` | None (direct mount) |
| **Auto-unmount** | No (persistent) | Yes (after 60 sec idle) |
| **Network handling** | Silent when unavailable | Blocks on access if unavailable |
| **Sleep/wake** | Robust (auto-reconnects) | Generally reliable |
| **Logging** | `~/.local/share/logs/nas-mount.log` | System journal/syslog |
| **Credentials** | Keychain | `~/.smbcredentials` file |

## Why Different Approaches?

**macOS autofs issues** (documented since OS X Yosemite):
- Ownership bug: mounts become owned by root after sleep/wake
- Network changes: doesn't auto-reconnect after WiFi switch
- Silent failures: hard to debug when things go wrong

**launchd approach benefits**:
- Periodic checks ensure mount stays healthy
- Network connectivity check prevents errors when away from home
- Detailed logging for troubleshooting
- Graceful handling of all edge cases
- No sudo required after initial setup

**Linux autofs remains** because:
- Works reliably on Linux
- On-demand mounting saves resources
- No known bugs requiring workarounds
- Standard approach used by many systems

## References

- [Linux autofs documentation](https://www.kernel.org/doc/html/latest/filesystems/autofs.html)
- [macOS autofs guide](https://support.apple.com/guide/deployment/autofs-apdE7A43C2E-91F5-44AC-8FCD-7D9A7A6C4355/web)
- [Samba/CIFS mount options](https://linux.die.net/man/8/mount.cifs)
- [launchd plist manual](https://www.launchd.info/)
