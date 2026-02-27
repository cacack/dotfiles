#!/usr/bin/env bash
# ccstatusline-usage.sh - Display Claude Code Enterprise Premium session usage
# Shows 5-hour session utilization percentage with progress bar
# Skips output when using Bedrock (CLAUDE_CODE_USE_BEDROCK=1)

# Skip if using Bedrock - no session limits apply
[[ "${CLAUDE_CODE_USE_BEDROCK:-0}" == "1" ]] && exit 0

CACHE_FILE="$HOME/.cache/ccstatusline-usage.txt"
LOCK_FILE="$HOME/.cache/ccstatusline-usage.lock"

# Function to generate progress bar
make_bar() {
  local pct="$1"
  local width=15
  local filled=$((pct * width / 100))
  local empty=$((width - filled))
  printf "["
  printf "█%.0s" $(seq 1 "$filled")
  printf "░%.0s" $(seq 1 "$empty")
  printf "]"
}

# Use cache if < 180 seconds old
if [[ -f "$CACHE_FILE" ]]; then
  AGE=$(($(date +%s) - $(stat -f '%m' "$CACHE_FILE")))
  [[ $AGE -lt 180 ]] && cat "$CACHE_FILE" && exit 0
fi

# Rate limit: only try API once per 30 seconds
if [[ -f "$LOCK_FILE" ]]; then
  LOCK_AGE=$(($(date +%s) - $(stat -f '%m' "$LOCK_FILE")))
  if [[ $LOCK_AGE -lt 30 ]]; then
    [[ -f "$CACHE_FILE" ]] && cat "$CACHE_FILE" && exit 0
    echo "[Timeout]" && exit 1
  fi
fi
touch "$LOCK_FILE"

# Keychain may return plain JSON or hex-encoded data depending on how it was stored
RAW=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
TOKEN=$(echo "$RAW" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
if [[ -z "$TOKEN" ]]; then
  TOKEN=$(echo "$RAW" | xxd -r -p | grep -o '"accessToken":"[^"]*"' | head -1 | sed 's/"accessToken":"//;s/"$//')
fi
if [[ -z "$TOKEN" ]]; then
  [[ -f "$CACHE_FILE" ]] && cat "$CACHE_FILE" && exit 0
  echo "[No credentials]"
  exit 1
fi

RESPONSE=$(curl -s --max-time 5 "https://api.anthropic.com/api/oauth/usage" -H "Authorization: Bearer $TOKEN" -H "anthropic-beta: oauth-2025-04-20" 2>/dev/null)

if [[ -z "$RESPONSE" ]]; then
  [[ -f "$CACHE_FILE" ]] && cat "$CACHE_FILE" && exit 0
  echo "[API Error]"
  exit 1
fi

SESSION=$(echo "$RESPONSE" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
RESETS_AT=$(echo "$RESPONSE" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)
WEEKLY=$(echo "$RESPONSE" | jq -r '.seven_day.utilization // empty' 2>/dev/null)

# Session is required, weekly and reset time are optional
if [[ -z "$SESSION" ]]; then
  [[ -f "$CACHE_FILE" ]] && cat "$CACHE_FILE" && exit 0
  echo "[Parse Error]"
  exit 1
fi

SESSION_INT=${SESSION%.*}
SESSION_BAR=$(make_bar "$SESSION_INT")

# Format reset time to local time (e.g., "3:59pm")
RESET_STR=""
if [[ -n "$RESETS_AT" ]]; then
  # Convert ISO8601 UTC timestamp to local time
  EPOCH=$(date -juf '%Y-%m-%dT%H:%M:%S' "${RESETS_AT%%.*}" '+%s' 2>/dev/null)
  if [[ -n "$EPOCH" ]]; then
    RESET_STR=" | Resets $(date -jf '%s' "$EPOCH" '+%-l:%M%p' | tr '[:upper:]' '[:lower:]')"
  fi
fi

# Build output - weekly is optional
if [[ -n "$WEEKLY" ]]; then
  WEEKLY_INT=${WEEKLY%.*}
  WEEKLY_BAR=$(make_bar "$WEEKLY_INT")
  echo "Session: $SESSION_BAR ${SESSION_INT}%${RESET_STR} | Weekly: $WEEKLY_BAR ${WEEKLY_INT}%" | tee "$CACHE_FILE"
else
  echo "Session: $SESSION_BAR ${SESSION_INT}%${RESET_STR}" | tee "$CACHE_FILE"
fi
