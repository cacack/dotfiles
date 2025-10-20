#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

print_header() {
    echo -e "${YELLOW}=== Security Scanning ===${NC}"
}

# Patterns to search for (case insensitive)
SENSITIVE_PATTERNS=(
    "password\s*=\s*['\"].*['\"]"
    "api[_-]?key\s*=\s*['\"].*['\"]"
    "secret\s*=\s*['\"].*['\"]"
    "token\s*=\s*['\"].*['\"]"
    "bearer\s+[a-zA-Z0-9_-]{20,}"
    "aws_access_key_id\s*=\s*['\"].*['\"]"
    "aws_secret_access_key\s*=\s*['\"].*['\"]"
    "BEGIN\s+(RSA\s+)?PRIVATE\s+KEY"
    "ssh-rsa\s+AAAA[0-9A-Za-z+/]+"
    "-----BEGIN\s+OPENSSH\s+PRIVATE\s+KEY-----"
)

# Files and patterns to exclude from scanning
EXCLUDE_PATTERNS=(
    ".git/"
    "*.md"  # Documentation files often contain example secrets
    "tests/test-security-scan.sh"  # This file contains patterns for testing
    ".smbcredentials"  # Expected to contain passwords (should be gitignored)
    ".autofs_config"  # Expected to contain NAS credentials (should be gitignored)
)

# Allowed/expected password handling patterns (these are safe)
ALLOWED_PATTERNS=(
    "read.*password"  # Reading password from user input
    "security find-generic-password"  # Reading from macOS Keychain
    "security add-generic-password"  # Adding to macOS Keychain
    "security delete-generic-password"  # Deleting from Keychain
    "printf.*password"  # Prompting for password
    "echo.*password"  # Password prompts/messages
    "NAS_PASSWORD="  # Variable assignment without hardcoded value
    "smb_pass"  # Variable name
    "# .*password"  # Comments mentioning passwords
)

test_gitignore_coverage() {
    echo "Checking .gitignore coverage for sensitive files:"

    local failures=0
    local sensitive_files=(
        ".smbcredentials"
        ".autofs_config"
        ".ssh/id_rsa"
        ".ssh/id_ed25519"
        ".env"
        "*.pem"
        "*.key"
    )

    if [[ ! -f "$DOTFILES_DIR/.gitignore" ]]; then
        echo -e "  ${YELLOW}⚠${NC} No .gitignore file found"
        return 0
    fi

    for pattern in "${sensitive_files[@]}"; do
        # Check if pattern or similar is in .gitignore (allowing wildcards)
        local base_pattern="${pattern#\*}"
        if grep -q "$base_pattern" "$DOTFILES_DIR/.gitignore" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $pattern is gitignored"
        else
            echo -e "  ${YELLOW}⚠${NC} $pattern not in .gitignore (consider adding if used)"
        fi
    done

    echo
    return 0
}

scan_for_hardcoded_secrets() {
    echo "Scanning for hardcoded secrets:"

    local total_findings=0
    local files_scanned=0

    # Build exclude pattern for grep
    local exclude_args=""
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        exclude_args="$exclude_args --exclude=$pattern"
    done

    for pattern in "${SENSITIVE_PATTERNS[@]}"; do
        # Search for pattern in all text files
        local matches=$(grep -r -i -E "$pattern" $exclude_args \
            --include="*.sh" \
            --include="*.zsh" \
            --include="*.mk" \
            --include="*.conf" \
            --include="*.config" \
            --include="*.yml" \
            --include="*.yaml" \
            "$DOTFILES_DIR" 2>/dev/null || true)

        if [[ -n "$matches" ]]; then
            # Filter out allowed patterns
            local filtered_matches=""
            while IFS= read -r line; do
                local is_allowed=0
                for allowed in "${ALLOWED_PATTERNS[@]}"; do
                    if echo "$line" | grep -q -i "$allowed"; then
                        is_allowed=1
                        break
                    fi
                done

                if [[ $is_allowed -eq 0 ]]; then
                    filtered_matches="${filtered_matches}${line}\n"
                    total_findings=$((total_findings + 1))
                fi
            done <<< "$matches"

            if [[ -n "$filtered_matches" ]]; then
                echo -e "${YELLOW}Potential secrets found matching '$pattern':${NC}"
                echo -e "$filtered_matches" | sed 's/^/    /'
            fi
        fi
    done

    echo
    if [[ $total_findings -eq 0 ]]; then
        echo -e "  ${GREEN}✓${NC} No hardcoded secrets detected"
        return 0
    else
        echo -e "  ${RED}✗${NC} Found $total_findings potential hardcoded secret(s)"
        echo -e "${YELLOW}Review the findings above and either:${NC}"
        echo -e "${YELLOW}  1. Remove hardcoded secrets and use secure storage (Keychain, env vars)${NC}"
        echo -e "${YELLOW}  2. Add to ALLOWED_PATTERNS if these are false positives${NC}"
        return 1
    fi
}

check_file_permissions() {
    echo "Checking permissions on sensitive files:"

    local failures=0

    # Check if any credential files exist with overly permissive permissions
    local sensitive_files=(
        "$HOME/.smbcredentials"
        "$HOME/.autofs_config"
        "$HOME/.ssh/id_rsa"
        "$HOME/.ssh/id_ed25519"
    )

    for file in "${sensitive_files[@]}"; do
        if [[ -f "$file" ]]; then
            local perms=$(stat -f "%Lp" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null)

            # Check if file is readable by group or others (should be 600 or 400)
            # Last two digits should be 00 (no group or other access)
            if [[ "$perms" =~ ^[0-7][0-7][1-7] ]] || [[ "$perms" =~ ^[0-7][1-7][0-7]$ ]]; then
                echo -e "  ${RED}✗${NC} $file has overly permissive permissions: $perms (should be 600 or 400)"
                failures=$((failures + 1))
            else
                echo -e "  ${GREEN}✓${NC} $file has appropriate permissions: $perms"
            fi
        fi
    done

    if [[ $failures -eq 0 ]]; then
        echo -e "  ${GREEN}✓${NC} All existing sensitive files have appropriate permissions"
    fi

    echo
    return $failures
}

main() {
    print_header

    local total_failures=0

    # Test 1: Check .gitignore coverage
    test_gitignore_coverage || total_failures=$((total_failures + 1))

    # Test 2: Scan for hardcoded secrets
    scan_for_hardcoded_secrets || total_failures=$((total_failures + 1))

    # Test 3: Check file permissions
    check_file_permissions || total_failures=$((total_failures + 1))

    echo
    if [[ $total_failures -eq 0 ]]; then
        echo -e "${GREEN}All security checks passed!${NC}"
        return 0
    else
        echo -e "${RED}$total_failures security check(s) failed${NC}"
        return 1
    fi
}

main "$@"
