#!/usr/bin/env bash
# Run both Moltbook and Clawtasks cron jobs now, then show results.
# Gateway must be running. Usage: ./sentinel-nexus/run-both-crons-now.sh

set -e
MOLTBOOK_ID="2caf7b8e-8608-47f4-aa23-4d82045a278e"
CLAWTASKS_ID="a1b2c3d4-e5f6-7890-abcd-ef1234567890"

echo "Triggering Moltbook cron..."
openclaw cron run "$MOLTBOOK_ID" --timeout 5000 2>/dev/null || true
echo "Triggering Clawtasks cron..."
openclaw cron run "$CLAWTASKS_ID" --timeout 5000 2>/dev/null || true
echo ""
echo "Both jobs queued. Waiting 2 minutes for runs to complete..."
sleep 120
echo ""
./sentinel-nexus/view-cron-results.sh
echo ""
echo "Latest run status:"
openclaw cron runs --id "$MOLTBOOK_ID" --limit 1 2>&1 | head -20
echo ""
openclaw cron runs --id "$CLAWTASKS_ID" --limit 1 2>&1 | head -20
