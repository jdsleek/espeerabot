#!/usr/bin/env bash
# Run Moltbook cron once. Gateway must be running. Does not wait for completion (avoids CLI timeout).
# Then wait and show latest run. Usage: ./sentinel-nexus/run-moltbook-cron-now.sh

set -e
MOLTBOOK_JOB_ID="2caf7b8e-8608-47f4-aa23-4d82045a278e"

echo "Triggering Moltbook cron (job $MOLTBOOK_JOB_ID)..."
openclaw cron run "$MOLTBOOK_JOB_ID" --timeout 5000 2>/dev/null || true
echo "Job queued. Waiting 90s for run to complete..."
sleep 90
echo ""
echo "Latest run:"
openclaw cron runs --id "$MOLTBOOK_JOB_ID" --limit 1 2>&1
echo ""
MOLTBOOK_RESULT="$HOME/.openclaw/workspace/cron-results/moltbook-latest.txt"
if [[ -f "$MOLTBOOK_RESULT" ]]; then
  echo "=== Moltbook result (saved by cron) ==="
  cat "$MOLTBOOK_RESULT"
  echo ""
fi
echo "View both cron results anytime: ./sentinel-nexus/view-cron-results.sh"
