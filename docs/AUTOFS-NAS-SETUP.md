# Autofs NAS Setup

This guide covers setting up automatic mounting of your Samba NAS share using autofs.

## Overview

The autofs configuration automatically mounts your NAS share at `~/shared/` when you access it. The share unmounts automatically after a period of inactivity, saving system resources.

**Supported Platforms:**
- macOS (using built-in autofs)
- Linux (Ubuntu/Debian, Fedora/RHEL/CentOS, Arch)

**Configuration:**
- NAS hostname and share name are configured during setup (not hardcoded in the repository)
- Mount Point: `~/shared/`
- Configuration stored in: `~/.autofs_config` (not committed to repository)

## Quick Start

### 1. Complete Setup (Recommended)

Run the all-in-one setup command:

```bash
make autofs
```

This interactive wizard will:
1. **Prompt for NAS details** (if not already configured):
   - NAS hostname (e.g., `nas.example.com`)
   - Share name (default: `shared`)
   - Username (default: your current username)
   - Password (stored securely in Keychain on macOS, or `~/.smbcredentials` on Linux)

2. **Configure autofs system files** (requires sudo):
   - Install autofs package (Linux only; macOS has autofs built-in)
   - Create mount point at `~/shared/`
   - Configure autofs maps
   - Restart autofs service

**Note:** Configuration is stored in `~/.autofs_config` (mode 600) which is NOT committed to the repository.

### 2. Test the Mount

```bash
make autofs-test
```

Or simply:
```bash
ls ~/shared/
```

The share should mount automatically when accessed.

### 3. Check Status

```bash
make autofs-status
```

Shows configuration, mount status, and service health with clear OK/ERROR indicators.

## Available Make Targets

| Target | Description |
|--------|-------------|
| `make autofs` | Complete setup (credentials + configuration) |
| `make autofs-status` | Show configuration and mount status |
| `make autofs-test` | Test the NAS mount connection |
| `make autofs-fix` | Fix common issues (menu-driven) |
| `make autofs-remove` | Remove autofs NAS configuration |

**Via `make autofs-fix` menu:**
- Refresh credentials (after password change)
- Restart autofs service
- Fix ownership bug (macOS only)
- Install/uninstall auto-fix agent (macOS only)

## How It Works

### Configuration Files

**User configuration (not in repository):**
- `~/.autofs_config` - NAS hostname and share name (mode 600)
- `~/.smbcredentials` - Linux only: Samba credentials (mode 600)

### Linux

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

### macOS

macOS uses the built-in autofs/automount system with SMB:

**System configuration files:**
- `/etc/auto_master` - Master map pointing to the NAS map
- `/etc/auto_nas` - Map file defining the mount configuration
- `~/.autofs_config` - NAS hostname/share (read by makefile)

**Mount options:**
- Filesystem type: `smbfs`
- Soft mount (non-blocking)
- Credentials from Keychain or prompted on first access

## Troubleshooting

### Check Configuration Status

```bash
make autofs-status
```

This shows:
- NAS configuration details
- System configuration status with OK/MISSING/ERROR indicators
- Mount point status and ownership
- Service status

### macOS: Permission Denied After Sleep/Wake (Known Bug)

**Problem:** On macOS, autofs mounts frequently become owned by root after sleep/wake cycles or network reconnections, causing "Permission denied" errors.

This is a **known macOS autofs bug** that has existed since at least macOS Yosemite and persists through Sequoia.

**Symptoms:**
- `ls ~/shared` returns "Permission denied"
- Mount shows as active: `mount | grep shared` shows the SMB mount
- Accessing mount point fails even though it appears mounted
- `make autofs-status` shows "[WARNING] Owned by root"

**Quick Fix:**
```bash
make autofs-fix
# Select option 3: Fix ownership bug (macOS)
```

Or manually:
```bash
sudo umount -f /System/Volumes/Data/shared-$USER && sudo automount -vc
```

This force unmounts the broken mount and refreshes autofs to remount with correct ownership.

**Permanent Solution (Recommended):**
Install a LaunchAgent that automatically detects and fixes the ownership issue:

```bash
make autofs-fix
# Select option 4: Install auto-fix agent (macOS)
```

This installs a background service that:
- Runs at login
- Checks every 5 minutes if the mount is owned by root
- Automatically fixes ownership when needed

**View fix logs:**
```bash
tail -f /tmp/autofs-fix.log
```

**Uninstall auto-fix:**
```bash
make autofs-fix
# Select option 5: Uninstall auto-fix agent (macOS)
```

**Technical Details:**
- The bug causes mounts to be automounted by root instead of the user
- Affects both sleep/wake cycles and network reconnections
- No official Apple fix exists
- Workaround: unmount and remount to restore correct ownership

### Mount Point Empty or Shows Only "." and ".."

**Problem:** `~/shared` exists but is empty or shows only hidden entries, not your NAS files.

**Symptoms:**
- `ls ~/shared` returns empty or just `.` and `..`
- Symlink exists: `ls -la ~/shared` shows symlink to `/System/Volumes/Data/shared-$USER`
- But `make autofs-status` shows "[MISSING] No entry in /etc/auto_master"

**Cause:** The mount point and symlink were created, but the autofs configuration was never applied. This happens when `make autofs` was interrupted or never completed.

**Solution:**
```bash
make autofs
```

This will (re)apply the autofs configuration files to `/etc/auto_master` and `/etc/auto_nas` (macOS) or `/etc/auto.master` and `/etc/auto.nas` (Linux).

**Verification:**
```bash
make autofs-status
# Should show "[OK] Entry exists in /etc/auto_master"
ls ~/shared
# Should now show your NAS files
```

### Mount Not Working

1. **Check autofs service:**
   ```bash
   # Linux
   sudo systemctl status autofs

   # macOS
   ps aux | grep automount
   ```

2. **Check credentials:**
   - Linux: Verify `~/.smbcredentials` has correct username/password
   - macOS: Check Keychain Access for `borg.theclonchs.com` entry

3. **Test NAS connectivity:**
   ```bash
   ping borg.theclonchs.com
   ```

4. **Manual mount test:**
   ```bash
   # Linux
   sudo mount -t cifs -o credentials=~/.smbcredentials,uid=$(id -u),gid=$(id -g) \
     //borg.theclonchs.com/share /mnt/test

   # macOS
   mkdir ~/test-mount
   mount -t smbfs //username@borg.theclonchs.com/share ~/test-mount
   ```

### Restart Autofs Service

```bash
make autofs-fix
# Select option 2: Restart autofs service
```

Or manually:
```bash
# Linux
sudo systemctl restart autofs

# macOS
sudo automount -vc
```

### View Autofs Logs

**Linux:**
```bash
# Ubuntu/Debian
sudo journalctl -u autofs -f

# Or check syslog
sudo tail -f /var/log/syslog | grep autofs
```

**macOS:**
```bash
# System log
log show --predicate 'process == "automountd"' --last 1h

# Or console app
# Open Console.app and filter for "automountd"
```

## Uninstalling

To remove the autofs NAS configuration:

```bash
make autofs-remove
```

This will:
1. Remove autofs configuration entries
2. Remove the mount point directory/symlink
3. Restart the autofs service

**Note:** This does NOT remove your credentials (`~/.autofs_config`, Keychain entries, or `~/.smbcredentials`).

The autofs package itself remains installed but inactive for your NAS.

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

4. **Network Security:**
   - SMB/CIFS traffic should use SMB3 protocol (enabled by default on modern systems)
   - Consider setting up VPN for remote access to NAS

## Advanced Configuration

### Change Mount Point

Edit `.make.d/autofs.mk` and change:
```makefile
MOUNT_POINT := $(HOME)/your-custom-path
```

Then run:
```bash
make autofs-remove
make autofs
```

### Change NAS Host or Share

Simply re-run setup, which will offer to reconfigure:

```bash
make autofs
```

If you need to completely reset:
```bash
make autofs-remove
make autofs
```

### Add Multiple NAS Shares

You can manually edit the autofs map files to add additional shares:

**Linux** (`/etc/auto.nas`):
```
shared -fstype=cifs,credentials=/home/user/.smbcredentials,uid=1000,gid=1000 ://your-nas.example.com/share
media  -fstype=cifs,credentials=/home/user/.smbcredentials,uid=1000,gid=1000 ://your-nas.example.com/media
```

**macOS** (`/etc/auto_nas`):
```
shared -fstype=smbfs,soft ://your-nas.example.com/share
media  -fstype=smbfs,soft ://your-nas.example.com/media
```

After editing, restart autofs:
```bash
make autofs-fix
# Select option 2: Restart autofs service
```

## References

- [Linux autofs documentation](https://www.kernel.org/doc/html/latest/filesystems/autofs.html)
- [macOS autofs guide](https://support.apple.com/guide/deployment/autofs-apdE7A43C2E-91F5-44AC-8FCD-7D9A7A6C4355/web)
- [Samba/CIFS mount options](https://linux.die.net/man/8/mount.cifs)
