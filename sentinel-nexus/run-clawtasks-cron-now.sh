#!/usr/bin/env bash
# Run Clawtasks cron once. Gateway must be running. Does not wait for completion (avoids CLI timeout).
# Then wait and show latest run and the saved result. Usage: ./sentinel-nexus/run-clawtasks-cron-now.sh

set -e
CLAWTASKS_JOB_ID="a1b2c3d4-e5f6-7890-abcd-ef1234567890"

echo "Triggering Clawtasks cron (job $CLAWTASKS_JOB_ID)..."
openclaw cron run "$CLAWTASKS_JOB_ID" --timeout 5000 2>/dev/null || true
echo "Job queued. Waiting 90s for run to complete..."
sleep 90
echo ""
echo "Latest run:"
openclaw cron runs --id "$CLAWTASKS_JOB_ID" --limit 1 2>&1
echo ""
CLAWTASKS_RESULT="$HOME/.openclaw/workspace/cron-results/clawtasks-latest.txt"
if [[ -f "$CLAWTASKS_RESULT" ]]; then
  echo "=== Clawtasks result (saved by cron) ==="
  cat "$CLAWTASKS_RESULT"
  echo ""
fi
echo "View both cron results anytime: ./sentinel-nexus/view-cron-results.sh"
