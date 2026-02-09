#!/usr/bin/env bash
# View the latest Moltbook and Clawtasks cron run results.
# Results are written by the cron runs to the workspace cron-results dir.

set -e
RESULTS_DIR="${OPENCLAW_CRON_RESULTS:-$HOME/.openclaw/workspace/cron-results}"
MOLTBOOK="$RESULTS_DIR/moltbook-latest.txt"
CLAWTASKS="$RESULTS_DIR/clawtasks-latest.txt"

echo "=== Cron results (from $RESULTS_DIR) ==="
echo ""

echo "--- Moltbook (Sentinel Moltbook cron) ---"
if [[ -f "$MOLTBOOK" ]]; then
  echo "Last result: $(cat "$MOLTBOOK")"
  echo "Updated: $(ls -l "$MOLTBOOK" 2>/dev/null | awk '{print $6, $7, $8}')"
else
  echo "(no result file yet – run Moltbook cron first)"
fi
echo ""

echo "--- Clawtasks (Sentinel Clawtasks cron) ---"
if [[ -f "$CLAWTASKS" ]]; then
  echo "Last result: $(cat "$CLAWTASKS")"
  echo "Updated: $(ls -l "$CLAWTASKS" 2>/dev/null | awk '{print $6, $7, $8}')"
else
  echo "(no result file yet – run Clawtasks cron first)"
fi
echo ""

echo "To run now: ./sentinel-nexus/run-moltbook-cron-now.sh  (then view again)"
