#!/usr/bin/env bash
# Quick status check for Sentinel_Nexus: heartbeat, state, learnings.
# Run from repo root or sentinel-nexus: ./sentinel-nexus/check-sentinel-status.sh

set -e
WORKSPACE="${OPENCLAW_WORKSPACE:-$HOME/.openclaw/workspace}"
STATE="$WORKSPACE/memory/heartbeat-state.json"
LEARNINGS="$WORKSPACE/memory/sentinel-learnings.md"

echo "=== Sentinel_Nexus status ==="
echo ""

echo "--- Last heartbeat (gateway) ---"
if command -v openclaw &>/dev/null; then
  openclaw system heartbeat last 2>/dev/null || echo "(openclaw not in PATH or gateway unreachable)"
else
  echo "(openclaw not in PATH)"
fi
echo ""

echo "--- State file: $STATE ---"
if [[ -f "$STATE" ]]; then
  ls -la "$STATE"
  echo "Contents:"
  cat "$STATE" | head -30
else
  echo "File not found."
fi
echo ""

echo "--- Learnings file: $LEARNINGS ---"
if [[ -f "$LEARNINGS" ]]; then
  ls -la "$LEARNINGS"
  echo "Last 25 lines:"
  tail -25 "$LEARNINGS"
else
  echo "File not found."
fi
echo ""

echo "--- Gateway (optional) ---"
if command -v openclaw &>/dev/null; then
  openclaw gateway status 2>/dev/null | head -15 || true
fi
echo ""
echo "Done. Run openclaw system heartbeat last after a run to see latest event."
