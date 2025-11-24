#!/bin/bash
################################################################################
# mount-nas.sh - Robust NAS mounting script for macOS
#
# This script is run periodically by launchd (every 5 minutes) to ensure
# the NAS share is mounted when on the home network. It handles:
# - Silent failure when network unavailable
# - Already-mounted detection (no-op if mounted)
# - Network availability checking (ping test)
# - Keychain password retrieval
# - Symlink management
# - Detailed logging for troubleshooting
#
# Exit codes:
#   0 - Success (mounted or already mounted)
#   1 - Silent failure (expected - network unavailable, config missing, etc.)
#   2 - Error (unexpected - logged for troubleshooting)
################################################################################

set -euo pipefail

# Configuration
CONFIG_FILE="${HOME}/.autofs_config"
MOUNT_POINT="/Volumes/nas-${USER}"
SYMLINK="${HOME}/shared"
LOG_FILE="${HOME}/.local/share/logs/nas-mount.log"
MAX_LOG_LINES=500

################################################################################
# Logging functions
################################################################################

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >> "$LOG_FILE"
}

# Rotate log file if it gets too large
rotate_log() {
    if [ -f "$LOG_FILE" ]; then
        local line_count
        line_count=$(wc -l < "$LOG_FILE" 2>/dev/null || echo 0)
        if [ "$line_count" -gt "$MAX_LOG_LINES" ]; then
            tail -n "$MAX_LOG_LINES" "$LOG_FILE" > "${LOG_FILE}.tmp"
            mv "${LOG_FILE}.tmp" "$LOG_FILE"
        fi
    fi
}

################################################################################
# Helper functions
################################################################################

# Silent exit - used for expected failures (network unavailable, etc.)
silent_exit() {
    log "$1"
    exit 0
}

# Error exit - used for unexpected failures
error_exit() {
    log_error "$1"
    exit 2
}

# Check if NAS is already mounted
is_mounted() {
    # Check if our specific share is mounted anywhere
    mount | grep -q "//${nas_username}@${nas_host}/${nas_share}"
}

# Create log directory if it doesn't exist
ensure_log_dir() {
    local log_dir
    log_dir=$(dirname "$LOG_FILE")
    if [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir" 2>/dev/null || true
    fi
}

# Create mount point directory if it doesn't exist
ensure_mount_point() {
    # On macOS, mount_smbfs creates /Volumes/ mount points automatically
    # We don't need to (and can't without sudo) pre-create them
    # Just verify /Volumes exists (it always should on macOS)
    if [ ! -d "/Volumes" ]; then
        error_exit "/Volumes directory not found (unexpected on macOS)"
    fi
}

# Create or update symlink to actual mount location
ensure_symlink() {
    local target_mount="$1"
    local search_host="${2:-}"
    local search_share="${3:-}"

    # If no target specified, try to find it
    if [ -z "$target_mount" ] && [ -n "$search_host" ] && [ -n "$search_share" ]; then
        # Look for mounts matching our NAS host
        target_mount=$(mount | grep "${search_host}/${search_share}" | awk '{print $3}' | head -1)
    fi

    # If still not found, can't create symlink
    if [ -z "$target_mount" ] || [ ! -d "$target_mount" ]; then
        log_error "Cannot create symlink: mount point not found"
        return 1
    fi

    if [ ! -L "$SYMLINK" ]; then
        ln -sf "$target_mount" "$SYMLINK" 2>/dev/null || \
            log_error "Failed to create symlink: $SYMLINK -> $target_mount"
    elif [ "$(readlink "$SYMLINK")" != "$target_mount" ]; then
        rm -f "$SYMLINK"
        ln -sf "$target_mount" "$SYMLINK" 2>/dev/null || \
            log_error "Failed to update symlink: $SYMLINK -> $target_mount"
    fi

    log "Symlink created/updated: $SYMLINK -> $target_mount"
}

# Check network connectivity to NAS host
check_network() {
    local nas_host="$1"
    # Ping with 2 second timeout, 1 packet
    if ping -c 1 -W 2 "$nas_host" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Retrieve password from Keychain
get_password() {
    local nas_host="$1"
    local nas_username="$2"
    local password

    password=$(security find-generic-password -s "$nas_host" -a "$nas_username" -w 2>/dev/null || echo "")

    if [ -z "$password" ]; then
        error_exit "No password in Keychain for ${nas_username}@${nas_host}"
    fi

    echo "$password"
}

# Mount the NAS share
mount_nas() {
    local nas_host="$1"
    local nas_share="$2"
    local nas_username="$3"
    local nas_password="$4"

    local smb_url="smb://${nas_username}:${nas_password}@${nas_host}/${nas_share}"

    # Use AppleScript to mount (handles mount point creation automatically)
    # This is the same approach Finder uses and handles Keychain integration
    if osascript -e "mount volume \"${smb_url}\"" 2>&1 | tee -a "$LOG_FILE"; then
        log "Successfully mounted ${nas_host}/${nas_share}"

        # Find where it was mounted (usually /Volumes/<share-name> or /Volumes/<share-name>-1)
        # Wait a moment for the mount to appear
        sleep 1

        # Look for the mount in common locations
        for possible_mount in "/Volumes/${nas_share}" "/Volumes/${nas_share}-1" "/Volumes/${nas_share}-2"; do
            if [ -d "$possible_mount" ] && mount | grep -q "$possible_mount"; then
                ACTUAL_MOUNT_POINT="$possible_mount"
                log "Mount detected at: $ACTUAL_MOUNT_POINT"
                return 0
            fi
        done

        # If we can't find it, just return success (it's mounted somewhere)
        log "Mount successful but location auto-detected"
        return 0
    else
        error_exit "Failed to mount ${nas_host}/${nas_share}"
    fi
}

################################################################################
# Main execution
################################################################################

main() {
    # Initialize logging
    ensure_log_dir
    rotate_log

    # Check if config file exists
    if [ ! -f "$CONFIG_FILE" ]; then
        silent_exit "Config file not found: $CONFIG_FILE (not configured yet)"
    fi

    # Read configuration
    nas_host=$(grep '^nas_host=' "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2 || echo "")
    nas_share=$(grep '^nas_share=' "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2 || echo "")
    nas_username=$(grep '^nas_username=' "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2 || echo "")

    # Validate configuration
    if [ -z "$nas_host" ] || [ -z "$nas_share" ] || [ -z "$nas_username" ]; then
        error_exit "Invalid configuration in $CONFIG_FILE (missing nas_host, nas_share, or nas_username)"
    fi

    # Check if already mounted
    if is_mounted; then
        # Find where it's mounted
        existing_mount=$(mount | grep "//${nas_username}@${nas_host}/${nas_share}" | awk '{print $3}' | head -1)
        if [ -n "$existing_mount" ] && ls "$existing_mount" >/dev/null 2>&1; then
            # Update symlink to point to existing mount
            ensure_symlink "$existing_mount"
            silent_exit "Already mounted and accessible at $existing_mount"
        else
            log "Mount exists but not accessible, forcing unmount"
            diskutil unmount force "$existing_mount" 2>/dev/null || true
        fi
    fi

    # Check network connectivity
    if ! check_network "$nas_host"; then
        silent_exit "NAS host $nas_host not reachable (probably not on home network)"
    fi

    # Ensure mount point exists
    ensure_mount_point

    # Get password from Keychain
    password=$(get_password "$nas_host" "$nas_username")

    # Mount the share
    mount_nas "$nas_host" "$nas_share" "$nas_username" "$password"

    # Create/update symlink (will auto-detect mount point)
    ensure_symlink "" "$nas_host" "$nas_share"

    log "Mount cycle completed successfully"
    exit 0
}

# Run main function
main "$@"
