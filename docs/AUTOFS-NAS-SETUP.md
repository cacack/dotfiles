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

### 1. Set Up Configuration and Credentials

Run the interactive setup to configure your NAS connection:

```bash
make setup-autofs-credentials
```

This will:
1. **Prompt for NAS details:**
   - NAS hostname (e.g., `nas.example.com`)
   - Share name (default: `share`)
   - Configuration saved to `~/.autofs_config` (mode 600)

2. **Platform-specific credential setup:**

   **Linux:**
   - Prompts for Samba username, password, and domain
   - Saves credentials to `~/.smbcredentials` (mode 600)

   **macOS:**
   - Displays instructions for storing credentials in Keychain
   - Alternatively, macOS will prompt for credentials on first access

**Note:** Both `~/.autofs_config` and `~/.smbcredentials` are local to your machine and NOT committed to the repository.

### 2. Install and Configure Autofs

```bash
make setup-autofs
```

This command will:
1. Install autofs and required packages (Linux only; macOS has autofs built-in)
2. Create the `~/shared/` mount point directory
3. Configure autofs master and map files (requires sudo)
4. Restart the autofs service

### 3. Test the Mount

```bash
make test-autofs
```

Or simply:
```bash
ls ~/shared/
```

The share should mount automatically when accessed.

## Available Make Targets

| Target | Description |
|--------|-------------|
| `make setup-autofs` | Complete autofs setup for NAS mounting |
| `make setup-autofs-credentials` | Configure Samba credentials |
| `make test-autofs` | Test the NAS mount |
| `make status-autofs` | Show autofs configuration status |
| `make restart-autofs-service` | Restart autofs service |
| `make remove-autofs` | Remove autofs NAS configuration |
| `make help-autofs` | Show autofs help message |

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
make status-autofs
```

This shows:
- NAS configuration details
- Autofs master and map file contents
- Mount point status
- Service status

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
make restart-autofs-service
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
make remove-autofs
```

This will:
1. Remove autofs configuration entries
2. Remove the mount point directory
3. Restart the autofs service

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
make remove-autofs
make setup-autofs
```

### Change NAS Host or Share

Simply re-run the credentials setup, which will prompt to reconfigure:

```bash
make setup-autofs-credentials
```

Then reconfigure autofs:
```bash
make remove-autofs
make setup-autofs
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
make restart-autofs-service
```

## References

- [Linux autofs documentation](https://www.kernel.org/doc/html/latest/filesystems/autofs.html)
- [macOS autofs guide](https://support.apple.com/guide/deployment/autofs-apdE7A43C2E-91F5-44AC-8FCD-7D9A7A6C4355/web)
- [Samba/CIFS mount options](https://linux.die.net/man/8/mount.cifs)
