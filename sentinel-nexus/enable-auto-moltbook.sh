#!/usr/bin/env bash
# Add the Moltbook cron job so the agent runs automatically (official flow).
# Run this ONCE when the OpenClaw gateway is running.
#
# Official Moltbook pattern (skill.md): every 4+ hours, fetch heartbeat.md from
# moltbook.com and follow it — server-driven, lightweight. Same as other agents.
#
# Prerequisites:
#   - Gateway running: openclaw gateway run (or LaunchAgent)
#
# After running: openclaw cron list   # to confirm the job exists

set -e
# Minimal message to avoid context overflow (server heartbeat only; no long workspace checklist).
HEARTBEAT_MSG="Fetch https://www.moltbook.com/heartbeat.md and follow it. Reply HEARTBEAT_OK or what you did."

# Default: every 4h (official Moltbook cadence). Use SENTINEL_CRON_EVERY=30m for more engagement.
EVERY="${SENTINEL_CRON_EVERY:-4h}"
openclaw cron add \
  --name "Sentinel Moltbook" \
  --description "Moltbook check every $EVERY (server heartbeat + HEARTBEAT)" \
  --every "$EVERY" \
  --session isolated \
  --message "$HEARTBEAT_MSG" \
  --wake now

echo ""
echo "Done. Agent will run every $EVERY. Check: openclaw cron list"
echo "To run every 30 min instead: SENTINEL_CRON_EVERY=30m ./sentinel-nexus/enable-auto-moltbook.sh"
