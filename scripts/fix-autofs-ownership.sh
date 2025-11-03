#!/bin/bash
# Fix macOS autofs ownership bug where mounts become owned by root
# after sleep/wake or network reconnection

MOUNT_POINT="/System/Volumes/Data/shared-${USER}"

echo "==> Fixing autofs mount ownership"

# Check if mount exists and is owned by root
if mount | grep -q "$MOUNT_POINT"; then
    OWNER=$(stat -f '%Su' "$MOUNT_POINT" 2>/dev/null || echo "unknown")

    if [ "$OWNER" = "root" ] || [ "$OWNER" = "unknown" ]; then
        echo "Mount ownership issue detected (owned by: $OWNER) - fixing..."

        # Force unmount the stale mount and refresh autofs
        sudo umount -f "$MOUNT_POINT" 2>/dev/null || true
        sudo automount -vc

        sleep 2

        # Trigger remount by accessing the path
        ls "$MOUNT_POINT" >/dev/null 2>&1 || true

        # Verify fix
        if ls "$MOUNT_POINT" >/dev/null 2>&1; then
            echo "✓ Mount ownership fixed successfully"
        else
            echo "✗ Mount still not accessible - may need manual intervention"
        fi
    else
        echo "✓ Mount is already owned by $OWNER (no fix needed)"
    fi
else
    echo "Mount not found - triggering initial mount..."
    sudo automount -vc
fi
