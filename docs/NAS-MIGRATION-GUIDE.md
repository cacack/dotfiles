# Migration Guide: autofs to NAS Mount (macOS)

This guide helps you migrate from the old autofs-based NAS mounting to the new launchd-based system on macOS.

## Why Migrate?

The old autofs implementation on macOS had several known issues:

1. **Ownership Bug**: Mounts frequently became owned by root after sleep/wake cycles
2. **Network Issues**: No auto-reconnect after WiFi changes
3. **Silent Failures**: Difficult to debug when things went wrong
4. **Maintenance Burden**: Required periodic manual fixes via `make autofs-fix`

The new launchd-based system solves all these issues with:

- Periodic health checks (every 5 minutes)
- Network-aware mounting (silent when NAS unreachable)
- Detailed logging for troubleshooting
- Automatic recovery from all edge cases
- No ownership bugs

## What Changes?

### Old System (autofs)
- **Technology**: macOS built-in autofs/automountd
- **Mount point**: `/System/Volumes/Data/shared-<username>`
- **Symlink**: `~/shared -> /System/Volumes/Data/shared-<username>`
- **Trigger**: On-demand when accessing mount point
- **Common issue**: Root ownership after sleep/wake

### New System (launchd)
- **Technology**: launchd + periodic mount script
- **Mount point**: `/Volumes/nas-<username>`
- **Symlink**: `~/shared -> /Volumes/nas-<username>`
- **Trigger**: Periodic check (every 5 minutes)
- **Benefits**: No ownership bugs, graceful network handling

### What Stays the Same?

- Configuration file: `~/.autofs_config` (reused)
- Credentials: macOS Keychain (reused)
- Access method: `~/shared` symlink (same location)
- Make commands: Similar (`nas-*` instead of `autofs-*`)

## Migration Steps

### Step 1: Check Current Status

```bash
make autofs-status
```

Note your current configuration (NAS host, share, username).

### Step 2: Remove Old autofs Configuration (Optional)

You can leave the old autofs configuration in place (it won't interfere), or clean it up:

```bash
make autofs-remove
```

This removes the autofs system configuration but keeps your `~/.autofs_config` and Keychain credentials.

**Manual cleanup** (if you want to be thorough):
```bash
# Remove autofs entries
sudo sed -i.bak '/auto_nas/d' /etc/auto_master
sudo rm -f /etc/auto_nas

# Remove old mount point (if exists)
sudo rmdir /System/Volumes/Data/shared-$USER 2>/dev/null || true

# Restart autofs to apply changes
sudo automount -vc
```

### Step 3: Install New System

```bash
make nas-mount
```

This will:
1. Detect your existing `~/.autofs_config` and offer to reuse it
2. Reuse your existing Keychain credentials
3. Install the new mount script
4. Install and load the LaunchAgent
5. Create the new mount point and symlink
6. Run an initial mount attempt

### Step 4: Verify Installation

```bash
make nas-status
```

You should see:
- `[OK] Mount script exists`
- `[OK] LaunchAgent exists`
- `[OK] LaunchAgent loaded and running`
- `[OK] Symlink: ~/shared -> /Volumes/nas-<username>`

### Step 5: Test the Mount

```bash
make nas-test
```

Or:
```bash
ls ~/shared
```

If the NAS is reachable, it should mount within 5 minutes. You can also force an immediate mount:

```bash
make nas-fix
# Select option 3: Force remount now
```

### Step 6: Check Logs

```bash
make nas-logs
```

You should see log entries showing successful mount or network status.

## Troubleshooting Migration

### Old Symlink Still Points to Old Mount Point

**Symptom**: `~/shared` points to `/System/Volumes/Data/shared-<user>` instead of `/Volumes/nas-<user>`

**Solution**:
```bash
rm ~/shared
make nas-mount
```

### Both Old and New Mounts Active

**Symptom**: Both `/System/Volumes/Data/shared-<user>` and `/Volumes/nas-<user>` are mounted

**Solution**: This is harmless but wastes resources. Remove the old autofs configuration:
```bash
sudo sed -i.bak '/auto_nas/d' /etc/auto_master
sudo rm -f /etc/auto_nas
sudo automount -vc
```

### Credentials Not Found

**Symptom**: "No password in Keychain" error

**Solution**: The old and new systems use the same Keychain format, so this shouldn't happen. If it does:
```bash
make nas-fix
# Select option 1: Refresh credentials
```

### Mount Not Working After Migration

**Check LaunchAgent status**:
```bash
launchctl list | grep com.user.nas-mount
```

**View logs**:
```bash
make nas-logs
```

**Force immediate mount**:
```bash
make nas-fix
# Select option 3: Force remount now
```

**Restart LaunchAgent**:
```bash
make nas-fix
# Select option 2: Restart launchd service
```

## Command Reference

### Old Commands → New Commands

| Old Command | New Command | Notes |
|-------------|-------------|-------|
| `make autofs` | `make nas-mount` | Setup/install |
| `make autofs-status` | `make nas-status` | Show status |
| `make autofs-test` | `make nas-test` | Test mount |
| `make autofs-fix` | `make nas-fix` | Fix issues |
| `make autofs-remove` | `make nas-remove` | Uninstall |
| N/A | `make nas-logs` | View logs (new!) |

### New Fix Menu Options

The `make nas-fix` menu now offers:
1. Refresh credentials (after password change)
2. Restart launchd service
3. Force remount now

**Removed** (no longer needed):
- Fix ownership bug (solved by new architecture)
- Install/uninstall auto-fix agent (not needed)

## Rollback (If Needed)

If you need to rollback to the old autofs system:

### Step 1: Remove New System
```bash
make nas-remove
```

### Step 2: Reinstall Old System

If you still have the old `autofs.mk` file:
```bash
# Temporarily restore old makefile
mv .make.d/nas-mount.mk .make.d/nas-mount.mk.backup
mv .make.d/autofs.mk.backup .make.d/autofs.mk  # if you have a backup

# Reinstall
make autofs
```

**Note**: The old autofs.mk is kept in git history. You can retrieve it with:
```bash
git show <commit-hash>:.make.d/autofs.mk > .make.d/autofs.mk
```

## FAQ

### Q: Will my data be affected?
**A**: No. The mount system only affects HOW you access the data, not the data itself on the NAS.

### Q: Can I keep both systems running?
**A**: Technically yes, but not recommended. They'll both try to mount to different locations and you'll have duplicate access points.

### Q: What if I'm not on my home network?
**A**: The new system silently skips mounting when the NAS is unreachable. When you return home, it will auto-mount within 5 minutes.

### Q: Do I need to reconfigure anything?
**A**: No. The new system reuses your `~/.autofs_config` and Keychain credentials.

### Q: What happens to my LaunchAgent fix from the old system?
**A**: You can remove it - it's no longer needed:
```bash
launchctl unload ~/Library/LaunchAgents/com.dotfiles.autofs-fix.plist 2>/dev/null || true
rm ~/Library/LaunchAgents/com.dotfiles.autofs-fix.plist
```

### Q: Is Linux affected?
**A**: No. Linux still uses autofs (it works well on Linux). Only macOS changed to the new system.

### Q: How do I know the migration succeeded?
**A**: Run `make nas-status` and verify you see:
- `[OK] LaunchAgent loaded and running`
- `[OK] Symlink: ~/shared -> /Volumes/nas-<username>`
- Mount works: `ls ~/shared` shows your NAS files

## Support

If you encounter issues during migration:

1. **Check status**: `make nas-status`
2. **Check logs**: `make nas-logs`
3. **Try force mount**: `make nas-fix` → option 3
4. **Restart service**: `make nas-fix` → option 2

For persistent issues, check the main documentation:
```bash
cat docs/NAS-MOUNT-SETUP.md
```
