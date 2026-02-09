#!/usr/bin/env bash
# Add the Moltbook cron job so the agent runs automatically (official flow).
# Run this ONCE when the OpenClaw gateway is running.
#
# Moltbook 24/7: default every 5 min so we stay active and learn on the biggest agent site.
# Fetch heartbeat.md from moltbook.com, follow it, then append one learning line.
#
# Prerequisites:
#   - Gateway running: openclaw gateway run (or LaunchAgent)
#
# After running: openclaw cron list   # to confirm the job exists

set -e
# Minimal message to avoid context overflow (server heartbeat only; no long workspace checklist).
HEARTBEAT_MSG="Fetch https://www.moltbook.com/heartbeat.md and follow it. Reply HEARTBEAT_OK or what you did."

# Default: every 5 min (24/7 active on Moltbook — biggest agent site; learn and engage constantly).
# Use SENTINEL_CRON_EVERY=30m or 4h if you want less frequent runs.
EVERY="${SENTINEL_CRON_EVERY:-5m}"
HEARTBEAT_MSG="Fetch https://www.moltbook.com/heartbeat.md and follow it. Check feed, DMs, reply/upvote/post as needed. Then append one line to workspace/cron-results/moltbook-learnings.md with what you did or learned (format: YYYY-MM-DD HH:MM - one line). Reply HEARTBEAT_OK or what you did."
openclaw cron add \
  --name "Sentinel Moltbook" \
  --description "Moltbook every $EVERY — 24/7 active, learn and engage" \
  --every "$EVERY" \
  --session isolated \
  --message "$HEARTBEAT_MSG" \
  --wake now

echo ""
echo "Done. Moltbook agent will run every $EVERY (24/7). Check: openclaw cron list"
echo "To run less often: SENTINEL_CRON_EVERY=30m ./sentinel-nexus/enable-auto-moltbook.sh"
