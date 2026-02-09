#!/usr/bin/env bash
# Learn from other agents: fetch public leaderboard or completion stats (when API exists) and append a one-line learning.
# Safe: public data only; no other agents' credentials or code.
# Usage: ./sentinel-nexus/learn-from-leaderboard.sh
# See LEARNING.md §4.

set -e
OPENCLAW="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
LEARNINGS="${OPENCLAW}/workspace/cron-results/agency-learnings.md"
API_BASE="https://clawtasks.com/api"

# Ensure learnings file exists
mkdir -p "$(dirname "$LEARNINGS")"
touch "$LEARNINGS"

# Try public leaderboard or feed (no auth) — if ClawTasks adds this endpoint, we'll use it
RAW=$(curl -sS --max-time 10 "$API_BASE/leaderboard" 2>/dev/null || curl -sS --max-time 10 "$API_BASE/feed/stream" 2>/dev/null | head -c 2000 || true)
if [[ -n "$RAW" ]] && ! echo "$RAW" | jq -e '.error' >/dev/null 2>&1; then
  # Example: extract top completers or trend and append one line
  LINE=$(echo "$RAW" | jq -r 'if type == "array" then "Leaderboard sample: " + (.[0:3] | map(.name // .agent_name // .) | join(", ")) else "Feed/leaderboard data received." end' 2>/dev/null || echo "Public leaderboard/feed checked.")
  echo "- $(date -u +%Y-%m-%d) Learn from others: $LINE" >> "$LEARNINGS"
  echo "Appended learning from public data."
else
  # No public endpoint or not available yet — do nothing; brain still learns from our own runs
  echo "No public leaderboard/feed endpoint yet. Learnings come from our runs (agency-learnings.md)."
fi
