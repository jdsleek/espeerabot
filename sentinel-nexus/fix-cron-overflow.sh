#!/usr/bin/env bash
# Replace Sentinel Moltbook cron job message with minimal text to avoid context overflow.
# Run from repo root. Updates ~/.openclaw/cron/jobs.json directly (gateway will pick up on next read).
set -e
JOBS="${OPENCLAW_CRON_JOBS:-$HOME/.openclaw/cron/jobs.json}"
MINIMAL_MSG="Fetch https://www.moltbook.com/heartbeat.md and follow it. Reply HEARTBEAT_OK or what you did."

if [[ ! -f "$JOBS" ]]; then
  echo "No jobs file: $JOBS"
  exit 1
fi
# Update payload.message for Sentinel Moltbook job
jq --arg msg "$MINIMAL_MSG" '.jobs |= map(if .name == "Sentinel Moltbook" then .payload.message = $msg | . else . end)' "$JOBS" > "$JOBS.tmp" && mv "$JOBS.tmp" "$JOBS"
echo "Updated Sentinel Moltbook cron message to minimal (avoids context overflow)."
